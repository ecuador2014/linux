#!/bin/sh
# Genera configs/hexaos_<perfil>[_ros2]_<arch>_defconfig a partir de profiles/*.frag
set -e
HERE=$(cd "$(dirname "$0")/.." && pwd)
P=$HERE/profiles
K='$(BR2_EXTERNAL_HEXAOS_PATH)/board/hexaos'
mkdir -p "$HERE/configs"; rm -f "$HERE"/configs/*_defconfig
for prof in humanoid drone car mini; do
 for arch in x86_64 aarch64 arm; do
  for ros in no yes; do
    [ $ros = yes ] && [ $arch = arm ] && continue   # ROS 2 no se ofrece en ARM 32 bits
    if [ $ros = yes ]; then libc=glibc; suf=_ros2; size=2G; ov="$K/overlay-ros2"; else libc=musl; suf=; size=512M; ov=; fi
    [ $prof = mini ] && [ $ros = no ] && size=128M
    out=$HERE/configs/hexaos_${prof}${suf}_${arch}_defconfig
    overlays="$K/overlay-common $K/overlay-$prof${ov:+ $ov}"
    {
      echo "# HEXAOS - perfil $prof, $arch, libc $libc, ROS 2: $ros  (GENERADO por tools/gen-defconfigs.sh)"
      cat $P/arch-$arch.frag $P/libc-$libc.frag $P/base.frag $P/$prof.frag
      [ $ros = yes ] && { cat $P/ros2.frag; echo "BR2_PACKAGE_ROS2_RUNTIME_TARBALL=\"\$(BR2_EXTERNAL_HEXAOS_PATH)/ros2/output/${prof}_${arch}/ros2-install.tar.gz\""; }
    } | sed -e "s#@HOST@#hexa-$prof#" -e "s#@PROFILE@#$prof#" -e "s#@SIZE@#$size#" \
            -e "s#@OVERLAYS@#$overlays#" -e "s#@KFRAGS@#$K/linux-base.fragment $K/linux-$prof.fragment#" > "$out"
  done
 done
done
ls "$HERE/configs"
