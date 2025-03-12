import os
import subprocess
import sys
# import compile_and_sim
from compile_and_sim import compile,list_binfiles,bin_to_mem,list_txtfiles,sim,copy_file

# 调用函数


def main(name = 'addi'):
    # 获取上一级路径
    rtl_dir = os.path.abspath(os.path.join(os.getcwd(), "..",".."))
    

    all_bin_files = list_txtfiles(rtl_dir + r'/sim/generated/')

    for file in all_bin_files:
        if(file.find(name) != -1 and file.find('.txt') != -1):
            test_txtfile = file
            break

    # 文件名字
    out_mem = rtl_dir + r'/sim/generated/inst_data.txt'
    copy_file(test_txtfile, out_mem)
    # bin 转 mem
    # bin_to_mem(test_binfile, out_mem)
    # 运行仿真
    sim()
    # 打印测试文件信息
    index = test_txtfile.index('-p-')
    print_name = test_txtfile[index+3:-4]
    print('test file: ' + print_name)

    # 获取波形
    # gtkwave_cmd = [r'gtkwave']
    # gtkwave_cmd.append(r'wave.vcd')
    # process = subprocess.Popen(gtkwave_cmd)

if __name__ == '__main__':
    sys.exit(main(sys.argv[1]))
