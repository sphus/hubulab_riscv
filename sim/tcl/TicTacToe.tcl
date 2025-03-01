############################## 基础配置#############################
#退出当前仿真
quit -sim
#清除命令和信息
.main clear

##############################编译和仿真文件#########################
vlib work

# 编译文件

vlog "../rtl/tictactoe/*.v"
vlog "../tb/tictactoe/*.v"

# 进行设计优化,但又保证所有信号可见,速度较快
vsim -vopt work.tb_TicTacToe -voptargs=+acc

################################添加波形#############################
# 添加虚拟类型
# virtual    type {
# {01 IDLE}
# {02 HALF}
# {04 ONE}
# {08 ONE_HALF}
# {16 TWO}
# } vir_new_signal
# virtual    function {(vir_new_signal)tb_complex_fsm/complex_fsm_inst/state} new_state
# add wave  -color red  -itemcolor blue  tb_complex_fsm/complex_fsm_inst/new_state

# #添加波形区分说明
# add wave -divider {name} 

###常用添加波形指令
#-radix red -----设置波形颜色
#-itemcolor Violet -----设置波形名字颜色
#常用颜色：red,blue,yellow,pink,orange,cyan,violet
#-radix decimal----定义显示进制形式
#常用进制有 binary, ascii, decimal, octal, hex, symbolic, time, and default

add wave -radix binary tb_TicTacToe/*
# add wave -position insertpoint sim:tb_TicTacToe/*
# add wave -position insertpoint sim:tb_TicTacToe/uut/*
# add wave -position insertpoint sim:tb_TicTacToe/uut/winx/*
# add wave -position insertpoint sim:tb_TicTacToe/uut/winx/topr/*
# add wave -position insertpoint sim:tb_TicTacToe/uut/winx/midr/*
# add wave -position insertpoint sim:tb_TicTacToe/uut/winx/botr/*
# add wave -position insertpoint sim:tb_TicTacToe/uut/blockx/*
# add wave -position insertpoint sim:tb_TicTacToe/uut/emptyx/*
# add wave -position insertpoint sim:tb_TicTacToe/opponent/*

## 配置时间线单位(不配置时默认为ns)
# configure wave -timelineunits us

################################运行仿真#############################
run 5us
# quit -sim

# https://blog.csdn.net/L_Carpediem/article/details/134223621