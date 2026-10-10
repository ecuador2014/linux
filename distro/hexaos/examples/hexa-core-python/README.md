# hexa-core (Python, SocketCAN)
Plantilla de lazo periódico a 1 kHz. Python no es determinista: úsala para prototipos y migra a C++/Rust (`clock_nanosleep`,
`mlockall`) para el lazo RT definitivo. Ver [docs/PROJECTS.md](../../docs/PROJECTS.md).
