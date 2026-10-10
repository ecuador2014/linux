from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    return LaunchDescription([
        Node(package='hexa_bringup', executable='heartbeat', name='hexa_heartbeat'),
        # Añade aquí tus nodos: ros2_control, drivers de sensores, etc.
    ])
