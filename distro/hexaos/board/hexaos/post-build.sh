#!/bin/sh
# Se ejecuta con TARGET_DIR como $1. Instala la clave SSH si HEXA_SSH_PUBKEY apunta a un .pub
set -e
TARGET_DIR="$1"
chmod 0755 "$TARGET_DIR"/etc/init.d/S* "$TARGET_DIR"/opt/hexa/bin/* 2>/dev/null || true
# El dnsmasq del paquete arrancaria un DNS en todas las interfaces y chocaria con el de S30wifi (AP).
# Los perfiles que lo necesitan lo lanzan ellos mismos.
rm -f "$TARGET_DIR"/etc/init.d/S80dnsmasq
if [ -n "$HEXA_SSH_PUBKEY" ] && [ -f "$HEXA_SSH_PUBKEY" ]; then
    install -d -m 0700 "$TARGET_DIR/root/.ssh"
    install -m 0600 "$HEXA_SSH_PUBKEY" "$TARGET_DIR/root/.ssh/authorized_keys"
fi
