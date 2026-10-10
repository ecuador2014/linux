# Portar a otras placas y crear perfiles

## Nueva placa (p. ej. Raspberry Pi 4/5, Orange Pi, i.MX)
Las configs `aarch64` son **genéricas** (kernel upstream `defconfig`, sin firmware ni DTB). Para una placa concreta:
1. Parte del defconfig oficial de Buildroot (`raspberrypi4_64_defconfig`, etc.) y copia: bootloader, firmware, DTB, `genimage`.
2. Conserva de HEXAOS: `BR2_ROOTFS_OVERLAY`, fragmentos de kernel (`BR2_LINUX_KERNEL_CONFIG_FRAGMENT_FILES`), paquetes.
3. Si la placa necesita kernel de fabricante (Raspberry Pi, Rockchip), puede no tener `PREEMPT_RT`: comprueba la rama RT.
4. Crea `profiles/arch-<placa>.frag` y añádela al bucle de `tools/gen-defconfigs.sh`.

## NVIDIA Jetson
Usa JetPack (L4T): no es Buildroot. Opciones: HEXAOS como sistema de control en otra placa y Jetson para percepción vía
Ethernet + ROS 2, o aplicar `overlay-*` y servicios sobre L4T (los scripts son POSIX `sh`).

## Nuevo perfil (p. ej. `rover`)
1. `profiles/rover.frag` (paquetes), `board/hexaos/linux-rover.fragment` (kernel), `board/hexaos/overlay-rover/etc/hexa/profile.conf`.
2. Añade `rover` al bucle `for prof in …` de `tools/gen-defconfigs.sh` y ejecútalo.
3. Documéntalo en `docs/PROFILES.md`.

## Otros buses
- **EtherCAT:** añade `ethercat` (IgH) o SOEM como paquete Buildroot propio en `package/`.
- **CAN FD:** ya habilitado en los drivers; configura `ip link set can0 type can bitrate … dbitrate … fd on`.
- **ROS 2 en ARM:** el SDK generado trae sysroot aarch64; `cross-build.sh` deduce la arquitectura del triplete.
