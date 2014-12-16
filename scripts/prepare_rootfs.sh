#!/bin/bash

SERIAL=ttyAMA0
MAKE_CONF_APPENDIX="~/synchronized/embEDUx/buildserver_setup/roles/docker_base/files/make.conf.appendix"
FSTAB="~/synchronized/embEDUx/rootfs/files/fstab"

mkdir -p /var/tmp/embedux/{stage3,rootfs}
IMAGE=$(docker images -q embedux/stage3-{{ target_arch }} | tail -n1)
docker save $IMAGE | tar -xv --strip-components=1 -C /var/tmp/embedux/stage3 -f -

rm -Rf /var/tmp/embedux/rootfs/*
tar -xv -C /var/tmp/embedux/rootfs -f /var/tmp/embedux/stage3/layer.tar 


# fstab
cp ${FSTAB} /var/tmp/embedux/rootfs/etc/fstab

# make.conf defaults
cat ${MAKE_CONF_APPENDIX} >> /var/tmp/embedux/rootfs/etc/portage/make.conf
echo FEATURES=\"\${FEATURES} distcc\" >> /var/tmp/embedux/rootfs/etc/portage/make.conf


# locales
echo en_US.UTF-8 UTF-8 >> /var/tmp/embedux/rootfs/etc/locale.gen
echo de_DE.UTF-8 UTF-8 >> /var/tmp/embedux/rootfs/etc/locale.gen
proot -S /var/tmp/embedux/rootfs/ -q /usr/bin/qemu-arm -i 0:0 /usr/sbin/locale-gen

# Terminal
echo f0:12345:respawn:/sbin/agetty -a root 9600 ${SERIAL} vt100 >> rootfs/etc/inittab

# Networking
ln -sf /etc/init.d/net.lo /var/tmp/embedux/rootfs/etc/init.d/net.eth0
proot -S /var/tmp/embedux/rootfs/ -q /usr/bin/qemu-arm -i 0:0 /sbin/rc-update add net.eth0 default

# SSH
mkdir /var/tmp/embedux/ssh_creds
echo | ssh-keygen -f /var/tmp/embedux/ssh_creds/qemu.id
mkdir /var/tmp/embedux/rootfs/root/.ssh/ -p
cat /var/tmp/embedux/ssh_creds/qemu.id.pub >> /var/tmp/embedux/rootfs/root/.ssh/authorized_keys
proot -S /var/tmp/embedux/rootfs/ -q /usr/bin/qemu-arm -i 0:0 /sbin/rc-update add sshd default

# Dist-CC
WRAPPER_BASE=$(ls -1 /var/tmp/embedux/rootfs/usr/lib/distcc/bin/ | grep -o ".*-" | uniq)
cat << EOF > /var/tmp/embedux/rootfs/usr/lib/distcc/bin/${WRAPPER_BASE}wrapper
#!/bin/bash
exec /usr/lib/distcc/bin/${WRAPPER_BASE}g\${0:\$[-2]} "\$@"
EOF
chmod +x /var/tmp/embedux/rootfs/usr/lib/distcc/bin/${WRAPPER_BASE}wrapper
rm /var/tmp/embedux/rootfs/usr/lib/distcc/bin/{c++,g++,gcc,cc}
for cmd in c++ g++ gcc cc; do
    ln -s ${WRAPPER_BASE}wrapper /var/tmp/embedux/rootfs/usr/lib/distcc/bin/${cmd}
done

echo FEATURES=\"\${FEATURES} distcc\" >> /var/tmp/embedux/rootfs/etc/portage/make.conf
echo "10.0.2.2,lzo,cpp" > /var/tmp/embedux/rootfs/etc/distcc/hosts


ROOT=/var/tmp/embedux/rootfs/ PORTAGE_CONFIGROOT=/var/tmp/embedux/rootfs/ flaggie app-emulation/docker +kw::~*
