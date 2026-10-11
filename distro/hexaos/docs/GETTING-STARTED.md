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

## 3. Imágenes ISO y de disco (x86_64)
Cada build x86_64 genera, junto a `bzImage` y `rootfs.ext4`, dos imágenes arrancables en `output/<perfil>_x86_64/images/`
(las crea `tools/make-images.sh`; sin root):

| Archivo | Uso |
|---|---|
| `hexaos-<perfil>-live.iso` | **Live**: arranca por BIOS o UEFI y corre en RAM; los cambios se pierden al apagar |
| `hexaos-<perfil>.img` | **Disco**: arranca por BIOS o UEFI; partición de arranque FAT32 + raíz ext4 persistente |

Dependencias del host: `sudo apt install grub-pc-bin grub-efi-amd64-bin xorriso mtools syslinux syslinux-common dosfstools fdisk e2fsprogs`.
Si faltan, `build.sh` avisa y deja solo `bzImage` y `rootfs.ext4`. Para regenerarlas: `tools/make-images.sh output/<perfil>_x86_64/images <perfil>`.

```sh
# Grabar en USB/SSD (¡comprueba bien /dev/sdX, se borra todo!)
sudo dd if=output/humanoid_x86_64/images/hexaos-humanoid.img of=/dev/sdX bs=4M status=progress conv=fsync
# Probar sin hardware (se abre una ventana de QEMU; login root en el monitor)
MODE=iso ./run-qemu.sh humanoid
MODE=img UEFI=1 ./run-qemu.sh humanoid      # UEFI necesita el paquete ovmf
```
- El menú de arranque tiene dos entradas: **monitor y teclado** (por defecto) y **consola serie ttyS0**.
- La raíz del `.img` mide lo mismo que `rootfs.ext4` (512 MB, 2 GB con ROS 2). Para ampliarla tras grabarla: `sudo resize2fs /dev/sdX2`
  (primero amplía la partición con `parted`/`growpart`).
- La ISO live carga todo el sistema en RAM: con ROS 2 necesita ≥ 2 GB.
- ARM (Raspberry Pi y similares) no usa ISO: ver [PORTING.md](PORTING.md).

## 3b. Instalar el kernel a mano (alternativa)
- **x86_64:** `dd if=output/.../rootfs.ext4 of=/dev/sdX1` y un cargador (GRUB/syslinux) que cargue `bzImage`
  con `root=/dev/sdX1 rw isolcpus=1 nohz_full=1 rcu_nocbs=1`.
- **aarch64:** ver [PORTING.md](PORTING.md); la configuración genérica no incluye firmware ni DTB de una placa concreta.

## 4. Poner tu código
Copia tu binario de control a `/opt/hexa/bin/hexa-core` (ejecutable). `S90hexa-core` lo lanza con prioridad
`SCHED_FIFO` en `RT_CPUS` y ejecuta `FAILSAFE_CMD` si termina. Para incluirlo en la imagen, ponlo en
`board/hexaos/overlay-<perfil>/opt/hexa/bin/`. Ver [examples/hexa-core-python](../examples/hexa-core-python).
