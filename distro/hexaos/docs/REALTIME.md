# Tiempo real

## Qué configura HEXAOS
Kernel `PREEMPT_RT`, `HZ=1000`, `NO_HZ_FULL`, RCU callbacks fuera de CPUs aisladas, governor `performance`,
`sched_rt_runtime_us=-1`, IRQs movidas a CPU0 (`S05rt-tune`), `swappiness=0`.

## Qué debes hacer tú
1. Cmdline: `isolcpus=1 nohz_full=1 rcu_nocbs=1` (CPUs de control) y que `RT_CPUS` coincida.
2. En tu proceso: `mlockall(MCL_CURRENT|MCL_FUTURE)`, preasigna memoria, evita `malloc`/IO/logs en el lazo, usa `clock_nanosleep(TIMER_ABSTIME)`.
3. Desactiva en BIOS: C-states profundos, Turbo/SMT si buscas mínima latencia, SMI.

## Medir (incluye `rt-tests`)
```sh
cyclictest -m -S -p 95 -i 200 -D 1h -h 400 -q      # latencia de planificación bajo carga
stress-ng --cpu 4 --io 2 --vm 1 &                  # genera carga en otras CPUs (instálalo si lo necesitas)
```
Objetivos orientativos: máx. < 100 µs en x86, < 200 µs en ARM64. Si superas: revisa SMIs, frecuencia, IRQs
(`/proc/interrupts`), `perf`/`ftrace` (`trace-cmd`) y drivers USB/GPU que roben tiempo.

## Jitter del bus
CAN: `txqueuelen 1000`, `restart-ms 100` (ya configurado). Para lazos > 1 kHz usa CAN FD o EtherCAT (no incluido; ver PORTING.md).
