#!/bin/bash
set -eou

### Install Docker

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

### Set up disks
MNT_DIR=/op-geth
sudo apt update && sudo apt install mdadm --no-install-recommends
sudo mdadm --create /dev/md0 --level=0 --raid-devices=8 \
 /dev/disk/by-id/google-local-nvme-ssd-0 \
 /dev/disk/by-id/google-local-nvme-ssd-1 \
 /dev/disk/by-id/google-local-nvme-ssd-2 \
 /dev/disk/by-id/google-local-nvme-ssd-3 \
 /dev/disk/by-id/google-local-nvme-ssd-4 \
 /dev/disk/by-id/google-local-nvme-ssd-5 \
 /dev/disk/by-id/google-local-nvme-ssd-6 \
 /dev/disk/by-id/google-local-nvme-ssd-7
sudo mkfs.ext4 -F /dev/md0
sudo mkdir -p /mnt/disks/$MNT_DIR
sudo mount /dev/md0 /mnt/disks/$MNT_DIR
sudo chmod a+w /mnt/disks/$MNT_DIR
UUID=$(sudo blkid -s UUID -o value /dev/md0)
echo "UUID=$UUID /mnt/disks/$MNT_DIR ext4 discard,defaults,nofail 0 2" | sudo tee -a /etc/fstab