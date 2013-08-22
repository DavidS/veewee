
set -e -x

DEST="/var/lib/zetbox/$(date --iso)"
# encode the path for systemd
DEST_ENC="${DEST//-/\\x2d}"
DEST_ENC="${DEST_ENC#/}"
DEST_ENC="${DEST_ENC//\//-}"

addgroup --system zetbox
adduser --system --home=/var/lib/zetbox --ingroup zetbox zetbox

# install required software
apt-get -y install nginx postgresql postgresql-contrib apache2-utils

# ignore unsigned warning
apt-get -y --force-yes install mono-complete mono-fastcgi-server4


# fetch prepared binaries from build server
wget 'http://jenkins:8080/view/dasz/job/dasz-develop-Linux_deploy/ws/deployed/*zip*/deployed.zip' -O zetbox.zip
mkdir -p "$DEST"
unzip zetbox.zip -d "$DEST"

wget 'http://jenkins:8080/view/dasz/job/dasz-develop-Linux_deploy/ws/Configs/Appliance/*zip*/Appliance.zip'
unzip Appliance.zip -d "$DEST"
mv "$DEST/Appliance" "$DEST/Configs"


# prepare some required directories
cat <<EOF >/etc/tmpfiles.d/zetbox.conf
d	/run/zetbox	0755	zetbox	zetbox	10d	-
d	/var/log/zetbox	0750	zetbox	zetbox	-	-
EOF

systemd-tmpfiles --create


# configure the zetbox fastcgi service
cat <<EOF >/etc/systemd/system/zetbox@.service
[Unit]
Description=zetbox FastCGI process for %f

[Service]
User=zetbox
WorkingDirectory=%f
# make socket accessible for zetbox group members
UMask=007
ExecStart=/usr/bin/fastcgi-mono-server4 /socket=unix:/run/zetbox/%i.fastcgi /root=%f /applications=/:. /printlog=True /loglevels=Standard

[Install]
WantedBy=multi-user.target

EOF

# needs to be done manually since systemd is not running yet
mkdir -p /etc/systemd/system/multi-user.target.wants/
ln -s /etc/systemd/system/zetbox@.service "/etc/systemd/system/multi-user.target.wants/zetbox@${DEST_ENC}.service"


# configure nginx
cat <<EOF >/etc/nginx/sites-enabled/default
server {
	server_name zetbox;

	location / {
		fastcgi_pass unix:/run/zetbox/${DEST_ENC}.fastcgi;
		fastcgi_index Default.aspx;
		include fastcgi_params;
	}

	location /.htpasswd {
		deny all;
	}
}
EOF


# create database
export DB_PASS="eicheGhah8thohSho7qu"
echo -e "$DB_PASS\n$DB_PASS" | su - postgres -c 'createuser --encrypted --no-createdb --no-createrole --no-superuser --pwprompt zetbox'
su - postgres -c 'createdb --encoding=utf-8 --owner=zetbox zetbox'
su - postgres -c "psql -c 'CREATE EXTENSION \"uuid-ossp\"' zetbox"

cd "${DEST}"
mono --debug ./deployed/PrepareEnv.exe Configs
cd deployed

htpasswd -bc .htpasswd zetbox "$DB_PASS"
htpasswd -b .htpasswd admin admin
mono --debug ./Zetbox.Cli.exe --fallback --deploy-update --syncidentities

