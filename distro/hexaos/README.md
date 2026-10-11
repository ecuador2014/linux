# HEXAOS

Distro Linux ligera y de **tiempo real** para robótica móvil. Una base común y cinco perfiles:

| Perfil | Para | Bus principal | Extras |
|---|---|---|---|
| `humanoid` | Humanoides, brazos, cuadrúpedos | CAN 1 Mbit/s | audio, joystick, cámaras |
| `drone` | Computador de a bordo de dron (PX4/ArduPilot) | UART MAVLink | gpsd, GStreamer, WiFi, PWM |
| `car` | Vehículos autónomos / AGV / rovers | CAN 500 kbit/s | PTP (lidar/cámaras), gpsd, Ethernet |
| `automation` | Pasarelas y controladores industriales / edificios / IoT | Modbus, RS-485, MQTT, OPC UA, CAN, GPIO | cortafuegos nftables, 1-Wire |
| `mini` | Robots pequeños: Pi Zero/3/4, rovers, brazos, seguidores de línea (rootfs 128 MB) | GPIO/I2C + serie a Arduino/ESP32 | WiFi cliente/AP, MQTT, Bluetooth, 1-Wire |

Todos incluyen kernel 6.18 LTS `PREEMPT_RT`, BusyBox, SSH solo con claves y herramientas de diagnóstico.
Cada perfil tiene variante **ROS 2** (Jazzy + Cyclone DDS) y arquitecturas `x86_64`, `aarch64` y `arm` (32 bits, ARMv7; solo sin ROS 2).

```sh
./tools/gen-defconfigs.sh                 # (re)genera configs/ — ya vienen generadas
HEXA_SSH_PUBKEY=~/.ssh/id_ed25519.pub ./build.sh humanoid          # mínima (musl); en x86_64 genera además ISO live e .img de disco
ROS2=1 ARCH=aarch64 ./build.sh drone                                # con ROS 2, ARM64
ARCH=arm ./build.sh mini                                            # robot pequeño ARMv7, sin ROS 2
./run-qemu.sh humanoid                                              # prueba x86_64 en QEMU
```

## Documentación
| Documento | Contenido |
|---|---|
| [docs/GETTING-STARTED.md](docs/GETTING-STARTED.md) | Primer arranque en 10 minutos |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Estructura del árbol, capas, cómo se genera una imagen |
| [docs/PROFILES.md](docs/PROFILES.md) | Humanoide, dron, coche: hardware, buses, proyectos típicos |
| [docs/ROS2.md](docs/ROS2.md) | Capa ROS 2: compilación cruzada, DDS, launch, micro-ROS |
| [docs/CONFIGURATION.md](docs/CONFIGURATION.md) | Referencia de `/etc/hexa/*`, servicios y variables |
| [docs/REALTIME.md](docs/REALTIME.md) | Ajuste y medición de latencia (cyclictest) |
| [docs/SAFETY-SECURITY.md](docs/SAFETY-SECURITY.md) | Seguridad funcional y de acceso: léelo antes de mover un actuador |
| [docs/PORTING.md](docs/PORTING.md) | Raspberry Pi, Jetson, otras placas; nuevos perfiles |
| [docs/PROJECTS.md](docs/PROJECTS.md) | Recetas para proyectos concretos |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Problemas frecuentes |
| [CONTRIBUTING.md](CONTRIBUTING.md), [CHANGELOG.md](CHANGELOG.md) | Colaboración e historial |
| [examples/](examples/) | `hexa-core` en Python (SocketCAN) y paquete ROS 2 `hexa_bringup` |

## Estado
Versión 0.1 (experimental). Los scripts pasan comprobación de sintaxis, pero **la imagen no ha sido compilada ni probada
en hardware**. Ver [CHANGELOG.md](CHANGELOG.md). **No uses HEXAOS en un vehículo o robot real sin leer
[docs/SAFETY-SECURITY.md](docs/SAFETY-SECURITY.md).**

## Licencia
Los archivos propios de HEXAOS se publican bajo GPL-2.0-only (como el kernel); Buildroot y los paquetes mantienen sus licencias.
