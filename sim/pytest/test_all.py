import os
import subprocess
import sys
from compile_and_sim import list_binfiles

fail_file = "../output/fail.txt"
pass_file = "../output/pass.txt"

def main():
    # 获取上一级路径
    rtl_dir = os.path.abspath(os.path.join(os.getcwd(), "..",".."))
    # 检查文件是否存在，存在则删除
    if os.path.exists(fail_file):
        os.remove(fail_file)
    if os.path.exists(pass_file):
        os.remove(pass_file)
    # 获取路径下所有bin文件
    all_bin_files = list_binfiles(rtl_dir + r'/sim/generated/')
    # 遍历所有文件一个一个执行
    for file_bin in all_bin_files:
        cmd = r'python compile_and_sim.py' + ' ' + file_bin
        f = os.popen(cmd)
        r = f.read()

        index = file_bin.index('-p-')
        print_name = file_bin[index+3:-4]

        # if (r.find('pass') == -1):
        #     # 检测fail testnum的值
        #     start_index = r.find('fail testnum = ') + len('fail testnum = ')
        #     end_index = r.find('\n', start_index)
        #     testnum = r[start_index:end_index].strip()
        #     message = print_name.ljust(10, ' ') + 'fail testnum = ' + testnum
        #     print(message)
        #     # 追加写入文件
        #     with open(fail_file, "a") as file:
        #         file.write(message + '\n')
            
        if (r.find('pass') != -1):
            with open(pass_file, "a") as file:
                file.write(print_name.ljust(10, ' ') + 'PASS' + '\n')
        elif(r.find('timeout') != -1):
            message = print_name.ljust(10, ' ') + 'timeout'
            print(message)
            with open(fail_file, "a") as file:
                file.write(message + '\n')
        else:
            # 检测fail testnum的值
            start_index = r.find('fail testnum = ') + len('fail testnum = ')
            end_index = r.find('\n', start_index)
            testnum = r[start_index:end_index].strip()
            message = print_name.ljust(10, ' ') + 'fail testnum = ' + testnum
            print(message)
            # 追加写入文件
            with open(fail_file, "a") as file:
                file.write(message + '\n')

        # if (r.find('pass') != -1):
            # print('指令  ' + print_name.ljust(10, ' ') + '    PASS')
        # else:
            # print('指令  ' + print_name.ljust(10, ' ') + '    !!!FAIL!!!')

            # start_index = r.find('fail testnum = ') + len('fail testnum = ')
            # end_index = r.find('\n', start_index)
            # testnum = r[start_index:end_index].strip()
            # # 打印 testnum
            # print('fail testnum = ' + testnum)

            # print(r)
        f.close()

if __name__ == '__main__':
    main()