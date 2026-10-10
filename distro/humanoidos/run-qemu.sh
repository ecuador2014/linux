#!/bin/sh
# Prueba rapida en QEMU (necesita imagenes generadas por build.sh)
IMG=$(dirname "$0")/output/images
exec qemu-system-x86_64 -M pc -m 512 -smp 2 -nographic \
  -kernel "$IMG/bzImage" -drive file="$IMG/rootfs.ext4",format=raw,if=virtio \
  -append "root=/dev/vda rw console=ttyS0 isolcpus=1 nohz_full=1 rcu_nocbs=1" \
  -nic user,hostfwd=tcp::2222-:22
