#!/bin/sh
# Uso: ./build.sh [defconfig]   (por defecto humanoidos_x86_64_defconfig)
# Variables: BUILDROOT_VERSION, HUMANOID_SSH_PUBKEY (ruta a tu id_ed25519.pub)
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
BR_VER=${BUILDROOT_VERSION:-2025.02.1}
DEFCONFIG=${1:-humanoidos_x86_64_defconfig}
BR_DIR=$HERE/.buildroot-$BR_VER
OUT=$HERE/output

if [ ! -d "$BR_DIR" ]; then
    curl -fL "https://buildroot.org/downloads/buildroot-$BR_VER.tar.xz" | tar -xJ -C "$HERE"
    mv "$HERE/buildroot-$BR_VER" "$BR_DIR"
fi
make -C "$BR_DIR" O="$OUT" BR2_EXTERNAL="$HERE" "$DEFCONFIG"
make -C "$BR_DIR" O="$OUT" -j"$(nproc)"
echo "Listo: $OUT/images/"
