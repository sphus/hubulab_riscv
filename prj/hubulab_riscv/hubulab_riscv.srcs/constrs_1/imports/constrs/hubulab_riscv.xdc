# 时钟约束50MHz
set_property -dict { PACKAGE_PIN R4 IOSTANDARD LVCMOS33 } [get_ports {clk}]; 
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports {clk}];

# 时钟引脚
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN R4 [get_ports clk]

# 复位引脚
set_property IOSTANDARD LVCMOS33 [get_ports rstn]
set_property PACKAGE_PIN U2 [get_ports rstn]

# CPU停住指示引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_halt_led]
set_property PACKAGE_PIN Y2 [get_ports jtag_halt_led]

# 程序执行完毕指示引脚
set_property IOSTANDARD LVCMOS33 [get_ports over]
set_property PACKAGE_PIN R2 [get_ports over]

# 程序执行成功指示引脚
set_property IOSTANDARD LVCMOS33 [get_ports pass]
set_property PACKAGE_PIN R3 [get_ports pass]

# JTAG TCK引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TCK]
set_property PACKAGE_PIN G21 [get_ports jtag_TCK]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_ports jtag_TCK]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK_IBUF]
# create_clock -name jtag_clk_pin -period 300 [get_ports {jtag_TCK}];

# JTAG TMS引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TMS]
set_property PACKAGE_PIN H22 [get_ports jtag_TMS]

# JTAG TDI引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDI]
set_property PACKAGE_PIN E19 [get_ports jtag_TDI]

# JTAG TDO引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDO]
set_property PACKAGE_PIN G22 [get_ports jtag_TDO]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]  
set_property CONFIG_MODE SPIx4 [current_design] 
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]