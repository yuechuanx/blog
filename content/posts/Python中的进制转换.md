---
title: Python 中的进制转换
slug: convert-number-in-python
toc: true
comments: true
tags:
  - python
date: 2020-12-21 17:51:58

---



> 最近遇到一个情景：
>
> 需要通过串口向控制器发送控制命令，其中控制命令都是 16 进制的字符串，像这样 `AA 1A 00 03 00 00 00 00 22 11 A2 42 0E 00 20 00 40 00 40 00 01 14 7B 40 97 BE`，里面有一些字段是 int 转为 hex。
>
> 这里面涉及到在 Python 中的进制的转换，由于 Python 中的变量赋值不需要类型声明。所以需要一些自定义的函数来控制转换为指定长度的 hex。

## 进制转换

Python 本身提供了进制转换的内置函数：

- `bin()`
-  `oct()`
-   `int()`
-  `hex()`
-  `format()`

```python
>>> n = 1024

>>> bin(n)
'0b10000000000'

>>> oct(n)
'0o2000'

>>> hex(n)
'0x400'

>>> format(n, 'b')
'10000000000'

>>> format(n, 'o')
'2000'

>>> format(n, 'x')
'400'
```

可以看到，Python 中进制在转换后都是字符串类型，而`bin()`, `oct()`, `hex()` 会分别带有 `0b`, `0o`, `0x` 的前缀。

不需要前缀可以使用 `format()` 函数，其声明为`format(value[, format_spec])`

> 个人觉得使用 `format()` 更为方便 

现在来看看当值出现负数的情况

~~~python
>>> n = -1024

>>> format(n, 'x')
'-400'
~~~

这里带有符号位，后面的值与正数的进制转换后结果相同。

## 计算补码

在计算机中所有数值是通过补码来表示的，补码的转换法则是原码取反后+1。

假设数值的存储长度为 16 位，它可以表示 -32768 到 32767的数 。那么现在来看一个负数的补码形式，对应的 16 进制的值。

```python
>>> # 16 位补码
>>> n = -1024
>>> bin(((1 << 16) - 1) & n) # 用 16 位长度Bit AND
'0b1111110000000000'
>>> comp = bin(((1 << 16) - 1) & n)
>>> comp
'0b1111110000000000'
>>> int16 = int(comp, 2)
>>> int16
64512
>>> hex(int16)
'0xfc00'
```

还有一种方式，如果你知道补码真正的含义的话，直接用 `2 ** 16 + n`，得到的就是补码的无符号位表示。

对应地可求出 32 位补码的值

## 定长的进制转换

如何做定长的进制转换呢？这会用到 `zfill()` 函数

```python
>>> n = 1024
>>> format(n, 'x')
'400'
>>> format(n, 'x').zfill(4)
'0400'

```

这样就可以很好的把进制转化为 c 风格的进制了。

```python
def int2hex(n, bit_len=16, hex_len=0):
  	comp = (2 ** bit_len + n) % 2 ** bit_len
	  return format(comp, 'x').zfill(hex_len)
  
def hex2int(n, bit_len=16):
  	if int(n, 16) < 2 ** (bit_len - 1):
      return int(n, 16)
    return int(n, 16) - 2 ** bit_len
```

我们还可以写出其他的长度进制转换。但现在就此打住。

## 总结

- Python 中的进制转换相关的函数
- 如何计算补码
- 如何做定长的进制转换