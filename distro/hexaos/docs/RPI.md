# Raspberry Pi 4 (aarch64)

Configuración para **Raspberry Pi 4 B, Pi 400 y Compute Module 4/4S** (`ARCH=rpi4`), basada en `raspberrypi4_64_defconfig` de Buildroot 2025.02:
kernel de la fundación Raspberry Pi (rama `rpi-6.12.y`, commit fijado, con `PREEMPT_RT`), firmware oficial, árbol de dispositivos y una
imagen de tarjeta SD (`sdcard.img`) con arranque FAT32 de 64 MB y raíz ext4.

> **Estado: sin probar en una placa real.** Los nombres de opciones se validaron contra el kconfig de Buildroot 2025.02.1 (todas se aplican),
> pero la imagen no se ha compilado ni arrancado. Pi 5, Pi 3 y Zero 2 W no están soportadas todavía.

## Compilar
```sh
HEXA_SSH_PUBKEY=~/.ssh/id_ed25519.pub ARCH=rpi4 ./build.sh mini        # o humanoid, drone, car, automation
ls -lh output/mini_rpi4/images/sdcard.img
```
Solo la imagen base (sin ROS 2 ni capa gráfica). Dependencias del host: las de [GETTING-STARTED](GETTING-STARTED.md).
El kernel se descarga de `github.com/raspberrypi/linux` (sin comprobación de hash).

## Grabar la tarjeta
```sh
# ¡Comprueba bien /dev/sdX: se borra todo!
sudo dd if=output/mini_rpi4/images/sdcard.img of=/dev/sdX bs=4M status=progress conv=fsync
```
También sirve **Raspberry Pi Imager → "Usar personalizado"** o balenaEtcher. La Pi 4 necesita el bootloader (EEPROM) reciente para arrancar de SD:
si tu placa es antigua, actualízalo una vez con Raspberry Pi OS.

## Primer arranque
- **Consola serie (recomendada):** adaptador USB-UART de 3,3 V en GPIO14 (TXD, pin 8), GPIO15 (RXD, pin 10) y GND (pin 6); 115200 baudios.
  Usuario `root`, sin contraseña (solo desarrollo).
- **Red:** Ethernet por DHCP (`eth0`). SSH solo con clave: instálala al compilar con `HEXA_SSH_PUBKEY`.
- **Wi-Fi y Bluetooth:** el firmware del chip de la Pi 4 viene incluido (`wlan0`). Con el perfil `mini`, `S30wifi` conecta como cliente si existe
  `/etc/wpa_supplicant.conf` o crea un punto de acceso si defines `AP_PASS`. No hay pila Bluetooth (BlueZ).
- **HDMI:** la imagen no incluye driver gráfico (DRM), así que la pantalla puede quedar en negro: usa serie o SSH.

## Ajustes en la partición de arranque
La partición `boot` (FAT32) se puede editar desde cualquier PC antes de arrancar:
- `config.txt`: descomenta las líneas de **CAN** para una placa MCP2515 por SPI (`dtparam=spi=on` y `dtoverlay=mcp2515-can0,...`; ajusta
  `oscillator` e `interrupt` a tu placa) y, si quieres baja latencia, `force_turbo=1`. Perfiles con CAN (`humanoid`, `car`): `can0` aparece al cargar el overlay.
- `cmdline.txt`: añade `isolcpus=1 nohz_full=1 rcu_nocbs=1` (la CPU debe coincidir con `RT_CPUS` de `/etc/hexa/profile.conf`).

## Tiempo real
El kernel se compila con `PREEMPT_RT`, pero **no se ha medido la latencia en la Pi**. Los controladores de USB, Wi-Fi y el firmware pueden añadir jitter;
mide con `cyclictest` (necesita una imagen glibc, ver [REALTIME.md](REALTIME.md)) antes de fiarte de ella.

## Límites conocidos
- Sin probar en hardware; el kernel descargado no se verifica con hash.
- Sin capa gráfica ni ROS 2 para `rpi4`; Pi 5 (otro SoC, otro kernel y firmware) no soportada.
- Imágenes con musl: no incluyen `rt-tests` (`cyclictest`).
