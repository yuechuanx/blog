---
title: 基于 Pexpect 在开发板执行 TestCase
slug: execute-testcase-on-the-development-board-based-pexpect
tags:
- python
- expect
- jenkins
date: 2020-08-03 16:47:26
---
#  基于 Pexpect 在开发板执行 TestCase

## 问题场景

在大多数嵌入式工程环境下，我们通过串口或者网口连接开发板，进行测试或调试。

带有固定步骤，且可通过输出判断执行结果的 TestCase，可以将其转为自动化测试。

通过 ssh 连接开发板，测试用例可以是 Expect 脚本，或者为了方便生成测试报告，使用 Python Unittest 框架。可以通过 Pexpect （Expect 的 Python 实现）来达到目标。

## 环境搭建

- jenkins 
- Python lib: pexpect

## 实现

