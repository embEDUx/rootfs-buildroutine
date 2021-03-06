#!/bin/bash -e
## This code runs inside the rootfs
DIR=$(dirname ${0})
pushd ${DIR}

# make.conf defaults
cat make.conf.appendix >> /etc/portage/make.conf

# Localization
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
echo de_DE.UTF-8 UTF-8 >> /etc/locale.gen
/usr/sbin/locale-gen


# SSH
mkdir /root/.ssh/ -p
chmod 700 /root/.ssh
cp target.id.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
/sbin/rc-update add sshd default

# Python 2.7 needed by ansible
eselect python set python2.7

# Portage
mkdir -p /usr/portage/distfiles
chown -R portage:portage /usr/portage
emerge --sync
chown -R portage:portage /usr/portage
emerge gentoolkit flaggie

# Prepare binary packages
mkdir /mnt/pkgdir
chown -R portage:portage /mnt/pkgdir
echo PKGDIR=\"\/mnt/pkgdir\" >> /etc/portage/make.conf

popd
