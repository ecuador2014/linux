# Contribuir
- Un cambio por PR; describe perfil/arquitectura afectados.
- No edites `configs/*_defconfig`: modifica `profiles/*.frag` y ejecuta `tools/gen-defconfigs.sh`.
- Scripts de init: POSIX `sh` (excepto `S91ros2`, que usa bash); valida con `sh -n`/`shellcheck`.
- Documenta cambios de configuración en `docs/CONFIGURATION.md` y añade entrada en `CHANGELOG.md`.
- Seguridad: no incluyas contraseñas ni claves; los cambios en failsafe requieren descripción de la prueba realizada.
