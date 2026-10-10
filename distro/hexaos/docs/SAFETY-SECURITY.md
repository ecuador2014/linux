# Seguridad funcional y de acceso

> HEXAOS es software experimental sin certificación (ISO 13849, ISO 26262, DO-178C…). Un robot, dron o coche puede causar
> daños graves. Las pruebas se hacen con el vehículo sujeto/en banco, hélices fuera, ruedas elevadas y paro de emergencia físico.

## Seguridad funcional
- **Paro de emergencia por hardware** independiente de Linux (corte de potencia a actuadores). El software no lo sustituye.
- `FAILSAFE_CMD` se ejecuta solo si el supervisor detecta la caída de `CORE_CMD`; **no cubre cuelgues** (proceso vivo pero bloqueado).
  Añade un latido: el actuador/ECU debe detenerse si no recibe comandos en X ms.
- Watchdog: `watchdog` de BusyBox (periodo 5 s) con `NOWAYOUT`. Si el kernel se cuelga, el hardware reinicia; verifica que
  tu actuador queda en estado seguro durante el reinicio.
- **Dron:** el failsafe vive en el autopiloto (geofence, RTL, pérdida de enlace). **Coche:** define tu trama de frenado.
- Prueba cada fallo: mata `hexa-core`, desconecta CAN, satura la CPU, corta la red.

## Seguridad de acceso
- Consola: root **sin contraseña** (solo desarrollo). Producción: pon `BR2_TARGET_GENERIC_ROOT_PASSWD` con hash o desactiva getty.
- SSH: Dropbear con `-s` (solo claves). Instala la tuya con `HEXA_SSH_PUBKEY`.
- `mini`: el AP WiFi no arranca sin `AP_PASS` (deliberado); cambia la contraseña en cada unidad. Mosquitto escucha sin autenticación: configura usuarios/TLS antes de exponerlo.
- `automation`: cortafuegos nftables activo por defecto (`FW_*`); Modbus y MQTT básicos no cifran ni autentican: no los expongas fuera de la red OT.
- Red (otros perfiles): no hay firewall por defecto. Con `ROS_LOCALHOST_ONLY=0`, DDS queda sin autenticar: usa SROS2, VPN (WireGuard) o red aislada.
- MAVLink por UDP: sin firma por defecto; activa MAVLink 2 signing en el autopiloto.
- Actualizaciones: no hay OTA; reconstruye y reflashea. Revisa CVE del kernel/paquetes al subir de versión.
- Imagen de solo lectura + overlay en RAM recomendada para producción (no incluido todavía).
