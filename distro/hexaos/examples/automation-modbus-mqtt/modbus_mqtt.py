#!/usr/bin/env python3
"""Pasarela Modbus-TCP -> MQTT (solo libreria estandar + mosquitto_pub). Instalar como /opt/hexa/bin/hexa-core.

Lee N registros holding de un PLC/medidor cada INTERVAL s y publica hexa/modbus/<unit>/<addr> = valor.
Variables: PLC_HOST, PLC_PORT (502), UNIT (1), START (0), COUNT (10), INTERVAL (1.0), MQTT_HOST (127.0.0.1)
"""
import os, socket, struct, subprocess, time

HOST = os.environ["PLC_HOST"]
PORT = int(os.environ.get("PLC_PORT", "502"))
UNIT = int(os.environ.get("UNIT", "1"))
START = int(os.environ.get("START", "0"))
COUNT = int(os.environ.get("COUNT", "10"))
INTERVAL = float(os.environ.get("INTERVAL", "1.0"))
MQTT = os.environ.get("MQTT_HOST", "127.0.0.1")


def read_holding(sock, tid):
    # MBAP (tid, proto=0, len=6, unit) + FC03 (start, count)
    sock.sendall(struct.pack(">HHHBBHH", tid, 0, 6, UNIT, 3, START, COUNT))
    hdr = sock.recv(9)
    if len(hdr) < 9 or hdr[7] != 3:
        raise IOError("respuesta Modbus invalida/excepcion")
    n = hdr[8]
    data = b""
    while len(data) < n:
        chunk = sock.recv(n - len(data))
        if not chunk:
            raise IOError("conexion cerrada")
        data += chunk
    return struct.unpack(">%dH" % (n // 2), data)


def main():
    tid = 0
    while True:
        try:
            with socket.create_connection((HOST, PORT), timeout=2) as s:
                while True:
                    tid = (tid + 1) & 0xFFFF
                    for i, v in enumerate(read_holding(s, tid)):
                        subprocess.run(["mosquitto_pub", "-h", MQTT, "-t",
                                        f"hexa/modbus/{UNIT}/{START + i}", "-m", str(v)], check=False)
                    time.sleep(INTERVAL)
        except (OSError, IOError) as e:
            print("error:", e, flush=True)
            time.sleep(2)  # reintenta


if __name__ == "__main__":
    main()
