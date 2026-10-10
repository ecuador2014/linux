# Referencia de configuración

## /etc/hexa/hexa.conf (común)
Carga `/etc/hexa/profile.conf` y define valores por defecto.

| Variable | Defecto | Descripción |
|---|---|---|
| `CORE_CMD` | `/opt/hexa/bin/hexa-core` | Proceso de control supervisado |
| `RT_CPUS` | `1` | CPUs (lista taskset) para `CORE_CMD`; vacío = sin afinidad |
| `RT_PRIO` | `80` | Prioridad `SCHED_FIFO` (1-99) |
| `FAILSAFE_CMD` | según perfil | Comando shell al caer/parar `CORE_CMD` |

## /etc/hexa/profile.conf (por perfil)
| Variable | Perfil | Descripción |
|---|---|---|
| `CAN_IFACES`, `CAN_BITRATE` | humanoid, car | Interfaces SocketCAN y bitrate |
| `PTP_IFACE` | car | NIC con PTP hardware |
| `FC_DEV`, `FC_BAUD`, `GCS_UDP` | drone | Puerto serie del autopiloto y destino UDP |
| `MCU_DEV`, `MCU_BAUD` | mini | Puerto serie al microcontrolador |
| `WIFI_IFACE`, `AP_SSID`, `AP_PASS`, `AP_ADDR` | mini | WiFi cliente/AP (AP solo si `AP_PASS` ≥ 8 caracteres) |

## /etc/hexa/ros2.conf (capa ROS 2)
`ROS_LAUNCH_ENABLE`, `ROS_DOMAIN_ID`, `RMW_IMPLEMENTATION`, `ROS_LOCALHOST_ONLY`, `ROS_LAUNCH_PKG`, `ROS_LAUNCH_FILE`,
`ROS_RT_CPUS`, `ROS_RT_PRIO`.

## Otros
- `/etc/sysctl.d/hexa.conf` : `sched_rt_runtime_us=-1`, buffers de red, reinicio tras panic.
- `/etc/default/dropbear`: `-s` (sin contraseñas).
- `/etc/hexa/ptp4l.conf` (car): PTP L2 por hardware.
- Cmdline del kernel recomendada: `isolcpus=<N> nohz_full=<N> rcu_nocbs=<N> threadirqs`.

## Compilación
`ARCH`, `ROS2`, `BUILDROOT_VERSION`, `HEXA_SSH_PUBKEY` (ver `build.sh`). Versión del kernel: `profiles/base.frag`
(`BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE`) y regenerar con `tools/gen-defconfigs.sh`.
