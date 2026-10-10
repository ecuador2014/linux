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

## Simulación sin hardware
`modprobe vcan; ip link add dev can0 type vcan; ip link set up can0` (el kernel incluye `vcan`) y ejecuta `hexa-core` contra `can0`.
