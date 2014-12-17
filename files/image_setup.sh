#!/bin/bash -e

# Store stage3 in a subvolume
if [ ! -d /var/tmp/embedux/rootfs.btrfs.mnt/stage3 ]; then
  # Create image, format and mount btrfs
  mkdir -p /var/tmp/embedux
  qemu-img create -f raw /var/tmp/embedux/rootfs.btrfs.img 8G
  mkfs.btrfs /var/tmp/embedux/rootfs.btrfs.img
  mkdir /var/tmp/embedux/rootfs.btrfs.mnt
  sudo mount /var/tmp/embedux/rootfs.btrfs.img /var/tmp/embedux/rootfs.btrfs.mnt
  IMAGE=$(sudo docker images -q embedux/stage3-{{ target_arch }} | tail -n1)
  sudo btrfs subvolume create /var/tmp/embedux/rootfs.btrfs.mnt/stage3
  sudo docker save $IMAGE | \
    tar --to-stdout -xv --strip-components=1 -f - --wildcards */layer.tar | \
    sudo tar -xpv -f - -C /var/tmp/embedux/rootfs.btrfs.mnt/stage3/
fi

# Create a snapshot
if [ -d  /var/tmp/embedux/rootfs.btrfs.mnt/qemu-prepare ]; then
  sudo btrfs subvolume delete /var/tmp/embedux/rootfs.btrfs.mnt/qemu-prepare
fi
sudo btrfs subvolume snapshot /var/tmp/embedux/rootfs.btrfs.mnt/stage3 /var/tmp/embedux/rootfs.btrfs.mnt/qemu-prepare/

# SSH
mkdir /var/tmp/embedux/image_setup/ssh_creds
echo | ssh-keygen -f /var/tmp/embedux/image_setup/ssh_creds/qemu.id
cp /var/tmp/embedux/image_setup/ssh_creds/qemu.id.pub ${FILES_DIR}/qemu-prepare/

#ROOT=/var/tmp/embedux/rootfs/ PORTAGE_CONFIGROOT=/var/tmp/embedux/rootfs/ flaggie app-emulation/docker +kw::~*
