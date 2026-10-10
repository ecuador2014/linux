# Problemas frecuentes

| Síntoma | Causa / solución |
|---|---|
| `build.sh`: "No existe configs/…" | Ejecuta `tools/gen-defconfigs.sh`; revisa `ARCH`/`ROS2` |
| Error "Falta el tarball de ROS 2" | Normal en el 1er build ROS 2: sigue `docs/ROS2.md` |
| Opción de Buildroot desconocida | Cambia `BUILDROOT_VERSION` o ajusta el `.frag`; ejecuta `make menuconfig` en `output/<…>` y `make savedefconfig` |
| `CONFIG_PREEMPT_RT` no se aplica | Falta `EXPERT`/arch sin soporte RT; revisa `output/…/build/linux-*/.config` |
| `can0` no existe | Falta driver/adaptador: `dmesg | grep -i can`; `ip link` |
| `RTNETLINK: Operation not supported` en `ip link set can0 type can` | La interfaz no es CAN (p. ej. vcan: crea sin bitrate) |
| Latencia alta | Ver `docs/REALTIME.md` (isolcpus, SMI, governor) |
| SSH rechaza | Instala clave con `HEXA_SSH_PUBKEY` y reconstruye; no hay login por contraseña |
| `ros2: command not found` | `. /etc/profile.d/ros2.sh`; verifica `/opt/ros/setup.sh` |
| `mini`: el AP WiFi no aparece | Define `AP_PASS` (≥ 8 caracteres) y que no exista `network=` en `/etc/wpa_supplicant.conf`; mira `logread` |
| `automation`: no conecta a 502/1883 | Revisa `FW_TCP_PORTS`/`FW_ALLOW_CIDR` y `nft list ruleset`; sin passwd MQTT solo escucha en localhost |
| aarch64 no arranca en la placa | Las configs genéricas no incluyen bootloader/DTB: `docs/PORTING.md` |
