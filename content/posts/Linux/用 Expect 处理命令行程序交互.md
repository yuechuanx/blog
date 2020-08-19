---
title: 用 Expect 处理命令行程序交互
slug: linuxuse-expect-to-handle-command-line-program-interaction
categories:
  - Linux
date: 2020-07-14 11:10:36
---
# 用 Expect 处理命令行程序交互

shell 把程序交互的特性留给了用户，这意味着有些程序，不能脱离用户输入。比如 passwd 命令。

expect 能够调用其他 unix 程序，处理交互操作。

## Expect 脚本登录 SSH 

先看一个通过 expect 脚本 SSH 到远程主机的示例：

```bash
#!/usr/bin/expect

set host "192.168.199.231"
set user "xiao"
set password "xiao"

spawn ssh '$user@$host'

expect {
    "*(yes/no)?" {
        send "yes\r"
        exp_continue
    }
    "*password:" {
        send "$password\r"
    }
    timeout {
        puts "timed out",exit 
    }
}

interact
```

这里注意到两个重要的关键字：`spawn`，`expect`

下面对 expect 语法里的关键字作介绍

## Keyword

`spawn`： 调用其他 unix 程序，生成新进程

`expect`: 处理其他程序的输出，对于匹配到的输出可以触发操作

`set`: 全局变量赋值

`send`: 发送字符指令，支持特殊字符 `\r` 回车, `\x03` Ctrl+c 等等

`puts`: 发送字符到标准输出

`interact`: 交互控制权切换到用户

##  FlowControl

- for-loop

~~~tcl
for {} {} {} {
	...
}

// eg:
for {set i 0} { i < 10} {incr 1} {
	...
}

// Endless loop
for {} 1 {} {
	...
}
~~~

- while-loop

~~~tcl
while { EXPRESSION } {
	...
}
~~~

- if-else

~~~tcl
if { EXPRESSION } {
	...
} else {
	...
}
~~~

## Match-Operation

~~~tcl
expect {
  PATTERN1 {
  	DO_SOMETHING
  } 
  PATTERN2 {
  	DO_SOMETHING_ELSE
  }
  timeout {
  	exit
  }
}
~~~

## 接收参数传入

~~~tcl
# 命令行参数 
# $argv，参数数组，使用[lindex $argv n]获取，$argv 0为脚本名字
# $argc，参数个数
set username [lindex $argv 1]  # 获取第1个参数
set passwd [lindex $argv 2]    # 获取第2个参数
~~~

## Function

~~~tcl
# params


set timeout         5
set now             [clock seconds]
set date            [clock format $now -format {%Y%m%d-%H%M}]
log_file -noappend   exp/log/xvr_autotest_$date.log

# picocom config
set baudrate        "1000000"
set device          [lindex $argv 0];

proc test_reboot { interval } {
	send "reboot\r"
	sleep $interval
}

proc test_some_function {} {

}

proc main {} {
	set interval 5
	test_reboot $interval
	test_some_function
}

spawn picocom -b $baudrate -f x $device
expect "Terminal ready" {
    send "\r"
}

main
~~~

以上，通过 expect 调用了 picocom (串口命令行工具) 连接到串口，去执行重启命令。

## Reference

- [expect教程中文版](http://xstarcd.github.io/wiki/shell/expect_handbook.html)
- [expect说明](http://xstarcd.github.io/wiki/shell/expect_description.html)
- [expect命令][https://man.linuxde.net/expect1]

