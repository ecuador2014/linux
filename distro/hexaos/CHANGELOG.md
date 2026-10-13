# Changelog
## 0.1.0 — experimental
- Base Buildroot external tree `HEXAOS`; kernel 6.18.55 LTS `PREEMPT_RT`.
- Perfiles `humanoid`, `drone`, `car`, `mini`, `automation`; arquitecturas `x86_64`, `aarch64`, `arm` (genéricas).
- Perfil `automation`: Modbus, OPC UA, MQTT, RS-485, CAN, cortafuegos nftables por defecto.
- Perfil `mini` para robots pequeños: WiFi cliente/AP, MQTT, serie a MCU, imagen de 128 MB.
- Capa ROS 2 (Jazzy, Cyclone DDS) con compilación cruzada.
- Perfil `car`: un solo mecanismo de PTP (servicios del paquete `linuxptp`, configurados por `/etc/default`); se elimina `S25ptp`, que duplicaba `ptp4l`/`phc2sys` y arrancaba antes de la red.
- Raspberry Pi 4 (`ARCH=rpi4`): kernel de la fundación 6.12 con PREEMPT_RT, firmware, imagen de SD con genimage. Sin probar en placa real (`docs/RPI.md`).
- Validación de todos los defconfigs contra el kconfig de Buildroot 2025.02.1: corregidas opciones que no se aplicaban (`i2c-tools`, `kmod`, `v4l-utils`, C++ en musl, `PYYAML`, Mesa `swrast`); `rt-tests` solo existe con glibc.
- Capa gráfica opcional `GUI=1`: kiosco Wayland con Cage, usuario `kiosk` sin privilegios y panel de estado (`docs/GUI.md`). Sin probar con Buildroot.
- x86_64: ISO live (BIOS+UEFI) e imagen de disco `.img` por perfil (`tools/make-images.sh`); `run-qemu.sh` con `MODE=iso|img` y `UEFI=1`.
- Documentación y ejemplos. Sin compilar ni probar en hardware.
