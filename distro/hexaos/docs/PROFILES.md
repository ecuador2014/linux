# Perfiles

Perfiles: `humanoid`, `drone`, `car`, `mini`, `automation`.

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

## mini
**Hardware típico:** Raspberry Pi Zero 2 W / 3 / 4, Orange Pi Zero, placas con ≥ 256 MB de RAM, más un microcontrolador
(Arduino, ESP32, STM32) que mueve motores y lee sensores; servos por PCA9685 (I2C); ultrasonidos/IR por GPIO; cámara USB/CSI.
- Imagen de **128 MB** (musl, BusyBox). ARMv7 32 bits (`ARCH=arm`, kernel `multi_v7`) o ARM64.
- `RT_CPUS` vacío: sin afinidad, válido en placas de 1 núcleo; prioridad RT 60.
- Serie al MCU: `MCU_DEV`/`MCU_BAUD` (`pyserial` incluido). Failsafe por defecto: enviar `STOP\n` al MCU (adáptalo a tu protocolo).
- WiFi (`S30wifi`): cliente si existe `/etc/wpa_supplicant.conf`; si no, **punto de acceso** `AP_SSID` con WPA2 cuando defines `AP_PASS`
  (8-63 caracteres; no hay contraseña por defecto, y sin ella el AP no arranca). Broker MQTT (`mosquitto`) para telemetría/mando.
- Bluetooth y 1-Wire en kernel; CAN opcional con MCP2515 por SPI (`CAN_IFACES="can0"`).
- ROS 2: en placas ≥ 1 GB con ARM64 (`ROS2=1 ARCH=aarch64`). En MCUs usa **micro-ROS** y un agente en la placa (ver ROS2.md).
- Proyectos: seguidor de línea, rover con cámara, brazo de servos, robot educativo, telepresencia, enjambre por MQTT.

## automation
**Uso:** pasarela o controlador de automatización industrial, de edificios, invernaderos, bombeo, cintas o celdas robóticas fijas:
conecta PLC/medidores (Modbus RTU/TCP, OPC UA), sensores/actuadores (GPIO, I2C, 1-Wire, ADC) y publica en MQTT/SCADA.
- **Protocolos:** `libmodbus`, `open62541` (OPC UA), `mosquitto` (MQTT), CAN/CANopen (SocketCAN), RS-485 (`RS485_DEV`).
- **Cortafuegos por defecto** (`S10firewall`, nftables): entrada denegada salvo SSH (22), Modbus (502), MQTT (1883), OPC UA (4840), solo desde `FW_ALLOW_CIDR`.
- **MQTT seguro por defecto:** sin `/etc/mosquitto/passwd` el broker solo escucha en `127.0.0.1`; con usuarios, escucha en red sin acceso anónimo.
- **Failsafe:** `FAILSAFE_CMD` típico = salidas a estado seguro con `gpioset`; vacío por defecto (defínelo según tu proceso).
- Opcional ROS 2 (`ROS2=1`); EtherCAT no incluido (ver PORTING.md).
- Proyectos: pasarela Modbus→MQTT (ejemplo incluido), invernadero, monitor de energía, celda pick&place.
