#!/bin/sh
# Prueba en QEMU x86_64: [MODE=kernel|iso|img] [UEFI=1] ./run-qemu.sh <perfil> [ros2|gui]   (ssh -p 2222 root@localhost)
#   gui: abre una ventana de QEMU con el kiosco (GPU virtio); la consola serie sigue en esta terminal
#   MODE=kernel (defecto): bzImage + rootfs.ext4, en esta terminal (Ctrl+A X para salir)
#   MODE=iso / MODE=img: ISO live / imagen de disco; abren una ventana de QEMU (login en el monitor)
P=${1:?Uso: ./run-qemu.sh <humanoid|drone|car|mini|automation> [ros2|gui]}
GFX=; case "$2" in ros2) P=${P}_ros2 ;; gui) P=${P}_gui; GFX="-vga virtio -serial mon:stdio" ;; esac
IMG=$(dirname "$0")/output/${P}_x86_64/images
BIOS=; [ "$UEFI" = 1 ] && for f in /usr/share/ovmf/OVMF.fd /usr/share/OVMF/OVMF.fd; do [ -f "$f" ] && BIOS="-bios $f" && break; done
COMMON="-M pc -m 1024 -smp 2 -nic user,hostfwd=tcp::2222-:22"
case "${MODE:-kernel}" in
  kernel) exec qemu-system-x86_64 $COMMON ${GFX:--nographic} $BIOS -kernel "$IMG/bzImage" \
            -drive file="$IMG/rootfs.ext4",format=raw,if=virtio \
            -append "root=/dev/vda rw console=ttyS0 isolcpus=1 nohz_full=1 rcu_nocbs=1 net.ifnames=0" ;;
  iso)    exec qemu-system-x86_64 $COMMON ${GFX} $BIOS -cdrom "$IMG/hexaos-$P-live.iso" -boot d ;;
  img)    exec qemu-system-x86_64 $COMMON ${GFX} $BIOS -drive file="$IMG/hexaos-$P.img",format=raw,if=virtio ;;
  *) echo "MODE debe ser kernel, iso o img"; exit 1 ;;
esac
