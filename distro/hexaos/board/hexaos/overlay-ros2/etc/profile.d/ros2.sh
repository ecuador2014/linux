# Entorno ROS 2 para shells interactivos
ROS_ROOT=$(ls -d /opt/ros 2>/dev/null)
if [ -f "$ROS_ROOT/setup.sh" ]; then
    . /etc/hexa/ros2.conf
    export ROS_DOMAIN_ID RMW_IMPLEMENTATION ROS_LOCALHOST_ONLY
    export CYCLONEDDS_URI=file:///etc/hexa/cyclonedds.xml
    . "$ROS_ROOT/setup.sh"
fi
