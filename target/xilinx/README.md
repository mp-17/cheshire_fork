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

# VCU128 boot
Program the board:
To select the target bitstream, either:
1. Export the envvar BIT=yourbit.bit
2. Select it form the `out/` directory exporting the following variables:
    - ARA=0: cheshire_no_ara
    - ARA=1: cheshire_ara_$(ARA_NR_LANES)_lanes
        - ARA_NR_LANES=[2|4|8]
Some runs might have an additional suffix:
   - IMPL_STRATEGY=...

````console
$ make program
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

## Connect with OpenOCd + GDB
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
$ riscv64-unknown-elf-gdb  -ex "target extended-remote :3333" 
(gdb) monitor reset halt
(gdb) file fw_payload.elf
(gdb) load
(gdb) break ...set your breakpoints...
(gdb) continue
(gdb) 
````


