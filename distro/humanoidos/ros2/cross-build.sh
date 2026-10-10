#!/bin/bash
# Compila ROS 2 (ros_base, solo Cyclone DDS) para el rootfs de HumanoidOS.
# Requisitos en el host: Ubuntu 24.04 + ROS_DISTRO jazzy, colcon, vcstool, cmake, python3-numpy.
# Uso: ver README.md, seccion "ROS 2"
#      ./ros2/cross-build.sh
# NOTA: la compilacion cruzada de ROS 2 es delicada; ajusta ros2.repos / ignores segun tu version.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
ROS_DISTRO=${ROS_DISTRO:-jazzy}
SDK_TGZ=$(ls "$HERE"/../output/images/*_sdk-buildroot.tar.gz | head -1)
WS=$HERE/ws
OUT=$HERE/output
mkdir -p "$WS/src" "$OUT" "$HERE/sdk"
[ -d "$HERE/sdk/bin" ] || { tar -xzf "$SDK_TGZ" -C "$HERE/sdk" --strip-components=1; "$HERE/sdk/relocate-sdk.sh"; }
SYSROOT=$(echo "$HERE"/sdk/*/sysroot)
TC=$(ls -d "$HERE"/sdk/bin/*-gcc | head -1); TRIPLE=$(basename "$TC" -gcc)

cat > "$HERE/toolchain.cmake" <<TCEOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER   $HERE/sdk/bin/$TRIPLE-gcc)
set(CMAKE_CXX_COMPILER $HERE/sdk/bin/$TRIPLE-g++)
set(CMAKE_SYSROOT $SYSROOT)
set(CMAKE_FIND_ROOT_PATH $SYSROOT)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
TCEOF

cd "$WS"
[ -f src/.imported ] || {
  curl -fL "https://raw.githubusercontent.com/ros2/ros2/$ROS_DISTRO/ros2.repos" -o ros2.repos
  vcs import src < ros2.repos && touch src/.imported
}
# Sin simulacion, GUI, ni FastDDS/ConnextDDS: solo Cyclone DDS
for p in rviz rqt ros_gz gz_ros2_control tlsf_cpp rmw_fastrtps rmw_connextdds fastrtps fastcdr; do
  find src -maxdepth 3 -type d -name "$p*" -exec touch {}/COLCON_IGNORE \;
done

colcon build --merge-install --install-base "$WS/install" \
  --packages-up-to ros_base \
  --cmake-args -DCMAKE_TOOLCHAIN_FILE="$HERE/toolchain.cmake" -DBUILD_TESTING=OFF \
               -DCMAKE_BUILD_TYPE=Release -DTHIRDPARTY_Asio=ON -DCMAKE_STRIP=$HERE/sdk/bin/$TRIPLE-strip

tar -czf "$OUT/ros2-install.tar.gz" -C "$WS/install" .
echo "Listo: $OUT/ros2-install.tar.gz"
