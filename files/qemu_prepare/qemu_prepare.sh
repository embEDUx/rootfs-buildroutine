#!/bin/bash -e
## This code runs inside the rootfs
DIR=$(dirname ${0})
pushd ${DIR}

# fstab
cp fstab /etc/fstab

# Inittab
echo f0:12345:respawn:/sbin/agetty -a root 115200 ttyAMA0 vt100 >> /etc/inittab

# Networking
ln -sf /etc/init.d/net.lo /etc/init.d/net.eth0
/sbin/rc-update add net.eth0 default

# Kernel sources (needed by some packages to build properly)
tar -xa -C / -f linux-rootfs-addon.tar
ln -sf /usr/src/linux-* /usr/src/linux
cp linux.config /usr/src/linux/.config
mkdir -p /etc/portage/profile
echo virtual/linux-sources-1 >> /etc/portage/profile/package.provided

# Dist-CC
emerge sys-devel/distcc
echo FEATURES=\"\${FEATURES} distcc distcc-pump\" >> /etc/portage/make.conf
echo "10.0.2.2,lzo,cpp" > /etc/distcc/hosts

WRAPPER_BASE=$(ls -1 /usr/lib/distcc/bin/ | grep -o ".*-" | uniq)
cat << EOF > /usr/lib/distcc/bin/${WRAPPER_BASE}wrapper
#!/bin/bash
exec /usr/lib/distcc/bin/${WRAPPER_BASE}g\${0:\$[-2]} "\$@"
EOF
chmod +x /usr/lib/distcc/bin/${WRAPPER_BASE}wrapper
rm /usr/lib/distcc/bin/{c++,g++,gcc,cc}
for cmd in c++ g++ gcc cc; do
    ln -s ${WRAPPER_BASE}wrapper /usr/lib/distcc/bin/${cmd}
done

# Script to notify the waiting host
cp send_signal_from_vm.py /etc/local.d/send_signal_from_vm.py.start

popd
