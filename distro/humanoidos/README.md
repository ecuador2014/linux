# HumanoidOS

Distro Linux ligera y de tiempo real para robots humanoides, como árbol externo de
[Buildroot](https://buildroot.org). Arranca en segundos y ocupa decenas de MB.

## Qué incluye
- Kernel 6.12 `PREEMPT_RT`, HZ=1000, `NO_HZ_FULL`, governor `performance`, sin depuración.
- Drivers de robot: SocketCAN (gs_usb, MCP251x, PEAK, Kvaser, slcan), GPIO, I2C, SPI, IIO, UVC, audio USB, watchdog.
- Userland BusyBox + eudev, musl (o glibc con ROS 2), SSH Dropbear (solo claves), chrony, can-utils, libgpiod, i2c/spi-tools, rt-tests, Python 3.
- Servicios: `S05rt-tune` (IRQ/governor), `S20can` (CAN), `S90robot` (supervisor de `/opt/robot/bin/robot-core` con SCHED_FIFO + e-stop CAN si cae), `S91ros2`.
- Configuración en `/etc/robot/robot.conf` y `/etc/robot/ros2.conf`.

## Compilar
```sh
HUMANOID_SSH_PUBKEY=~/.ssh/id_ed25519.pub ./build.sh              # sin ROS 2 (musl, mínima)
./run-qemu.sh                                                       # prueba; ssh -p 2222 root@localhost
```
Para Raspberry Pi / Jetson: copia `configs/humanoidos_x86_64_defconfig`, cambia arquitectura y kernel
(p.ej. base de `raspberrypi4_64_defconfig` de Buildroot) y reutiliza `board/humanoidos/`.

## ROS 2 (Jazzy, Cyclone DDS)
ROS 2 no está en Buildroot ni soporta musl, así que se integra como capa precompilada:
```sh
./build.sh humanoidos_ros2_x86_64_defconfig   # falla al final si falta el tarball: es normal la 1ª vez
make -C .buildroot-* O=$PWD/output sdk        # genera el toolchain/sysroot cruzado
./ros2/cross-build.sh                         # host Ubuntu 24.04 con colcon+vcstool -> ros2/output/ros2-install.tar.gz
./build.sh humanoidos_ros2_x86_64_defconfig   # el paquete ros2-runtime instala el árbol en /opt/ros
```
En el robot, `S91ros2` hace `ros2 launch $ROS_LAUNCH_PKG $ROS_LAUNCH_FILE` (por defecto `humanoid_bringup`),
fijado a `ROS_RT_CPUS` con prioridad RT. Añade tus paquetes (p.ej. `ros2_control`, `humanoid_bringup`) al workspace
de `cross-build.sh` antes de compilar. Cyclone DDS se configura en `/etc/robot/cyclonedds.xml` (solo loopback por defecto).

## Estado
Sintaxis de scripts verificada (`sh -n`), pero **no se ha compilado la imagen** (sin red/tiempo de build en esta sesión).
Es probable que haya que ajustar nombres de opciones de Buildroot, la versión de Buildroot/kernel y, sobre todo, la
compilación cruzada de ROS 2. Seguridad: el root de consola no tiene contraseña (solo desarrollo) — cámbiala en producción.
