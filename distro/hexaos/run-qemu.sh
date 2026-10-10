#!/bin/sh
# Prueba en QEMU x86_64: ./run-qemu.sh <humanoid|drone|car|mini> [ros2]   (ssh -p 2222 root@localhost)
P=${1:?Uso: ./run-qemu.sh <humanoid|drone|car|mini> [ros2]}; [ "$2" = ros2 ] && P=${P}_ros2
IMG=$(dirname "$0")/output/${P}_x86_64/images
exec qemu-system-x86_64 -M pc -m 1024 -smp 2 -nographic \
  -kernel "$IMG/bzImage" -drive file="$IMG/rootfs.ext4",format=raw,if=virtio \
  -append "root=/dev/vda rw console=ttyS0 isolcpus=1 nohz_full=1 rcu_nocbs=1" \
  -nic user,hostfwd=tcp::2222-:22
