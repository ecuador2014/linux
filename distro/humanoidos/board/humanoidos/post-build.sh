#!/bin/sh
# Se ejecuta con TARGET_DIR como $1. Instala la clave SSH si HUMANOID_SSH_PUBKEY apunta a un .pub
set -e
TARGET_DIR="$1"
chmod 0755 "$TARGET_DIR"/etc/init.d/S* "$TARGET_DIR"/opt/robot/bin/* 2>/dev/null || true
if [ -n "$HUMANOID_SSH_PUBKEY" ] && [ -f "$HUMANOID_SSH_PUBKEY" ]; then
    install -d -m 0700 "$TARGET_DIR/root/.ssh"
    install -m 0600 "$HUMANOID_SSH_PUBKEY" "$TARGET_DIR/root/.ssh/authorized_keys"
fi
