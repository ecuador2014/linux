# Capa ROS 2

HEXAOS no empaqueta ROS 2 con Buildroot: se compila cruzado con el SDK de la propia imagen y se instala como `ros2-runtime`.
Distribución: **Jazzy** (cambia con `ROS_DISTRO`). Middleware: **Cyclone DDS** (`RMW_IMPLEMENTATION=rmw_cyclonedds_cpp`).

## Compilación
```sh
export PROFILE=humanoid ARCH=x86_64
ROS2=1 ARCH=$ARCH ./build.sh $PROFILE                    # 1ª vez: falla al final por falta del tarball (normal)
make -C .buildroot-*/ O=$PWD/output/${PROFILE}_ros2_$ARCH sdk
ARCH=$ARCH ./ros2/cross-build.sh $PROFILE                # -> ros2/output/${PROFILE}_$ARCH/ros2-install.tar.gz
ROS2=1 ARCH=$ARCH ./build.sh $PROFILE                    # ahora sí: imagen con /opt/ros
```
Tus paquetes (`ros2_control`, drivers, `hexa_bringup`…) se añaden a `ros2/ws-*/src` antes del `colcon build`
(edita `cross-build.sh` o copia tus repos tras el `vcs import`).

## En el robot
- `/etc/hexa/ros2.conf`: `ROS_DOMAIN_ID`, `ROS_LOCALHOST_ONLY`, paquete/launch (`hexa_bringup robot.launch.py`), CPUs/prioridad.
- `/etc/hexa/cyclonedds.xml`: interfaz de red. Por defecto solo `lo`; para multi-máquina cambia `name="lo"` por `eth0` y
  `ROS_LOCALHOST_ONLY=0`.
- Shell interactivo: `/etc/profile.d/ros2.sh` carga el entorno (`ros2 topic list`, etc.).
- Servicio: `/etc/init.d/S91ros2 {start|stop}`.

## Buenas prácticas de tiempo real
- Ejecuta el lazo de control como nodo con `SCHED_FIFO` y memoria bloqueada (`mlockall`); usa `realtime_tools` / `ros2_control`.
- Evita `ros2 launch` con muchos nodos en el mismo núcleo RT: separa percepción (CPUs 2+) del control (CPU 1).
- Usa QoS `SensorData` para sensores y `Reliable` con profundidad baja para comandos.

## Variantes por perfil
- **drone:** micro-XRCE-DDS Agent + `px4_msgs`; **car:** Nav2/Autoware (necesitan más RAM y GPU: considera Ubuntu para percepción
  pesada y HEXAOS para el control); **humanoid:** `ros2_control` + `controller_manager` en el lazo RT.
