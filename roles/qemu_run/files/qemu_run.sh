#!/bin/bash

QEMU_AUDIO_DRV=none qemu-system-${QEMU_ARCH} \
  -M ${MACHINE_ARG} \
  -m 3072 \
  -daemonize \
  -pidfile ${PIDFILE} \
  -kernel ${KERNEL_DIR}/zImage \
  -append "root=/dev/vda rw rootflags=subvol=target_run console=ttyAMA0" \
  -net user \
  -netdev user,id=vnet0 \
  -redir tcp:2222::22 \
  -device virtio-net-device,netdev=vnet0 \
  -drive file=${IMAGE},id=root \
  -device virtio-blk-device,drive=root
