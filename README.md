# Self Evaluation System with Configuration / SESC

## 用途

该项目的用途是在 OI 比赛中途批量测试大样例。

## 项目描述

该项目包含一个主程序代码 selfeval.cpp 和若干个自定义 checker。

## 配置文件

每行包含三个字符串和两个数字，按顺序分别为题目名，checker 名，文件格式串，样例数量，限时（单位为毫秒）。

其中，格式串中要求有且仅有一个 `{}` 用来指示填放数字的位置。

## 使用要求

selfeval.cpp 需要使用支持 C++20 及以上标准的编译器编译。

所有代码必须存放在与代码同名的子文件夹内，且必须使用文件 IO，后缀名分别为 .in/.out，答案文件后缀必须为 .ans。

答案文件必须为一个固定的模式+一个固定位置的数字，必须从 $1$ 开始编号，不能有前导零。

~~checker 源代码文件必须放在与 selfeval.cpp 相同的位置下。~~现在需要通过在运行时通过程序参数的方式指定根目录。

建议使用 testlib 编写 checker。

config.txt 文件放在**存放代码的根目录**下。

## 使用方法

使用下方代码编译 selfeval.cpp：

```bash
g++ selfeval.cpp -std=c++20 -O2 -o selfeval --static
```

随后编写 config.txt，运行 selfeval.exe 即可。
