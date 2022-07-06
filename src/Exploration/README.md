# LEAP-Research-Group (LRG)

## Multi Threading
The `compareLevelplain()` function in `GAs.jl` is now implemented to use multiple Threads. (e.g. run each simulation in an own Thread)

Julia starts with only one Thread by default. To start Julia with more Threads you have to use the `-t` / `--threads` option.  
To use Julia with 4 Threads use:

```bash
$ julia -t 4
# OR:
$ julia --threads 4
```

Alternatively you can set the `JULIA_NUM_THREADS` environment variable (depending on OS and used shell):
```bash
# bash (on Linux/macOS):
export JULIA_NUM_THREADS=4
```
```bash
# C shell on Linux/macOS, CMD on Windows:
set JULIA_NUM_THREADS=4
```
```PowerShell
# Windows Powershell:
$env:JULIA_NUM_THREADS=4
```

You can easily verify how much Threads Julia uses with:
```Julia REPL
julia> Threads.nthreads()
4
```