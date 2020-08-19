---
title: 通过 pySerial 连接串口
categories:
- Python
tags:
- serial
- python
slug: connect-serial-port-via-pyserial
date: 2020-08-10 17:28:56
---

# 通过 pySerial 连接串口

> pySerial 是一个 Python 模块。该模块封装了对串行端口的访问。
>
> 它提供了在Windows，OSX，Linux，BSD（可能是任何POSIX兼容系统）和IronPython上运行的[Python的](http://python.org/)后端。名为 “serial” 的模块会自动选择适当的后端。
>
> 简而言之，pySerial 提供了通过 Python 代码连接串口设备的功能。

<!-- more -->

[toc]

## 安装

```shell
python -m pip install pyserial
# or
pip install pyserial
```

## 基本使用

打开串口设备`/dev/ttyUSB0`，默认波特率 9600，不设置 Timeout

```python
>>> import serial
>>> ser = serial.Serial('/dev/ttyUSB0')  # open serial port
>>> print(ser.name)         # check which port was really used
>>> ser.write(b'hello')     # write a string
>>> ser.close()             # close port
```

打开串口设备`/dev/ttyS1`, 波特率 19200，设置 Timeout 为 1 秒

```Python
>>> with serial.Serial('/dev/ttyS1', 19200, timeout=1) as ser:
...     x = ser.read()          # read one byte
...     s = ser.read(10)        # read up to ten bytes (timeout)
...     line = ser.readline()   # read a '\n' terminated line
```

打开串口 `COM3`, 波特率 38400，不设 Timeout

```Python
>>> ser = serial.Serial('COM3', 38400, timeout=0,
...                     parity=serial.PARITY_EVEN, rtscts=1)
>>> s = ser.read(100)       # read up to one hundred bytes
...                         # or as much is in the buffer
```

动态设置串口属性

先创建 `Serial` 实例，再设置属性，通过 `Serial.open()` 连接串口

```Python
>>> ser = serial.Serial()
>>> ser.baudrate = 19200
>>> ser.port = 'COM1'
>>> ser
Serial<id=0xa81c10, open=False>(port='COM1', baudrate=19200, bytesize=8, parity='N', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
>>> ser.open()
>>> ser.is_open
True
>>> ser.close()
>>> ser.is_open
False
```

支持 `with` 语法 [context manager](https://pyserial.readthedocs.io/en/latest/pyserial_api.html#context-manager):

```python
with serial.Serial() as ser:
    ser.baudrate = 19200
    ser.port = 'COM1'
    ser.open()
    ser.write(b'hello')
```

## 内置工具

pySerial 库中内置了两个工具

- list_ports
- miniterm

### list_ports

list_ports 能列出串口列表，在终端环境下输入 `python -m serial.tool.list_ports -h`

```bash
usage: list_ports.py [-h] [-v] [-q] [-n N] [-s] [regexp]

Serial port enumeration

positional arguments:
  regexp               only show ports that match this regex

optional arguments:
  -h, --help           show this help message and exit
  -v, --verbose        show more messages
  -q, --quiet          suppress all messages
  -n N                 only output the N-th entry
  -s, --include-links  include entries that are symlinks to real devices
  
# 列出可用的串口端口
python -m serial.tools.list_ports -v
/dev/ttyUSB0
    desc: FT232R USB UART
    hwid: USB VID:PID=0403:6001 SER=A90807ZH LOCATION=1-10
/dev/ttyUSB1
    desc: FT232R USB UART
    hwid: USB VID:PID=0403:6001 SER=AC01PSKO LOCATION=1-9
2 ports found
```

在 Python 代码里调用 `serial.tools.list_ports.comports()` 

```python
>>> from serial.tools import list_ports
>>> list_ports.comports()
[<serial.tools.list_ports_linux.SysFS object at 0x7fc2c3ec5460>, <serial.tools.list_ports_linux.SysFS object at 0x7fc2d0aad880>]
```

### miniterm

miniterm 是对 pySerial 进行封装的串口终端，输入 `python -m serial.tools.miniterm -h`:

```bash
usage: miniterm.py [-h] [--parity {N,E,O,S,M}] [--rtscts] [--xonxoff]
                   [--rts RTS] [--dtr DTR] [-e] [--encoding CODEC] [-f NAME]
                   [--eol {CR,LF,CRLF}] [--raw] [--exit-char NUM]
                   [--menu-char NUM] [-q] [--develop]
                   [port] [baudrate]

Miniterm - A simple terminal program for the serial port.

positional arguments:
  port                  serial port name
  baudrate              set baud rate, default: 9600

optional arguments:
  -h, --help            show this help message and exit

port settings:
  --parity {N,E,O,S,M}  set parity, one of {N E O S M}, default: N
  --rtscts              enable RTS/CTS flow control (default off)
  --xonxoff             enable software flow control (default off)
  --rts RTS             set initial RTS line state (possible values: 0, 1)
  --dtr DTR             set initial DTR line state (possible values: 0, 1)
  --ask                 ask again for port when open fails

data handling:
  -e, --echo            enable local echo (default off)
  --encoding CODEC      set the encoding for the serial port (e.g. hexlify,
                        Latin1, UTF-8), default: UTF-8
  -f NAME, --filter NAME
                        add text transformation
  --eol {CR,LF,CRLF}    end of line mode
  --raw                 Do no apply any encodings/transformations

hotkeys:
  --exit-char NUM       Unicode of special character that is used to exit the
                        application, default: 29
  --menu-char NUM       Unicode code of special character that is used to
                        control miniterm (menu), default: 20

diagnostics:
  -q, --quiet           suppress non-error messages
  --develop             show Python traceback on error
```

用 miniterm.py 进入串口环境

```bash
miniterm.py /dev/ttyUSB1 115200
--- Miniterm on /dev/ttyUSB1  115200,8,N,1 ---
--- Quit: Ctrl+] | Menu: Ctrl+T | Help: Ctrl+T followed by Ctrl+H ---


/ #
```

## 案例：向串口写入以及读取

```python
import serial

device = serial.Serial('/dev/ttyUSB1', 115200)
while True:
  str_in = input()
  device.write((str_in + '\n').encode())
  str_out = device.read_all().decode('utf-8')
  print(str_out)
```

这段代码从输入读取，通过串口向设备写入，再从串口中读取返回的值打印出来。



