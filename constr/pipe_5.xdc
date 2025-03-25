# 时钟约束50MHz
set_property -dict { PACKAGE_PIN R4 IOSTANDARD LVCMOS33 } [get_ports {clk}]; 
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports {clk}];

# 时钟引脚
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN R4 [get_ports clk]

# 复位引脚
set_property IOSTANDARD LVCMOS33 [get_ports rstn]
set_property PACKAGE_PIN U2 [get_ports rstn]

# # 程序执行完毕指示引脚
# set_property IOSTANDARD LVCMOS33 [get_ports over]
# set_property PACKAGE_PIN R2 [get_ports over]

# # 程序执行成功指示引脚
# set_property IOSTANDARD LVCMOS33 [get_ports succ]
# set_property PACKAGE_PIN R3 [get_ports succ]

# # CPU停住指示引脚
# set_property IOSTANDARD LVCMOS33 [get_ports halted_ind]
# set_property PACKAGE_PIN V2 [get_ports halted_ind]

# # 串口下载使能引脚
# set_property IOSTANDARD LVCMOS33 [get_ports uart_debug_pin]
# set_property PACKAGE_PIN Y8 [get_ports uart_debug_pin]

# # 串口发送引脚
# set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]
# set_property PACKAGE_PIN M21 [get_ports uart_tx_pin]

# # 串口接收引脚
# set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_pin]
# set_property PACKAGE_PIN K22 [get_ports uart_rx_pin]

# # GPIO0引脚
# set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]
# set_property PACKAGE_PIN Y2 [get_ports {gpio[0]}]

# # GPIO1引脚
# set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]
# set_property PACKAGE_PIN T3 [get_ports {gpio[1]}]

# # JTAG TCK引脚
# set_property IOSTANDARD LVCMOS33 [get_ports jtag_TCK]
# set_property PACKAGE_PIN G21 [get_ports jtag_TCK]
# set_property CLOCK_DEDICATED_ROUTE FALSE [get_ports jtag_TCK]
# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK_IBUF]
# # create_clock -name jtag_clk_pin -period 300 [get_ports {jtag_TCK}];

# # JTAG TMS引脚
# set_property IOSTANDARD LVCMOS33 [get_ports jtag_TMS]
# set_property PACKAGE_PIN H22 [get_ports jtag_TMS]

# # JTAG TDI引脚
# set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDI]
# set_property PACKAGE_PIN E19 [get_ports jtag_TDI]

# # JTAG TDO引脚
# set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDO]
# set_property PACKAGE_PIN G22 [get_ports jtag_TDO]

# # SPI MISO引脚
# set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]
# set_property PACKAGE_PIN M13 [get_ports spi_miso]

# # SPI MOSI引脚
# set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]
# set_property PACKAGE_PIN R17 [get_ports spi_mosi]

# # SPI SS引脚
# set_property IOSTANDARD LVCMOS33 [get_ports spi_ss]
# set_property PACKAGE_PIN N15 [get_ports spi_ss]

# # SPI CLK引脚
# set_property IOSTANDARD LVCMOS33 [get_ports spi_clk]
# set_property PACKAGE_PIN M17 [get_ports spi_clk]

# set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]  
# set_property CONFIG_MODE SPIx4 [current_design] 
# set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

# # by dzk