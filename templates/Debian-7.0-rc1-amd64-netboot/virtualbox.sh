
# install the current dkms drivers
apt-get install -y virtualbox-guest-dkms
# Make a temporary mount point
mkdir /tmp/veewee-validation
# Test mount the veewee-validation
mount -t vboxsf veewee-validation /tmp/veewee-validation

