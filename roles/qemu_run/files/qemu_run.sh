#!/bin/bash

#QEMU_AUDIO_DRV=none qemu-system-arm \
#  -M virt \
#  -m 3072 \
#  -nographic \
#  -kernel zImage \
#  -append "root=/dev/root rw rootflags=rw,trans=virtio,version=9p2000.L rootfstype=9p console=ttyAMA0" \
#  -net user \
#  -netdev user,id=vnet0 \
#  -device virtio-net-device,netdev=vnet0 \
#  -device virtio-serial-device \
#  -chardev socket,path=/tmp/foo,server,nowait,id=vconsole \
#  -device virtserialport,chardev=vconsole,name=vconsole \
#  -fsdev local,id=root,path=/var/tmp/embedux/rootfs/,security_model=mapped-file \
#  -device virtio-9p-device,fsdev=root,mount_tag=/dev/root

QEMU_AUDIO_DRV=none qemu-system-${TARGET_ARCH_SHORT} \
  -M virt \
  -m 3072 \
  -daemonize \
  -pidfile ${PIDFILE} \
  -kernel ${KERNEL_DIR}/zImage \
  -append "root=/dev/vda rw rootflags=subvol=qemu_run console=ttyAMA0" \
  -net user \
  -netdev user,id=vnet0 \
  -redir tcp:2222::22 \
  -device virtio-net-device,netdev=vnet0 \
  -drive file=${IMAGE},id=root \
  -device virtio-blk-device,drive=root
