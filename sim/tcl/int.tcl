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
vsim -vopt work.tb_int -voptargs=+acc

add wave -divider {SOC} 
add wave tb_int/riscv_soc_inst/*
add wave -divider {RISCV} 
add wave tb_int/riscv_soc_inst/riscv_inst/*
add wave -divider {REG} 
add wave tb_int/riscv_soc_inst/riscv_inst/register_inst/reg_mem
add wave -divider {if_id} 
add wave tb_int/riscv_soc_inst/riscv_inst/if_id_inst/*
add wave -divider {ex} 
add wave tb_int/riscv_soc_inst/riscv_inst/ex_inst/*
add wave -divider {COMMIT} 
add wave tb_int/riscv_soc_inst/riscv_inst/commit_init/*
add wave -divider {PLIC} 
add wave tb_int/riscv_soc_inst/plic_inst/*
add wave -divider {CLINT} 
add wave tb_int/riscv_soc_inst/clint_inst/*
add wave -divider {CSR} 
add wave tb_int/riscv_soc_inst/riscv_inst/csr_reg_inst/*

configure wave -signalnamewidth 1

# add wave tb_int/rstn

################################运行仿真#############################
 run 10us
# run 20us
# run -all
# quit -sim