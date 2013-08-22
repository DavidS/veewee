# configure dasz' local mirror
cp /etc/apt/sources.list{,.orig}
cat <<EOF >/etc/apt/sources.list
deb http://kvmhost.dasz:3142/debian wheezy main
deb http://kvmhost.dasz:3142/security wheezy/updates main
deb http://kvmhost.dasz:3142/debian wheezy-updates main
# Use recompiled mono3 for squeeze
deb http://kvmhost.dasz/debian zetbox main
EOF

# Update the box
apt-get -y update
apt-get -y full-upgrade
apt-get -y install linux-headers-$(uname -r) build-essential \
		zlib1g-dev libssl-dev libreadline-gplv2-dev \
		curl unzip systemd

# Set up sudo
echo 'vagrant ALL=NOPASSWD:ALL' > /etc/sudoers.d/vagrant

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="init=/lib/systemd/systemd"
EOF

update-grub
