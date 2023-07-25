# VCU128 emulation

```bash
# Build the bitstream:
make
# Re-build the bitstream without
# re-building the IPs:
make rebuild-top
# Simulate with the IPs
# Note you need to generate the
# Vivado IP models before
make sim
```

# VCU128 FPGA build
make [VARIABLE=value]

List of variables available for override and default values:
- ARA (default:1)
    - 0: PROJECT=cheshire_no_ara
    - 1: PROJECT=cheshire_ara_$(ARA_NR_LANES)_lanes 
- ARA_NR_LANES=[2|4|8] (default:2)
- DEBUG_RUN: (default:1)
    - 0: configure the build with the variables below
    - 1: overrides all the ones below, and sets fastest runtime
- IMPL_STRATEGY (default:Performance_ExtraTimingOpt)
    - must be supported by your vivado version
- SYNTH_STRATEGY (default:Flow_PerfOptimized_high)
    - must be supported by your vivado version
- BIT (default:out/$(PROJECT))
    - final bistream path

# VCU128 boot
Program the board:
To select the target bitstream by setting the variable BIT.

````console
$ make program BIT=yourbit.bit
````
This will take around 2 minutes.

## Build fw_payload.elf with CVA6 SDK
````console
$ export CVA6_SDK=<path to cva6-sdk clone>`
````
Defaults to `../../../cva6-sdk`

### No flash
````console
$ make spike_fw_payload
````

### Use flash (default)
````console
$ make fw_payload
````

## Program the flash (can skip if no flash)
On bordcomputer, start hw_server:
````console
$ /home/vcu128-02/hw_server.sh`
````

On host: 
````console
$ make flash_uImage
````
This will take 3-4 minutes.

## Connect with OpenOCD + GDB
On bordcomputer, stop hw_server, and launch OpenOCD:
````console
$ openocd -f openocd_configs/vcu128-2.cfg
````

On host, launch ssh tunnel to bordcomputer's GDB port: 
````console
$ ssh -L 3333:localhost:3334 -C -N -f -l $USER bordcomputer`
````

Launch GDB:
````console
$ riscv64-unknown-elf-gdb -ex "target extended-remote :3333" 
(gdb) monitor reset halt
(gdb) file fw_payload.elf
(gdb) load
(gdb) break ...set your breakpoints...
(gdb) continue
(gdb) 
````

An example and utility GDB script is provided in scripts/gdb.gdb. It can be launched like so:
````console
$ riscv64-unknown-elf-gdb -ex "target extended-remote :3333" --command=scripts/gdb/helloworld.gdb
````


