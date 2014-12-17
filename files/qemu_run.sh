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

QEMU_AUDIO_DRV=none qemu-system-arm \
  -M virt \
  -m 3072 \
  -nographic \
  -kernel zImage \
  -append "root=/dev/mmcblk0 rw rootflags=rw,subvol=qemu_prepare console=ttyAMA0" \
  -net user \
  -netdev user,id=vnet0 \
  -device virtio-net-device,netdev=vnet0 \
  -sd ${EMBEDUX_TMP}/rootfs.btrfs.img 8G
