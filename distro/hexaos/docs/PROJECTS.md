# Recetas de proyectos

## Humanoide: control de articulaciones por CAN (sin ROS)
1. Copia `examples/hexa-core-python/hexa_core.py` a `board/hexaos/overlay-humanoid/opt/hexa/bin/hexa-core` y adapta IDs/escala.
2. `candump can0` para ver tráfico; `cansend can0 123#DEADBEEF` para pruebas; `ip -details link show can0` para errores.
3. Con IMU I2C: `i2cdetect -y 1`; lee con `/dev/i2c-1` o IIO (`/sys/bus/iio`).

## Humanoide con ROS 2 y ros2_control
Compila con `ROS2=1`; coloca tu `hexa_bringup` (ver `examples/hexa_bringup`) y el hardware interface CAN en el workspace.
`S91ros2` lanza `robot.launch.py`.

## Dron: companion + PX4
```sh
# En el dron (imagen drone + ROS2=1)
MicroXRCEAgent serial --dev /dev/ttyAMA0 -b 921600    # agente micro-XRCE-DDS (añádelo al workspace)
ros2 topic list                                       # /fmu/out/...
```
Cámara a tierra: `gst-launch-1.0 v4l2src ! videoconvert ! x264enc tune=zerolatency ! rtph264pay ! udpsink host=<IP> port=5600`.
Configura en PX4: `MAV_1_CONFIG`/`UXRCE_DDS_CFG` hacia el puerto usado.

## Coche autónomo / rover
- Sincroniza sensores: `PTP_IFACE` y `ptp4l`; comprueba con `pmc -u -b 0 'GET CURRENT_DATA_SET'`.
- GNSS: `gpsd -n /dev/ttyACM0` y `gpspipe -w`; RTK con NTRIP externo.
- Interfaz con la ECU: CAN `can0` 500 kbit/s; registra con `candump -l can0` y reproduce con `canplayer`.
- Captura de lidar: `tcpdump -i eth0 -w lidar.pcap udp port 2368`.

## Mini: rover con Arduino/ESP32 por serie
1. Firmware del MCU: acepta líneas `M <izq> <der>\n` (PWM −255..255) y `STOP\n`.
2. Copia `examples/mini-serial-bridge/drive.py` a `overlay-mini/opt/hexa/bin/hexa-core`; el supervisor lo reinicia si cae y envía `STOP`.
3. Control remoto: define `AP_PASS`, conéctate al AP `hexa-mini` y publica por MQTT (`mosquitto_pub -h 192.168.4.1 -t hexa/cmd -m "M 100 100"`).

## Mini: brazo de servos (PCA9685 por I2C)
`i2cdetect -y 1` debe mostrar `0x40`; escribe registros con `i2cset` o desde Python (`/dev/i2c-1`). Alimenta los servos aparte (nunca del 5 V de la placa).

## Automatización: pasarela Modbus → MQTT
```sh
PLC_HOST=192.168.1.10 UNIT=1 START=0 COUNT=10 /opt/hexa/bin/hexa-core    # ver examples/automation-modbus-mqtt
mosquitto_sub -h 127.0.0.1 -t 'hexa/modbus/#'
```
Pruébalo con un servidor Modbus simulado en tu PC. Para Modbus RTU usa `libmodbus` sobre `RS485_DEV`.

## Automatización: red mínima segura
1. Ajusta `FW_ALLOW_CIDR`. 2. Usuarios MQTT: `mosquitto_passwd -c /etc/mosquitto/passwd operador`. 3. Separa red OT/IT con VLAN.

## Simulación sin hardware
`modprobe vcan; ip link add dev can0 type vcan; ip link set up can0` (el kernel incluye `vcan`) y ejecuta `hexa-core` contra `can0`.
