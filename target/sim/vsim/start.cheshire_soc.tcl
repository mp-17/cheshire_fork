# Copyright 2022 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Nicole Narr <narrn@student.ethz.ch>
# Christopher Reinwardt <creinwar@student.ethz.ch>
# Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>
# Paul Scheffler <paulsc@iis.ee.ethz.ch>

set TESTBENCH tb_cheshire_soc

# Set voptargs only if not already set to make overridable.
# Default on fast simulation flags.
if {![info exists VOPTARGS]} {
    # Log all signals
    set VOPTARGS "-O5 -permissive +acc=p+tb_cheshire_soc/fix/dut. -debugdb"
}

# Suppress (vopt-7033) Variable '' driven in a combinational block, may not be driven by any other process.
# Because of ara/lane/operand_requester.sv
set flags "-suppress 3009 -suppress 8386 -suppress vopt-7033 -error 7 -dpicpppath /usr/pack/questa-2022.3-bt/questasim/gcc-7.4.0-linux_x86_64/bin/g++"

set pargs ""
if {[info exists BOOTMODE]} { append pargs "+BOOTMODE=${BOOTMODE} " }
if {[info exists PRELMODE]} { append pargs "+PRELMODE=${PRELMODE} " }
if {[info exists BINARY]}   { append pargs "+BINARY=${BINARY} " }
if {[info exists IMAGE]}    { append pargs "+IMAGE=${IMAGE} " }

eval "vsim -c ${TESTBENCH} -t 1ns -vopt -debugdb -voptargs=\"${VOPTARGS}\"" ${pargs} ${flags}

set StdArithNoWarnings 1
set NumericStdNoWarnings 1
