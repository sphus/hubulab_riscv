import os
import subprocess
import sys
from compile_and_sim import list_txtfiles

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

    pass_flag = True

    # 获取路径下所有txt文件
    all_txt_files = list_txtfiles(rtl_dir + r'/sim/generated/')
    # 遍历所有文件一个一个执行
    # for file_txt in all_txt_files:
    for i,file_txt in enumerate(all_txt_files):

        if i == 0:
            continue  # 跳过当前循环，处理下一个文件

        cmd = r'python compile_and_sim.py' + ' ' + file_txt
        f = os.popen(cmd)
        r = f.read()

        index = file_txt.index('-p-')
        print_name = file_txt[index+3:-4]

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
        elif(r.find('fail') != -1):
            # 检测fail testnum的值
            pass_flag = False
            start_index = r.find('fail testnum = ') + len('fail testnum = ')
            end_index = r.find('\n', start_index)
            testnum = r[start_index:end_index].strip()
            message = print_name.ljust(10, ' ') + 'fail testnum = ' + testnum
            print(message)
            # 追加写入文件
            with open(fail_file, "a") as file:
                file.write(message + '\n')
        elif(r.find('timeout') != -1):
            pass_flag = False
            message = print_name.ljust(10, ' ') + 'timeout'
            print(message)
            with open(fail_file, "a") as file:
                file.write(message + '\n')
        else:
            pass_flag = False
            print(print_name.ljust(10, ' ') + 'test error!')
            # print('test error!')

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
    print(pass_flag)
    if (pass_flag == True):
        print("############################")
        print("#####  ALL INST PASS  ######")
        print("############################")
    else:
        print("############################")
        print("#####  SOME INST FAIL  #####")
        print("############################")

if __name__ == '__main__':
    main()