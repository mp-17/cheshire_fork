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
- PROJECT:
    - Override project name
- ARA: (default:1)
    - 0: PROJECT=cheshire_no_ara
    - 1: PROJECT=cheshire_ara_$(ARA_NR_LANES)_lanes 
- ARA_NR_LANES=[2|4|8] (default:2)
- DEBUG_RUN: (default:1)
    - 0: configure the build with the variables below
    - 1: overrides all the ones below, sets fastest runtime 
- DEBUG_NETS: (default:1) 
    - 0: Don't instantiate ILAs on nets
    - 1: Instantiate ILAs on nets
- IMPL_STRATEGY (default:Performance_ExtraTimingOpt)
    - must be supported by your vivado version
- SYNTH_STRATEGY (default:Flow_PerfOptimized_high)
    - must be supported by your vivado version
- BIT (default:target/xilinx/out/$(PROJECT).bit)
    - Override bistream path
- LTX (default:target/xilinx/out/$(PROJECT).ltx)
    - Override probes file path
- INT_JTAG: (default:0)
    - 0: Use FMC connector for CVA6-attached JTAG module
    - 1: Use BSCANE2, i.e., USB scanchain, connector for CVA6-attached JTAG module

NOTE: If INT_JTAG=1, hw_server and OpenOCD cannot be used together since they attach to the same USB connector


# VCU128 Linux boot
Link cva6-sdk in the `sw/boot` directory:
````console
$ ln -s $(CVA6-SDK)/install64 sw/boot/install64V
$ make spi_boot
````

## SPI flash boot
From cva6-sdk, build OpenSBI+U-Boot and Linux images:
````console
$ make clean_spi_boot
$ make spi_boot
````

### Program the flash 
This step can be skipped if the "In-memory flow" is used.

On bordcomputer, start hw_server:
````console
$ /home/vcu128-02/hw_server.sh`
````

On host: 
````console
$ make chs-xil-flash
````
This will take 3-10 minutes, depending on the flash image size.

### Flash the bitstream
On bordcomputer, start hw_server:
````console
$ /home/vcu128-02/hw_server.sh`
````
Program the board:
To select the target bitstream by setting the variable BIT.

````console
$ make program BIT=yourbit.bit
````
This will take around 2 minutes.

## In-memory boot
From cva6-sdk, build OpenSBI+Linux image:
````console
$ make clean_in_memory_boot
$ make in_memory_boot
````

### Flash the bitstreamsd
See above.

### Connect with OpenOCD + GDB
On bordcomputer launch OpenOCD:

- if INT_JTAG=0, 
````console
$ openocd -f openocd_configs/vcu128-2-digilent.cfg
````
- if INT_JTAG=1
````console
$ openocd -f openocd_configs/vcu128-2.cfg
````

From GDB UI:
````console
(gdb) source scripts/gdb/in_memory_boot.gdb
````



