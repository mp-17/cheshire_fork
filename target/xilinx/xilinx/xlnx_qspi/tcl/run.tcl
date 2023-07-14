set partNumber $::env(XILINX_PART)
set boardName  $::env(XILINX_BOARD)

set ipName xlnx_qspi

create_project ${ipName} . -part $partNumber
set_property board_part $boardName [current_project]

create_ip -name axi_quad_spi -vendor xilinx.com -library ip -version 3.2 -module_name ${ipName}

# From https://github.com/AlSaqr-platform/he-soc/blob/master/hardware/fpga/alsaqr/tcl/ips/qspi/run.tcl
# Tested for vivado-2018.2
# set_property -dict [list CONFIG.C_SPI_MEMORY {2} \
#                             CONFIG.C_USE_STARTUP {1} \
#                             CONFIG.C_USE_STARTUP_INT {1} \
#                             CONFIG.C_SPI_MODE {2} \
#                             CONFIG.C_SCK_RATIO {2} \
#                         ] [get_ips ${ipName}]
# From vivado-2020.2 instantiation
# set_property -dict [list CONFIG.C_USE_STARTUP {1} \
                            CONFIG.C_USE_STARTUP_INT {1} \
                            CONFIG.C_SPI_MODE {2} \
                            CONFIG.C_SCK_RATIO {2} \
                            CONFIG.C_XIP_MODE {0} \
                            CONFIG.C_TYPE_OF_AXI4_INTERFACE {0} \
                        ] [get_ips ${ipName}]
# From occamy BD (vivado-2020.2) https://github.com/pulp-platform/snitch/blob/master/hw/system/occamy/fpga/occamy_vcu128_bd.tcl#L311
# NOTE: CONFIG.C_S_AXI4_ID_WIDTH {5} must match $bits(axi_slv_id_t)
set_property -dict [ list \
            CONFIG.C_FIFO_DEPTH {16} \
            CONFIG.C_SCK_RATIO {2} \
            CONFIG.C_SPI_MEMORY {2} \
            CONFIG.C_SPI_MODE {2} \
            CONFIG.C_TYPE_OF_AXI4_INTERFACE {1} \
            CONFIG.C_S_AXI4_ID_WIDTH {5} \
            CONFIG.C_USE_STARTUP {1} \
            CONFIG.C_USE_STARTUP_INT {1} \
            CONFIG.FIFO_INCLUDED {1} \
            CONFIG.Master_mode {1} \
            ] [get_ips ${ipName}]

generate_target {instantiation_template} \
[get_files ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
generate_target all [get_files  ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
# catch { config_ip_cache -export [get_ips -all ${ipName}] }
# export_ip_user_files -of_objects [get_files ./${ipName}/${ipName}.srcs/sources_1/ip/${ipName}/${ipName}.xci] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ./$ipName.srcs/sources_1/ip/$ipName/$ipName.xci]
launch_run -jobs 8 ${ipName}_synth_1
wait_on_run ${ipName}_synth_1

# From vivado-2020.2
# TODO: align parameters and use relative paths
# set_property -dict [list CONFIG.C_USE_STARTUP {1} \
CONFIG.C_USE_STARTUP_INT {1} \
CONFIG.C_SPI_MODE {2} \
CONFIG.C_SCK_RATIO {2} \
CONFIG.C_XIP_MODE {0} \
CONFIG.C_TYPE_OF_AXI4_INTERFACE {0}] [get_ips axi_quad_spi_0]
# generate_target {instantiation_template} \
[get_files ./${ipName}/${ipName}.srcs/sources_1/ip/axi_quad_spi_0/axi_quad_spi_0.xci]
# update_compile_order -fileset sources_1
# generate_target all [get_files  ./${ipName}/${ipName}.srcs/sources_1/ip/axi_quad_spi_0/axi_quad_spi_0.xci]
# catch { config_ip_cache -export [get_ips -all axi_quad_spi_0] }
# export_ip_user_files -of_objects [get_files ./${ipName}/${ipName}.srcs/sources_1/ip/axi_quad_spi_0/axi_quad_spi_0.xci] -no_script -sync -force -quiet
# create_ip_run [get_files -of_objects [get_fileset sources_1] ./${ipName}/${ipName}.srcs/sources_1/ip/axi_quad_spi_0/axi_quad_spi_0.xci]
# launch_runs axi_quad_spi_0_synth_1 -jobs 8
# export_simulation -of_objects [get_files ./${ipName}/${ipName}.srcs/sources_1/ip/axi_quad_spi_0/axi_quad_spi_0.xci] -directory ./${ipName}/${ipName}.srcs/ip_user_files/sim_scripts -ip_user_files_dir ./${ipName}/${ipName}.srcs/ip_user_files -ipstatic_source_dir ./${ipName}/${ipName}.srcs/ip_user_files/ipstatic -lib_map_path [list {modelsim=./${ipName}/${ipName}.srcs/cache/compile_simlib/modelsim} \
{questa=./${ipName}/${ipName}.srcs/cache/compile_simlib/questa} \
{ies=./${ipName}/${ipName}.srcs/cache/compile_simlib/ies} \
{xcelium=./${ipName}/${ipName}.srcs/cache/compile_simlib/xcelium} \
{vcs=./${ipName}/${ipName}.srcs/cache/compile_simlib/vcs} \
{riviera=./${ipName}/${ipName}.srcs/cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet



