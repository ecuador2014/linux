#!/bin/sh
# Genera, a partir de los artefactos de Buildroot (x86_64):
#   hexaos-<perfil>-live.iso : ISO live hibrida BIOS+UEFI (el sistema corre en RAM)
#   hexaos-<perfil>.img      : imagen de disco para instalar (MBR; arranca por BIOS y por UEFI;
#                              particion de arranque FAT32 + particion raiz ext4 persistente)
# Uso: tools/make-images.sh <directorio images/> <perfil>
# Host (Debian/Ubuntu): sudo apt install grub-pc-bin grub-efi-amd64-bin xorriso mtools syslinux \
#                                         syslinux-common dosfstools fdisk e2fsprogs
# No necesita root.
set -e
IMG=${1:?Uso: $0 <directorio images/> <perfil>}
PROFILE=${2:?Uso: $0 <directorio images/> <perfil>}
IMG=$(cd "$IMG" && pwd)
ISO=$IMG/hexaos-$PROFILE-live.iso
DISK=$IMG/hexaos-$PROFILE.img
DISKID=48455841                       # "HEXA": identificador MBR; PARTUUID de la raiz = $DISKID-02
BOOT_MIB=64
LABEL=HEXABOOT
CMD_BASE="net.ifnames=0 loglevel=4"
# /dev/console = ultimo console=: login en monitor (tty0) o en serie (ttyS0)
CON_MON="console=ttyS0,115200 console=tty0"
CON_SER="console=tty0 console=ttyS0,115200"

for f in bzImage rootfs.cpio.gz rootfs.ext4; do
    [ -f "$IMG/$f" ] || { echo "Falta $IMG/$f (compila con build.sh; el defconfig x86_64 genera cpio y ext4)"; exit 1; }
done
for c in grub-mkrescue grub-mkstandalone xorriso mcopy mkfs.fat syslinux sfdisk dd truncate; do
    command -v "$c" >/dev/null || { echo "Falta '$c' (ver cabecera del script para los paquetes)"; exit 1; }
done
MBR=
for p in /usr/lib/syslinux/mbr/mbr.bin /usr/lib/SYSLINUX/mbr.bin /usr/share/syslinux/mbr.bin; do
    [ -f "$p" ] && MBR=$p && break
done
[ -n "$MBR" ] || { echo "No encuentro mbr.bin de syslinux (paquete syslinux-common)"; exit 1; }

W=$(mktemp -d); trap 'rm -rf "$W"' EXIT

# ---------- ISO live (BIOS + UEFI) ----------
mkdir -p "$W/iso/boot/grub"
cp "$IMG/bzImage" "$W/iso/boot/bzImage"
cp "$IMG/rootfs.cpio.gz" "$W/iso/boot/initrd.gz"
cat > "$W/iso/boot/grub/grub.cfg" <<CFG
set default=0
set timeout=5
menuentry "HEXAOS $PROFILE - live (monitor y teclado)" {
    linux /boot/bzImage $CMD_BASE $CON_MON
    initrd /boot/initrd.gz
}
menuentry "HEXAOS $PROFILE - live (consola serie ttyS0)" {
    linux /boot/bzImage $CMD_BASE $CON_SER
    initrd /boot/initrd.gz
}
CFG
grub-mkrescue -o "$ISO" "$W/iso" >/dev/null 2>&1
echo "ISO:  $ISO"

# ---------- Imagen de disco ----------
ROOT_BYTES=$(stat -c %s "$IMG/rootfs.ext4")
BOOT_START=2048                                   # sectores (1 MiB)
BOOT_SECT=$((BOOT_MIB * 2048))
ROOT_START=$((BOOT_START + BOOT_SECT))
TOTAL=$((ROOT_START + ROOT_BYTES / 512 + 2048))   # +1 MiB de margen
rm -f "$DISK"
truncate -s $((TOTAL * 512)) "$DISK"
sfdisk -q "$DISK" <<PT
label: dos
label-id: 0x$DISKID
unit: sectors
start=$BOOT_START, size=$BOOT_SECT, type=ef, bootable
start=$ROOT_START, type=83
PT
OFF=$((BOOT_START * 512))
mkfs.fat -F32 -n "$LABEL" --offset "$BOOT_START" "$DISK" $((BOOT_MIB * 1024)) >/dev/null 2>&1
M="$DISK@@$OFF"
mmd -i "$M" ::/EFI ::/EFI/BOOT
mcopy -i "$M" "$IMG/bzImage" ::/bzImage
ROOTARG="root=PARTUUID=$DISKID-02 rw rootwait $CMD_BASE"
cat > "$W/syslinux.cfg" <<CFG
DEFAULT monitor
PROMPT 1
TIMEOUT 30
LABEL monitor
  LINUX /bzImage
  APPEND $ROOTARG $CON_MON
LABEL serial
  LINUX /bzImage
  APPEND $ROOTARG $CON_SER
CFG
mcopy -i "$M" "$W/syslinux.cfg" ::/syslinux.cfg
cat > "$W/grub-embedded.cfg" <<CFG
set default=0
set timeout=3
search --no-floppy --label $LABEL --set=root
menuentry "HEXAOS $PROFILE (monitor y teclado)" {
    linux /bzImage $ROOTARG $CON_MON
}
menuentry "HEXAOS $PROFILE (consola serie ttyS0)" {
    linux /bzImage $ROOTARG $CON_SER
}
CFG
grub-mkstandalone -O x86_64-efi -o "$W/BOOTX64.EFI" \
    --modules="part_msdos part_gpt fat ext2 search search_label normal linux echo" \
    "boot/grub/grub.cfg=$W/grub-embedded.cfg" >/dev/null 2>&1
mcopy -i "$M" "$W/BOOTX64.EFI" ::/EFI/BOOT/BOOTX64.EFI
syslinux --offset "$OFF" --install "$DISK"                 # BIOS: sector de arranque + ldlinux
dd if="$MBR" of="$DISK" bs=440 count=1 conv=notrunc status=none   # BIOS: codigo MBR (no toca la tabla)
dd if="$IMG/rootfs.ext4" of="$DISK" bs=512 seek="$ROOT_START" conv=notrunc,sparse status=none
echo "DISK: $DISK  (grabar con: sudo dd if=$DISK of=/dev/sdX bs=4M status=progress conv=fsync)"
