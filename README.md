自动化测试使用方法:
- 打开Anaconda Prompt
  ```
  :: 进入sim\pytest\文件夹
  :: 其中$PATH为工程的绝对路径
  cd $PATH\sim\pytest

  :: 单条指令测试:执行auipc指令测试
  python test_one_inst.py auipc
  :: 全测试:执行generated/所有bin文件
  python test_all.py
  ```
- 结果
  - print到cmd上了
  - 也可以打开[fail.txt](sim/output/fail.txt)和[pass.txt](sim/output/pass.txt)查看

寄存器表

| Register | Name   | Use                          | Saver  |
| :------- | :----- | :--------------------------- | :----- |
| x0       | zero   | Constant 0                   | -      |
| x1       | ra     | Return Address               | Caller |
| x2       | sp     | Stack Pointer                | Callee |
| x3       | gp     | Global Pointer               | -      |
| x4       | tp     | Thread Pointer               | -      |
| x5~x7    | t0~t2  | Temp                         | Caller |
| x8       | s0/fp  | Saved/Frame pointer          | Callee |
| x9       | s1     | Saved                        | Callee |
| x10~x11  | a0~a1  | Arguments/ <br> Return Value | Caller |
| x12~x17  | a2~a7  | Arguments                    | Caller |
| x18~x27  | s2~s11 | Saved                        | Callee |
| x28~x31  | t3~t6  | Temp                         | Caller |

<!-- |          |   冲刷   |                 暂停                 | -->
<!-- | :------: | :------: | :----------------------------------: | -->
<!-- |   条件   | 出现跳转 | $出现严重数据冒险\\访存接收busy信号$ | -->
<!-- | 控制信号 |   无效   |                 无效                 | -->
<!-- | 数据信号 |   无效   |                 保持                 | -->

<!-- |       |               [1]               |          [0]           | -->
<!-- | :---: | :-----------------------------: | :--------------------: | -->
<!-- | hold  |    全部pipe_dff停滞,对应busy    | 仅pc,IF_ID停滞,对应nop | -->
<!-- | flush | IF_ID,ID_EX,EX_MEM冲刷,对应jump |   ID_EX冲刷,对应nop    | -->


|       |                 跳转访存指令                  |
| :---: | :-------------------------------------------: |
|  IF   |        jump_addr计算,jump判断是否跳转         |
|  MEM  |  访存:result即mem_addr,根据wmem选择是否写入   |
|  MEM  |    跳转:result计算,判断并存储跳转条件jump     |
|  MEM  |    跳转:result计算,判断并存储跳转条件jump     |
|  WB   | result计算,根据rmem选择写回mem_data还是result |
                
|       |   指令    |  SEL  | 输入1 | 输入2 | CTRL  |
| :---: | :-------: | :---: | :---: | :---: | :---: |
|  IF   |   jalr    |   1   |  rs1  |  imm  |   0   |
|  IF   | cjump/jal |   3   |  PC   |  imm  |   0   |
|  IF   |   ~jump   |   4   |  PC   |   4   |   0   |
| ----- |   -----   | ----- | ----- | ----- | ----- |
|  MEM  |    R/B    |   0   |  rs1  |  rs2  |   1   |
|  MEM  |    I/S    |   1   |  rs1  |  imm  |   1   |
|  MEM  |    lui    |   2   |   0   |  imm  |   1   |
|  MEM  |   auipc   |   3   |  PC   |  imm  |   1   |
|  MEM  | jalr/jal  |   4   |  PC   |   4   |   1   |
| ----- |   -----   | ----- | ----- | ----- | ----- |
|  WB   |   同MEM   | 同MEM | 同MEM | 同MEM | 同MEM |
