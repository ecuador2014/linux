#!/usr/bin/env python3
"""hexa-core para el perfil mini: recibe "M <izq> <der>" por MQTT local (mosquitto_sub) y lo reenvia al MCU por serie.

Instalar como /opt/hexa/bin/hexa-core. Protocolo MCU: "M <izq> <der>\n" (-255..255) y "STOP\n".
Si no llegan ordenes en TIMEOUT s, para los motores (latido por software).
"""
import os, select, subprocess, sys, time

import serial  # pyserial

DEV = os.environ.get("MCU_DEV", "/dev/ttyUSB0")
BAUD = int(os.environ.get("MCU_BAUD", "115200"))
TIMEOUT = 0.5


def clamp(v):
    return max(-255, min(255, v))


def main():
    mcu = serial.Serial(DEV, BAUD, timeout=0.1)
    sub = subprocess.Popen(["mosquitto_sub", "-h", "127.0.0.1", "-t", "hexa/cmd"],
                           stdout=subprocess.PIPE, text=True)
    last = time.monotonic()
    while True:
        r, _, _ = select.select([sub.stdout], [], [], 0.1)
        if r:
            line = sub.stdout.readline()
            if not line:
                sys.exit("mosquitto_sub termino")
            try:
                cmd, l, rr = line.split()
                if cmd == "M":
                    mcu.write(f"M {clamp(int(l))} {clamp(int(rr))}\n".encode())
                    last = time.monotonic()
            except ValueError:
                pass  # ignora basura
        elif time.monotonic() - last > TIMEOUT:
            mcu.write(b"STOP\n")
            last = time.monotonic()


if __name__ == "__main__":
    main()
