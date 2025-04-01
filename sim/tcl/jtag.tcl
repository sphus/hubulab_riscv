############################## 基础配置#############################
#退出当前仿真
quit -sim
#清除命令和信息
.main clear

##############################编译和仿真文件#########################
vlib work

# 编译文件

vlog "../../rtl/core/*.v"
vlog "../../rtl/periph/*.v"
vlog "../../rtl/soc/*.v"
vlog "../../rtl/utils/*.v"
vlog "../../rtl/debug/*.v"
vlog "../../tb/*.v"

# 进行设计优化,但又保证所有信号可见,速度较快
vsim -vopt work.tb_jtag -voptargs=+acc

# add wave -divider {CLOCK} 
# add wave -radix unsigned tb/*

# add wave tb_jtag/riscv_soc_inst/riscv_inst/pc_inst/*

# add wave tb_jtag/riscv_soc_inst/riscv_inst/clk
# add wave tb_jtag/riscv_soc_inst/riscv_inst/rstn 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/inst_rom 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/inst_addr_rom 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/pc_if 

# add wave tb_jtag/riscv_soc_inst/riscv_inst/pc_if 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/register_inst/reg_mem

# add wave tb_jtag/riscv_soc_inst/riscv_inst/inst_if 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/inst_addr_if 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/inst_addr_if 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/inst_if_id 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/inst_addr_if_id 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/rs1_addr 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/rs2_addr 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/rs1_addr 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/rs2_addr 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/rs1_data 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/rs2_data 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/inst_id 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/inst_addr_id 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/rd_addr_id 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/op1_id 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/op2_id 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/wen_id 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/inst_id_ex 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/inst_addr_id_ex 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/rd_addr_id_ex 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/op1_id_ex 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/op2_id_ex 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/wen_id_ex 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/rd_addr_ex 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/rd_data_ex 

# add wave tb_jtag/riscv_soc_inst/riscv_inst/inst_rom    
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/inst_addr_rom

add wave -divider {SOC} 
add wave tb_jtag/riscv_soc_inst/*
#add wave -divider {ROM} 
#add wave tb_jtag/riscv_soc_inst/rom_test_init/*
add wave -divider {ROM} 
add wave tb_jtag/riscv_soc_inst/rom_inst/*
add wave -divider {dual_ram} 
add wave tb_jtag/riscv_soc_inst/rom_inst/dual_ram_inst/*
add wave -divider {JTAG} 
add wave tb_jtag/riscv_soc_inst/u_jtag_top/*
add wave -divider {DERIVER} 
add wave tb_jtag/riscv_soc_inst/u_jtag_top/u_jtag_driver/*
add wave -divider {DM} 
add wave tb_jtag/riscv_soc_inst/u_jtag_top//u_jtag_dm/*

# add wave -divider {CSR_REG} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/csr_reg_inst/*
# add wave -divider {SOC} 
# add wave tb_jtag/riscv_soc_inst/*
# add wave -divider {ROM} 
# add wave tb_jtag/riscv_soc_inst/rom_inst/*
# add wave -divider {JTAG} 
# add wave tb_jtag/riscv_soc_inst/u_jtag_top/*
# add wave -divider {DERIVER} 
# add wave tb_jtag/riscv_soc_inst/u_jtag_top/u_jtag_driver/*
# add wave -divider {DM} 
# add wave tb_jtag/riscv_soc_inst/u_jtag_top//u_jtag_dm/*
# add wave -divider {RV} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/*
# add wave -divider {REGISTER} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/register_inst/reg_mem
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/inst_i
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/inst_addr_i
# add wave -divider {ID} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/id_inst/*
# add wave -divider {ID_EX} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/id_ex_inst/*
# add wave -divider {EX} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/*
# add wave -divider {RAM} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ram_inst/*
# add wave -divider {RAM_BYTE0} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ram_inst/ram_byte0/*
# add wave -divider {RAM_BYTE0_TEMPLATE} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ram_inst/ram_byte0/dual_ram_template_inst/*
# add wave -divider {RAM_BYTE1} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ram_inst/ram_byte1/dual_ram_template_inst/*
# add wave -divider {RAM_BYTE2} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ram_inst/ram_byte2/dual_ram_template_inst/*
# add wave -divider {RAM_BYTE3} 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ram_inst/ram_byte3/*
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/func7 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/rs2   
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/rs1   
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/func3 
# add wave -radix unsigned tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/rd    
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/opcode
# add wave tb_jtag/riscv_soc_inst/riscv_inst/wen_ex 
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/jump_addr_o
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/jump_en_o  
# add wave tb_jtag/riscv_soc_inst/riscv_inst/ex_inst/hold_flag_o

configure wave -signalnamewidth 1

# add wave tb_jtag/rstn

################################运行仿真#############################
 run 200us
# run 20us
# run -all
# quit -sim