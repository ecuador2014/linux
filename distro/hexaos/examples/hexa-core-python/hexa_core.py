#!/usr/bin/env python3
"""Plantilla de hexa-core: lazo periodico a 1 kHz sobre SocketCAN (solo libreria estandar).

Instalar como /opt/hexa/bin/hexa-core. S90hexa-core lo lanza con SCHED_FIFO en RT_CPUS.
Probar sin hardware: modprobe vcan; ip link add dev can0 type vcan; ip link set up can0
"""
import os, socket, struct, time

IFACE = os.environ.get("CAN_IFACE", "can0")
PERIOD_NS = 1_000_000          # 1 kHz
CAN_FMT = "=IB3x8s"            # struct can_frame: id, dlc, pad, data


def main():
    s = socket.socket(socket.AF_CAN, socket.SOCK_RAW, socket.CAN_RAW)
    s.bind((IFACE,))
    s.setblocking(False)
    try:
        os.mlockall(os.MCL_CURRENT | os.MCL_FUTURE) if hasattr(os, "mlockall") else None
    except OSError:
        pass
    next_t = time.monotonic_ns()
    seq = 0
    while True:
        # 1) leer feedback sin bloquear
        try:
            while True:
                can_id, dlc, data = struct.unpack(CAN_FMT, s.recv(16))
        except BlockingIOError:
            pass
        # 2) calcular comando (aqui va tu controlador)
        cmd = struct.pack("<H", seq & 0xFFFF)
        # 3) enviar
        s.send(struct.pack(CAN_FMT, 0x123, len(cmd), cmd.ljust(8, b"\0")))
        seq += 1
        next_t += PERIOD_NS
        delay = next_t - time.monotonic_ns()
        if delay > 0:
            time.sleep(delay / 1e9)
        else:
            next_t = time.monotonic_ns()   # overrun: resincroniza


if __name__ == "__main__":
    main()
