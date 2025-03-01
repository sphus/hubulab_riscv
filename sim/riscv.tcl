############################## 基础配置#############################
#退出当前仿真
quit -sim
#清除命令和信息
.main clear

##############################编译和仿真文件#########################
vlib work

# 编译文件

vlog "../rtl/*.v"
vlog "../tb/*.v"

# 进行设计优化,但又保证所有信号可见,速度较快
vsim -vopt work.tb_riscv -voptargs=+acc

# add wave -divider {CLOCK} 
# add wave -radix unsigned tb/*

# add wave tb_riscv/riscv_soc_uut/riscv_inst/pc_inst/*

# add wave tb_riscv/riscv_soc_uut/riscv_inst/clk
# add wave tb_riscv/riscv_soc_uut/riscv_inst/rstn 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/inst_rom 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/inst_addr_rom 
# # add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/pc_if 
add wave tb_riscv/riscv_soc_uut/riscv_inst/pc_if 
add wave tb_riscv/riscv_soc_uut/riscv_inst/register_inst/reg_mem
# add wave tb_riscv/riscv_soc_uut/riscv_inst/inst_if 
# # add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/inst_addr_if 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/inst_addr_if 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/inst_if_id 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/inst_addr_if_id 
# # add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/rs1_addr 
# # add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/rs2_addr 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/rs1_addr 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/rs2_addr 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/rs1_data 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/rs2_data 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/inst_id 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/inst_addr_id 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/rd_addr_id 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/op1_id 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/op2_id 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/wen_id 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/inst_id_ex 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/inst_addr_id_ex 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/rd_addr_id_ex 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/op1_id_ex 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/op2_id_ex 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/wen_id_ex 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/rd_addr_ex 
# add wave -radix unsigned tb_riscv/riscv_soc_uut/riscv_inst/rd_data_ex 
# add wave tb_riscv/riscv_soc_uut/riscv_inst/wen_ex 

configure wave -signalnamewidth 1


# add wave tb_riscv/rstn

################################运行仿真#############################
# run 200ns
run 20us
# run -all
# quit -sim