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
vsim -vopt work.tb_ram -voptargs=+acc

# add wave -divider {CLOCK} 
# add wave -divider {RAM} 
add wave -divider {RAM} 
add wave -radix unsigned tb_ram/*
add wave -divider {RAM_BYTE0} 
add wave -radix unsigned tb_ram/u_ram/ram_byte0/*
add wave -divider {RAM_BYTE1} 
add wave -radix unsigned tb_ram/u_ram/ram_byte1/*
add wave -divider {RAM_BYTE2} 
add wave -radix unsigned tb_ram/u_ram/ram_byte2/*
add wave -divider {RAM_BYTE3} 
add wave -radix unsigned tb_ram/u_ram/ram_byte3/*


configure wave -signalnamewidth 1


# add wave tb_ram/rstn

################################运行仿真#############################
# run 200ns
run 20us
# run -all
# quit -sim