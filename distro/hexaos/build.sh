#!/bin/sh
# Uso: [ROS2=1] [ARCH=x86_64|aarch64|arm] ./build.sh <humanoid|drone|car|mini|automation>   (arm: sin ROS 2)
# Variables: BUILDROOT_VERSION, HEXA_SSH_PUBKEY (ruta a tu clave .pub)
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
PROFILE=${1:?Uso: ./build.sh <humanoid|drone|car|mini|automation>}
ARCH=${ARCH:-x86_64}
SUF=; [ "${ROS2:-0}" = 1 ] && SUF=_ros2
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
