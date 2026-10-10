# Arquitectura

HEXAOS es un **árbol externo de Buildroot** (`BR2_EXTERNAL`): no copia Buildroot, solo añade configuración.

```
hexaos/
├── external.desc / external.mk / Config.in   # registro del árbol externo (nombre HEXAOS)
├── package/ros2-runtime/                     # paquete Buildroot: instala el árbol ROS 2 en /opt/ros
├── profiles/*.frag                           # piezas de defconfig: arch, libc, base, perfil, ros2
├── tools/gen-defconfigs.sh                   # compone profiles/ -> configs/ (defconfigs)
├── configs/                                  # defconfigs GENERADOS (no editar a mano)
├── board/hexaos/
│   ├── linux-{base,humanoid,drone,car,mini,automation}.fragment   # opciones de kernel
│   ├── overlay-common/    # RT-tuning, CAN, supervisor, sysctl, SSH
│   ├── overlay-<perfil>/  # profile.conf + servicios específicos
│   ├── overlay-ros2/      # ros2.conf, cyclonedds.xml, S91ros2, profile.d
│   └── post-build.sh      # permisos + clave SSH
├── ros2/cross-build.sh                       # compila ROS 2 con el SDK de Buildroot
├── docs/  examples/  build.sh  run-qemu.sh
```

## Composición de una imagen
`defconfig = arch + libc + base + perfil [+ ros2]`, overlays `common → perfil → ros2` (el último pisa al anterior),
kernel = `defconfig de arquitectura + linux-base + linux-<perfil>`. ROS 2 fuerza glibc (musl en el resto) y rootfs de 2 GB.

## Arranque
BusyBox init ejecuta `/etc/init.d/S*` en orden:

| Script | Función |
|---|---|
| `S05rt-tune` | governor `performance`, sysctl RT, IRQs a CPU0 |
| `S20can` | levanta `CAN_IFACES` a `CAN_BITRATE` |
| `S25mavlink` (drone) | puente MAVLink serie ↔ UDP |
| `S25ptp` (car) | `ptp4l` + `phc2sys` |
| `S10firewall` (automation) | nftables, entrada denegada por defecto |
| `S30mosquitto-conf` (automation) | MQTT seguro por defecto |
| `S30wifi` (mini) | WiFi cliente o AP de configuración |
| `S50dropbear` | SSH solo clave |
| `S90hexa-core` | supervisor de `CORE_CMD` + failsafe |
| `S91ros2` (ros2) | `ros2 launch` con prioridad RT + failsafe |

## Decisiones de diseño
- **Buildroot sobre Yocto/Debian:** imagen pequeña, build reproducible, rápido de iterar; coste: sin gestor de paquetes en el robot.
- **PREEMPT_RT mainline** (≥ 6.12): sin parches externos.
- **Perfiles por composición:** añadir un perfil = un `.frag`, un `linux-*.fragment` y un overlay (ver PORTING.md).
