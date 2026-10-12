# Capa gráfica: kiosco Wayland (Cage)

Un **kiosco** muestra **una sola aplicación a pantalla completa**: sin escritorio, sin barra de tareas, sin ventanas.
HEXAOS usa **Cage** (un compositor Wayland mínimo) y, por defecto, un **panel de estado** del sistema.

```
arranque → kernel RT → servicios (CAN, ROS 2...) → seatd → Cage → tu aplicación a pantalla completa
```

## Compilar y probar
```sh
GUI=1 ./build.sh humanoid                     # perfil + capa gráfica (x86_64 y aarch64; no se combina aún con ROS2=1)
GUI=1 ARCH=aarch64 ./build.sh mini
./run-qemu.sh humanoid gui                    # abre una ventana de QEMU con el kiosco; la consola serie sigue en la terminal
MODE=iso ./run-qemu.sh humanoid gui           # también con la ISO live o la imagen de disco (MODE=img)
```
La imagen crece unos 100-250 MB (Mesa, Wayland, Cage, la terminal `foot` y fuentes). El `rootfs.ext4` pasa a 768 MB.

## Qué incluye
- **Kernel:** DRM/KMS, `virtio-gpu`, `simpledrm`, consola de framebuffer y entrada (teclado, ratón, táctil, USB HID).
- **Pila gráfica:** Wayland, Mesa (`softpipe` por CPU y `virgl` para QEMU), `libinput`, `seatd`, `xkeyboard-config`, fuente DejaVu.
- **Cage** como usuario **`kiosk`** sin privilegios (grupos `video` e `input`, sin contraseña). La consola de root sigue en el puerto serie.
- **`hexa-panel`:** panel de estado (kernel, uptime, carga, memoria, temperatura, red, CAN y si corre `hexa-core`).
- **Servicio** `S60kiosk`: espera a `/dev/dri/card0`, arranca `seatd` y Cage y lo reinicia si cae.

## Configuración (`/etc/hexa/kiosk.conf`)
| Variable | Defecto | Descripción |
|---|---|---|
| `KIOSK_ENABLE` | `1` | `0` desactiva el kiosco |
| `KIOSK_CMD` | `foot /opt/hexa/bin/hexa-panel` | Aplicación que se muestra |
| `KIOSK_RENDERER` | `pixman` | `pixman` = por CPU (funciona sin GPU y en QEMU); `gles2` = acelerado, necesita el driver Mesa de tu GPU |

Para mostrar **tu propia aplicación**, cambia `KIOSK_CMD` (cualquier cliente Wayland: Qt con el plugin `wayland`, GTK, un navegador en modo kiosco...)
e inclúyela en la imagen. Cage la abre a pantalla completa; las ventanas emergentes y cuadros de diálogo se muestran encima.

## Tiempo real
La interfaz no debe interferir con el control. Reserva CPUs para el lazo de control (`RT_CPUS`, `isolcpus`) y deja la parte gráfica en las demás.
Evita los drivers de GPU propietarios con `PREEMPT_RT`: pueden añadir latencia.

## Límites actuales
- **Sin probar en una imagen real**: la secuencia Cage + `foot` + panel se verificó en un contenedor con los paquetes de Ubuntu, con
  un backend sin pantalla. La compilación de la capa con Buildroot y el arranque en QEMU/hardware están pendientes.
- **Sin aceleración para tu GPU concreta:** solo `softpipe` y `virgl`; añade los drivers de Mesa que necesites (Intel `iris`, AMD `radeonsi`, Pi `vc4`/`v3d`, etc.).
- `GUI=1` no se puede combinar con `ROS2=1`, y no existe en ARM de 32 bits.
- **Es un kiosco, no un escritorio:** no hay ventanas, menú ni gestor de archivos.
