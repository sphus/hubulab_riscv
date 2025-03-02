自动化测试使用方法:
打开Anaconda Prompt

```
# 进入当前文件夹 
cd D:\work_file\FPGA\RISC_V\mine_rv\sim
# 单条指令测试:执行auipc指令测试
python test_one_inst.py auipc
# 全测试:执行generated/所有bin文件
python test_all.py
```