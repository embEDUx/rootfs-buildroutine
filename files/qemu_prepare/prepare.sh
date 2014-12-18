#!/bin/bash -e
## This code runs inside the rootfs

# fstab
DIR=$(dirname ${0})
pushd ${DIR}
cp fstab /etc/fstab

# make.conf defaults
cat make.conf.appendix >> /etc/portage/make.conf

# Localization
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
echo de_DE.UTF-8 UTF-8 >> /etc/locale.gen
/usr/sbin/locale-gen

# Serial terminal
echo f0:12345:respawn:/sbin/agetty -a root 9600 ttyAMA0 vt100 >> /etc/inittab

# Networking
ln -sf /etc/init.d/net.lo /etc/init.d/net.eth0
/sbin/rc-update add net.eth0 default

# SSH
mkdir /root/.ssh/ -p
chmod 700 /root/.ssh
cp qemu.id.pub /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
/sbin/rc-update add sshd default

# Dist-CC
#emerge-webrsync
#emerge sys-devel/distcc
#
#WRAPPER_BASE=$(ls -1 /usr/lib/distcc/bin/ | grep -o ".*-" | uniq)
#cat << EOF > /usr/lib/distcc/bin/${WRAPPER_BASE}wrapper
##!/bin/bash
#exec /usr/lib/distcc/bin/${WRAPPER_BASE}g\${0:\$[-2]} "\$@"
#EOF
#chmod +x /usr/lib/distcc/bin/${WRAPPER_BASE}wrapper
#rm /usr/lib/distcc/bin/{c++,g++,gcc,cc}
#for cmd in c++ g++ gcc cc; do
#    ln -s ${WRAPPER_BASE}wrapper /usr/lib/distcc/bin/${cmd}
#done
#
#echo FEATURES=\"\${FEATURES} distcc\" >> /etc/portage/make.conf
#echo "10.0.2.2,lzo,cpp" > /etc/distcc/hosts

popd
