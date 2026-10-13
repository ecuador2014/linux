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
| "Waiting for interface eth0 ... timeout" al arrancar | udev renombró la NIC (`enpXsY`). La imagen enmascara el renombrado (`80-net-name-slot.rules`) y `run-qemu.sh` pasa `net.ifnames=0`; en hardware real añade `net.ifnames=0` a la cmdline si usas otro overlay |
| `build.sh`: "no se generaron la ISO ni el .img" | Instala las dependencias de `tools/make-images.sh` (grub-pc-bin, grub-efi-amd64-bin, xorriso, mtools, syslinux, syslinux-common, dosfstools, fdisk) y ejecútalo a mano |
| La ISO/.img arranca pero no veo el login | Entrada de menú equivocada: "monitor" para pantalla y teclado, "serie" para ttyS0 |
| `GUI=1`: pantalla negra o sin kiosco | Comprueba `ls /dev/dri` (debe existir `card0`), `logread`/`dmesg`, `/var/log/seatd.log` y prueba `KIOSK_RENDERER=pixman`; en QEMU usa `./run-qemu.sh <perfil> gui` |
| La imagen no trae `cyclictest` | `rt-tests` no existe con musl; usa una variante glibc (`ROS2=1`) o compila la distro con glibc |
| `car`: `ptp4l` no sincroniza (QEMU o NIC sin PTP) | Necesita una NIC con sellado de tiempo por hardware (`ethtool -T eth0`); en QEMU (e1000) `ptp4l` no puede funcionar. Con tiempo por software cambia `time_stamping` en `/etc/hexa/ptp4l.conf` |
| aarch64 no arranca en la placa | Las configs genéricas no incluyen bootloader/DTB: `docs/PORTING.md` |
