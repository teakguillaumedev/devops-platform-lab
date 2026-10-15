# Day 02 — Namespaces & cgroups

## Key ideas
- A container = a normal process + namespaces (what it SEES) + cgroups (what it CONSUMES) + its own root filesystem.
- Namespaces: pid, uts, mnt, net, ipc, user, cgroup. Inspect with `ls -l /proc/<pid>/ns` and `lsns`.
- `unshare --pid` needs `--fork` (only children enter the new PID ns) and `--mount-proc` (ps reads /proc).
- One process, one PID per namespace level (1 inside, 2345 on the host).
- PID 1 dies → kernel SIGKILLs the whole namespace → container stops.
- chroot only changes `/`; no process, network or hostname isolation.
- `exec` replaces the shell → the app is PID 1. Dockerfile: exec form `CMD ["app"]` receives SIGTERM; shell form doesn't.
- cgroups v2: `cpu.max = 20000 100000` → 20 ms per 100 ms = 20% CPU.
- CPU is compressible → throttled. Memory is incompressible → OOM killed.
- Exit code = 128 + signal: 137 = SIGKILL (OOMKilled), 143 = SIGTERM.

## Lab: hand-made container
sudo unshare --pid --fork --mount --uts --net --ipc \
  chroot rootfs /bin/sh -c "mount -t proc proc /proc && hostname mini && exec /bin/sh"

## Lab: limits
sudo systemd-run --unit=cpu-test -p CPUQuota=20% sh -c 'yes > /dev/null'
sudo systemd-run --unit=mem-test -p MemoryMax=50M -p MemorySwapMax=0 python3 -c "..."

## Permissions & strace
- Directory: r = list names, x = traverse/enter. 644 on a dir → ls ok, cd denied.
- setuid = runs as file owner (passwd). On bash → root shell for anyone (bash -p). Audit: find / -perm -4000.
- Sticky bit on /tmp: only the owner can delete his files.
- Containers: run as non-root (USER 1000 / runAsUser).
- strace = syscalls. -c summary, -f follow children, -e trace=file, -p attach.
- ENOENT = no such file, EACCES = permission denied.
- Debug "Permission denied": strace | grep EACCES → namei -l <path> → id.
