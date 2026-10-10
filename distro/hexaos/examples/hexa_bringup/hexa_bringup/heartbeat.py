import rclpy
from rclpy.node import Node
from std_msgs.msg import Int32


class Heartbeat(Node):
    """Publica un latido a 100 Hz; un monitor puede disparar el failsafe si se detiene."""
    def __init__(self):
        super().__init__('hexa_heartbeat')
        self.pub = self.create_publisher(Int32, 'hexa/heartbeat', 10)
        self.n = 0
        self.create_timer(0.01, self.tick)

    def tick(self):
        self.pub.publish(Int32(data=self.n))
        self.n += 1


def main():
    rclpy.init()
    rclpy.spin(Heartbeat())
