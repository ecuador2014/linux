# Changelog
## 0.1.0 — experimental
- Base Buildroot external tree `HEXAOS`; kernel 6.18.55 LTS `PREEMPT_RT`.
- Perfiles `humanoid`, `drone`, `car`, `mini`, `automation`; arquitecturas `x86_64`, `aarch64`, `arm` (genéricas).
- Perfil `automation`: Modbus, OPC UA, MQTT, RS-485, CAN, cortafuegos nftables por defecto.
- Perfil `mini` para robots pequeños: WiFi cliente/AP, MQTT, serie a MCU, imagen de 128 MB.
- Capa ROS 2 (Jazzy, Cyclone DDS) con compilación cruzada.
- Documentación y ejemplos. Sin compilar ni probar en hardware.
