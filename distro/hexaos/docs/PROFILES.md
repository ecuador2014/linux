# Perfiles

## humanoid
**Hardware típico:** mini-PC x86 o SBC ARM64 + actuadores CAN (p. ej. motores tipo MIT/CyberGear/ODrive-CAN), IMU por I2C/SPI/USB,
cámaras UVC, micrófono/altavoz USB.
- CAN `can0` a 1 Mbit/s; failsafe: trama CAN configurable (`FAILSAFE_CMD`).
- Lazo de control en `RT_CPUS=1`, prioridad 80. Reserva más núcleos con `isolcpus=1,2`.
- Paquetes: `can-utils`, `libgpiod`, `i2c-tools`, `spi-tools`, `evtest`, `alsa-utils`, `v4l-utils`.
- Proyectos: caminata/equilibrio (WBC, MPC), teleoperación con gamepad, voz.

## drone
**Hardware típico:** computador companero (RPi CM4/Jetson/Orange Pi) conectado por UART/USB al autopiloto (Pixhawk con PX4 o ArduPilot).
- `S25mavlink`: `socat` entre `FC_DEV` (921600 baudios) y UDP `GCS_UDP` (QGroundControl/MAVProxy).
- Visión: GStreamer con V4L2/RTP/UDP para video a tierra; `gpsd` para GNSS auxiliar.
- Con ROS 2: usa **micro-XRCE-DDS Agent** para PX4 (`MicroXRCEAgent serial --dev /dev/ttyAMA0 -b 921600`) y `px4_msgs`.
- **El failsafe debe estar en el autopiloto** (pérdida de offboard → RTL/Land), no en Linux.
- Proyectos: seguimiento visual, navegación offboard, mapeo, entrega de carga.

## car
**Hardware típico:** PC industrial/ARM con 2-4 CAN, GNSS RTK por USB/serie, lidar Ethernet, cámaras GigE o USB, ECU del vehículo por CAN.
- CAN `can0` 500 kbit/s; `RT_CPUS=2,3`, prioridad 85.
- `S25ptp`: sincronización PTP hardware (`PTP_IFACE`) para lidar y cámaras; `chrony` para NTP.
- `tcpdump`/`libpcap` para depurar el tráfico de sensores.
- Proyectos: seguimiento de ruta (pure pursuit/MPC), AGV de almacén, rover agrícola, plataforma Autoware/Nav2.
- **Define tú `FAILSAFE_CMD`** (frenado seguro) según el protocolo de tu vehículo; viene vacío a propósito.
