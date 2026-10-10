# Ejemplos
- `hexa-core-python/`: lazo de control 1 kHz sobre SocketCAN → `/opt/hexa/bin/hexa-core`.
- `hexa_bringup/`: paquete ROS 2 (ament_python) con `robot.launch.py`; cópialo a `ros2/ws-<perfil>-<arch>/src/` antes de `cross-build.sh`.
- `mini-serial-bridge/`: mando MQTT → MCU por serie con latido por software (perfil `mini`).
