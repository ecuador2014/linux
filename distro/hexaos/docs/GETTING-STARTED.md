# Primeros pasos

## Requisitos del host
Linux (Debian/Ubuntu recomendado), ≥ 20 GB libres, 8 GB RAM, acceso a Internet. Paquetes:
`sudo apt install build-essential git curl wget cpio unzip rsync bc file libncurses-dev qemu-system-x86`.
Para ROS 2 además: Ubuntu 24.04, `python3-colcon-common-extensions python3-vcstool cmake`.

## 1. Compilar
```sh
cd distro/hexaos
HEXA_SSH_PUBKEY=~/.ssh/id_ed25519.pub ./build.sh humanoid     # tarda 30-90 min la primera vez
```
La salida queda en `output/humanoid_x86_64/images/` (`bzImage`, `rootfs.ext4`).

## 2. Probar en QEMU
```sh
./run-qemu.sh humanoid        # login: root (sin contraseña en consola; SSH solo con clave)
ssh -p 2222 root@localhost
```
Dentro: `uname -a` (debe decir `PREEMPT_RT`), `cat /etc/hexa/profile.conf`, `ls /etc/init.d`.

## 3. Instalar en hardware
- **x86_64:** `dd if=output/.../rootfs.ext4 of=/dev/sdX` y arranca con un cargador (GRUB/syslinux) apuntando a `bzImage`
  con `root=/dev/sdX1 rw isolcpus=1 nohz_full=1 rcu_nocbs=1`.
- **aarch64:** ver [PORTING.md](PORTING.md); la configuración genérica no incluye firmware ni DTB de una placa concreta.

## 4. Poner tu código
Copia tu binario de control a `/opt/hexa/bin/hexa-core` (ejecutable). `S90hexa-core` lo lanza con prioridad
`SCHED_FIFO` en `RT_CPUS` y ejecuta `FAILSAFE_CMD` si termina. Para incluirlo en la imagen, ponlo en
`board/hexaos/overlay-<perfil>/opt/hexa/bin/`. Ver [examples/hexa-core-python](../examples/hexa-core-python).
