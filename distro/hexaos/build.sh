#!/bin/sh
# Uso: [ROS2=1 | GUI=1] [ARCH=x86_64|aarch64|arm|rpi4] ./build.sh <humanoid|drone|car|mini|automation>
#   ROS2=1: capa ROS 2 (no en arm)   GUI=1: capa grafica Cage (solo x86_64/aarch64; no se combina con ROS2)
# Variables: BUILDROOT_VERSION, HEXA_SSH_PUBKEY (ruta a tu clave .pub)
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
PROFILE=${1:?Uso: ./build.sh <humanoid|drone|car|mini|automation>}
ARCH=${ARCH:-x86_64}
SUF=; [ "${ROS2:-0}" = 1 ] && SUF=_ros2
if [ "${GUI:-0}" = 1 ]; then
    [ -n "$SUF" ] && { echo "GUI=1 y ROS2=1 todavia no se pueden combinar"; exit 1; }
    SUF=_gui
fi
DEFCONFIG=hexaos_${PROFILE}${SUF}_${ARCH}_defconfig
BR_VER=${BUILDROOT_VERSION:-2025.02.1}
BR_DIR=$HERE/.buildroot-$BR_VER
OUT=$HERE/output/$PROFILE${SUF}_$ARCH

[ -f "$HERE/configs/$DEFCONFIG" ] || { echo "No existe configs/$DEFCONFIG (ejecuta tools/gen-defconfigs.sh)"; exit 1; }
if [ ! -d "$BR_DIR" ]; then
    curl -fL "https://buildroot.org/downloads/buildroot-$BR_VER.tar.xz" | tar -xJ -C "$HERE"
    mv "$HERE/buildroot-$BR_VER" "$BR_DIR"
fi
make -C "$BR_DIR" O="$OUT" BR2_EXTERNAL="$HERE" "$DEFCONFIG"
make -C "$BR_DIR" O="$OUT" -j"$(nproc)"
echo "Listo: $OUT/images/"
if [ "$ARCH" = x86_64 ]; then
    "$HERE/tools/make-images.sh" "$OUT/images" "$PROFILE${SUF}" || \
        echo "Aviso: no se generaron la ISO ni el .img (ver dependencias en tools/make-images.sh); bzImage y rootfs.ext4 siguen disponibles"
fi
if [ "$ARCH" = rpi4 ]; then
    echo "Imagen de tarjeta SD: $OUT/images/sdcard.img   (grabar: sudo dd if=... of=/dev/sdX bs=4M conv=fsync)"
fi
