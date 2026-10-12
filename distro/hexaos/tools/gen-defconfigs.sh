#!/bin/sh
# Genera configs/hexaos_<perfil>[_ros2][_gui]_<arch>_defconfig   (arch: x86_64 aarch64 arm rpi4) a partir de profiles/*.frag
#   _ros2: capa ROS 2 (glibc, no en arm 32 bits)   _gui: capa grafica Cage (solo x86_64/aarch64, sin ROS 2)
set -e
HERE=$(cd "$(dirname "$0")/.." && pwd)
P=$HERE/profiles
K='$(BR2_EXTERNAL_HEXAOS_PATH)/board/hexaos'
mkdir -p "$HERE/configs"; rm -f "$HERE"/configs/*_defconfig
for prof in humanoid drone car mini automation; do
 for arch in x86_64 aarch64 arm rpi4; do
  for layer in base ros2 gui; do
    [ $layer = ros2 ] && [ $arch = arm ] && continue    # ROS 2 no se ofrece en ARM 32 bits
    [ $layer = gui ]  && [ $arch = arm ] && continue    # la capa grafica no se ofrece en ARM 32 bits
    [ $layer != base ] && [ $arch = rpi4 ] && continue  # Raspberry Pi 4: solo la imagen base por ahora
    suf=; ov=; kf=; extra=; libc=musl
    case $layer in
      ros2) libc=glibc; suf=_ros2; size=2G;   ov="$K/overlay-ros2"; extra=ros2 ;;
      gui)  suf=_gui;  size=768M; ov="$K/overlay-gui"; kf="$K/linux-gui.fragment"; extra=gui ;;
      *)    size=512M; case $prof in mini) size=128M;; automation) size=256M;; esac ;;
    esac
    out=$HERE/configs/hexaos_${prof}${suf}_${arch}_defconfig
    overlays="$K/overlay-common $K/overlay-$prof${ov:+ $ov}"
    postbuild="$K/post-build.sh"; [ $arch = rpi4 ] && postbuild="board/raspberrypi4-64/post-build.sh $K/post-build.sh"
    {
      echo "# HEXAOS - perfil $prof, $arch, libc $libc, capa: $layer  (GENERADO por tools/gen-defconfigs.sh)"
      cat $P/arch-$arch.frag $P/libc-$libc.frag $P/base.frag $P/$prof.frag
      [ $arch != rpi4 ] && cat $P/kernel-mainline.frag   # rpi4 usa el kernel de la fundacion (arch-rpi4.frag)
      [ "$extra" = ros2 ] && { cat $P/ros2.frag; echo "BR2_PACKAGE_ROS2_RUNTIME_TARBALL=\"\$(BR2_EXTERNAL_HEXAOS_PATH)/ros2/output/${prof}_${arch}/ros2-install.tar.gz\""; }
      [ "$extra" = gui ] && cat $P/gui.frag
    } | sed -e "s#@HOST@#hexa-$prof#" -e "s#@PROFILE@#$prof#" -e "s#@SIZE@#$size#" \
            -e "s#@OVERLAYS@#$overlays#" -e "s#@POSTBUILD@#$postbuild#" -e "s#@KFRAGS@#$K/linux-base.fragment $K/linux-$prof.fragment${kf:+ $kf}#" > "$out"
  done
 done
done
ls "$HERE/configs" | wc -l
