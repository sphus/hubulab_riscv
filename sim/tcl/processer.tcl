############################## 基础配置#############################
#退出当前仿真
quit -sim
#清除命令和信息
.main clear

##############################编译和仿真文件#########################
vlib work

# 编译文件

vlog "../rtl/microcode/*.v"
vlog "../tb/microcode/*.v"

# 进行设计优化,但又保证所有信号可见,速度较快
vsim -vopt work.tb_processer -voptargs=+acc

add wave -divider {CLOCK} 
add wave tb_processer/clk
add wave tb_processer/rstn
add wave -divider {IO_PORT}
add wave -radix decimal tb_processer/in
add wave -radix decimal tb_processer/o0
add wave -radix decimal tb_processer/o1
add wave -divider {REGISTER}
add wave -radix decimal tb_processer/uut/t0
add wave -radix decimal tb_processer/uut/t1
add wave -radix decimal tb_processer/uut/t2

################################运行仿真#############################
run 5us
# quit -sim