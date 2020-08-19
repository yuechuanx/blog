---
title: 如何让你的代码更 Pythonic
slug: make-your-code-more-pythonic
categories:
  - Python
tags: 
  - python
  - codestyle
date: 2020-08-13 16:35:34
---

本次 share 介绍如何写出更 pythonic 的 python 代码。

从两个方面切入:

第一个方面是介绍 python 的代码风格规范，以目前实践中事实规范 pep8 为标准。

第二个方面是介绍 python 的一些语言特性，如何利用这些特写编写更优雅的 python 代码

[toc]

## 1. PEP 8: Style Guide for Python Code

以下所有内容包含在官方 PEP(Python Enhancement Proposals) 链接为 [pep8][https://www.python.org/dev/peps/pep-0008/]

简要版本

- 代码编排

  - 缩进。4个空格的缩进（编辑器都可以完成此功能），不使用Tap，更不能混合使用Tap和空格

    > 针对不同编辑器兼容性，对 tab 可能有不同的标准，导致样式不统一。

  - 每行最大长度79，换行可以使用反斜杠，最好使用圆括号。换行点要在操作符的后边敲回车。

    > 早期 unix 主机终端只能显示 80 个字符。
    >
    > 通过限制所需的编辑器窗口宽度，可以并排打开多个文件，并且在使用在相邻列中显示两个版本的代码查看工具时，效果很好。

  - 类和top-level函数定义之间空两行；

    类中的方法定义之间空一行；

    函数内逻辑无关段落之间空一行；

    其他地方尽量不要再空行。

- 文档编排

  - 模块内容的顺序：

    模块说明和docstring

    import

    globals&constants

    其他定义。

    其中import部分，又按标准、三方和自己编写顺序依次排放，之间空一行。

  - 不要在一句import中多个库，比如import os, sys不推荐。
    如果采用from XX import XX引用库，可以省略‘module.’，都是可能出现命名冲突，这时就要采用import XX。

    如果有命名冲突。可以使用 `from X import Y as Z`

- 空格的使用
  总体原则，避免不必要的空格。

  - 各种右括号前不要加空格。
  - 逗号、冒号、分号前不要加空格。
  - 函数的左括号前不要加空格。如Func(1)。
  - 序列的左括号前不要加空格。如list[2]。
  - 操作符左右各加一个空格，不要为了对齐增加空格。
  - 函数默认参数使用的赋值符左右省略空格。
  - 不要将多句语句写在同一行，尽管使用‘；’允许。
  - if/for/while语句中，即使执行语句只有一句，也必须另起一行。

- 命名规范
  总体原则，新编代码必须按下面命名风格进行，现有库的编码尽量保持风格。

  - 尽量单独使用小写字母‘l’，大写字母‘O’等容易混淆的字母。
  - 模块命名尽量短小，使用全部小写的方式，可以使用下划线。
  - 包命名尽量短小，使用全部小写的方式，不可以使用下划线。
  - 类的命名使用CapWords的方式，模块内部使用的类采用_CapWords的方式。_
  - 异常命名使用CapWords+Error后缀的方式。
  - 全局变量尽量只在模块内有效，类似C语言中的static。实现方法有两种，一是__all__机制;二是前缀一个下划线
  - 函数命名使用全部小写的方式，可以使用下划线。
  - 常量命名使用全部大写的方式，可以使用下划线。
  - 类的属性（方法和变量）命名使用全部小写的方式，可以使用下划线。
  - 类的属性有3种作用域public、non-public和subclass API，可以理解成C++中的public、private、protected，non-public属性前，前缀一条下划线。
  - 类的属性若与关键字名字冲突，后缀一下划线，尽量不要使用缩略等其他方式。
  - 为避免与子类属性命名冲突，在类的一些属性前，前缀两条下划线。比如：类Foo中声明__a,访问时，只能通过Foo._Foo__a，避免歧义。如果子类也叫Foo，那就无能为力了。
  - 类的方法第一个参数必须是self，而静态方法第一个参数必须是cls。

- 注释
  总体原则，错误的注释不如没有注释。所以当一段代码发生变化时，第一件事就是要修改注释！
  注释必须使用英文，最好是完整的句子，首字母大写，句后要有结束符，结束符后跟两个空格，开始下一句。如果是短语，可以省略结束符。
  
  - 块注释，在一段代码前增加的注释。在‘#’后加一空格。段落之间以只有‘#’的行间隔。比如：
  ```
  # Description : Module config.
  #
  
  # Input : None
  #
  # Output : None
  ```
  
  - 行注释，在一句代码后加注释。比如：x = x + 1 # Increment x
  但是这种方式尽量少使用。可以在 Magic Number 时使用。
  - 避免无谓的注释。
  
- 文档描述
  1 为所有的共有模块、函数、类、方法写docstrings；非共有的没有必要，但是可以写注释（在def的下一行）。
  2 如果docstring要换行，参考如下例子,详见PEP 257
  ```shell
  """Return a foobang
  
  Optional plotz says to frobnicate the bizbaz first.
  
  """
  ```
  
- 编码建议
  
  - 编码中考虑到其他python实现的效率等问题，比如运算符‘+’在CPython（Python）中效率很高，都是Jython中却非常低，所以应该采用.join()的方式。
    2 尽可能使用`i`
  - `s` `is not`取代`==`，比如`if x is not None` 要优于`if x`。
    3 使用基于类的异常，每个模块或包都有自己的异常类，此异常类继承自Exception。
  4 异常中不要使用裸露的except，except后跟具体的exceptions。
    5 异常中try的代码尽可能少。比如：
  
    ```
    try:
    value = collection[key]
    except KeyError:
    return key_not_found(key)
    else:
    return handle_value(value)

    要优于
    try:
    # Too broad!
    return handle_value(collection[key])
    except KeyError:
    # Will also catch KeyError raised by handle_value()
    return key_not_found(key)
    ```
  - 使用startswith() and endswith()代替切片进行序列前缀或后缀的检查。比如
    ```
    Yes: if foo.startswith(‘bar’):优于
    No: if foo[:3] == ‘bar’:
    - 使用isinstance()比较对象的类型。比如
    Yes: if isinstance(obj, int): 优于
    No: if type(obj) is type(1):
    ```
  - 判断序列空或不空，有如下规则
    ```
    Yes: if not seq:
    if seq:
    优于
    No: if len(seq)
    if not len(seq)
    ```
  - 字符串不要以空格收尾。
  -  二进制数据判断使用 if boolvalue的方式。

## 2.Effictive python 

在第一部分介绍了 Python Codestyle 接受度最广泛的 pep8 后，要想能够写出 pythonic 的代码仍然是不够的。Python 语言有着丰富的语法特性，能让 Python 代码十分优雅。

接下来介绍的这部分的内容来源于 「 Effective Python 」。

本次只会介绍一部分有用的特性，结合实际的例子来完成。

### 内置序列类型概览

* 容器序列  
  `list`、`tuple` 和 `collections.deque` 这些序列能存放不同类型的数据。
* 扁平序列  
  `str`、`bytes`、`bytearray`、`memoryview` 和 `array.array`，这类序列只能容纳一种类型。

容器序列存放的是它们所包含的任意类型的对象的**引用**，而扁平序列里存放的**是值而不是引用**。换句话说，扁平序列其实是一段连续的内存空间。由此可见扁平序列其实更加紧凑，但是它里面只能存放诸如字符、字节和数值这种基础类型。

序列类型还能按照能否被修改来分类。

* 可变序列  
  `list`、`bytearray`、`array.array`、`collections.deque` 和 `memoryview`。
* 不可变序列  
  `tuple`、`str` 和 `bytes`

### 列表推导和生成器表达式

#### 列表推导和可读性

列表推导是构建列表(list)的快捷方式，生成器表达式用来穿件其他任何类型的序列。


```python
# 比较两段代码
symbols = 'abcde'

codes = []
for symbol in symbols:
    codes.append(ord(symbol))    
print(codes)

codes = [ord(symbol) for symbol in symbols]
print(codes)
```

列表推导能够提升可读性。
只用列表推导来创建新的列表，并尽量保持简短（不要超过一行）

###  列表推导同 filter 和 map 的比较


```python
symbols = 'abcde'

beyond_ascii = [ord(s) for s in symbols if ord(s) > 100]
print(beyond_ascii)

beyond_ascii = list(filter(lambda c: c > 100, map(ord, symbols)))
print(beyond_ascii)
```

    [101]
    [101]


### 笛卡尔积


```python
colors = ['black', 'white'] 
sizes = ['S', 'M', 'L']

tshirts = [(color, size) for color in colors 
                         for size in sizes]
print(tshirts)

tshirts = [(color, size) for size in sizes
                         for color in colors]
print(tshirts)
# 注意顺序是依照 for-loop 嵌套关系
```

    [('black', 'S'), ('black', 'M'), ('black', 'L'), ('white', 'S'), ('white', 'M'), ('white', 'L')]
    [('black', 'S'), ('white', 'S'), ('black', 'M'), ('white', 'M'), ('black', 'L'), ('white', 'L')]


### 生成器表达式

列表推导与生成器表达式的区别：

- 生成器表达式遵守实现了迭代器接口，可以逐个地产出元素。
- 列表推导是先建立一个完整的列表，再将这个列表传递到构造函数里。
- 语法上近似，方括号换成圆括号


```python
# symbols = 'abcde'
print(tuple(ord(symbol) for symbol in symbols))

import array
print(array.array('I', (ord(symbol) for symbol in symbols)))
```

- 如果生成器表达式是一个函数调用过程中的唯一参数，则不需要额外括号
- 生成器会在 for-loop 运行时才生成一个组合。逐个产出元素


```python
colors = ['black', 'white'] 
sizes = ['S', 'M', 'L']

for tshirt in ('%s %s' %(c, s) for c in colors for s in sizes):
    print(tshirt)
```

    black S
    black M
    black L
    white S
    white M
    white L


### 元祖不仅仅是不可变的列表

#### 元祖与记录

- 元祖是对数据的记录
- 元祖的位置信息为数据赋予了意义。对元祖内元素排序，位置信息将丢失


```python
# LA 国际机场经纬度
lax_coordinates = (33.9425, -118.408056)
# 城市，年份，人口（单位：百万），人口变化（单位：百分比），面积
city, year, pop, chg, area = ('Tokyo', 2003, 32450, 0.66, 8014)
# country_code, passport number
traveler_ids = [('USA', '31195855'), ('BBA', 'CE342567'), ('ESP', 'XDA205856')]

for passport in sorted(traveler_ids):
    print('%s%s' % passport)

# 拆包（unpacking）
for country, _ in traveler_ids:
    print(country)
```

    BBACE342567
    ESPXDA205856
    USA31195855
    USA
    BBA
    ESP


#### 元祖拆包

- 平行赋值


```python
lax_coordinates = (33.9425, -118.408056)
# 元祖拆包
latitude, longtitude = lax_coordinates
print(latitude)
print(longtitude)
```

    33.9425
    -118.408056


- 交换变量值，不使用中间变量


```python
a = 3
b = 4
b, a = a, b
print(a)
print(b)
```

    4
    3


- `*` 运算符，把一个可迭代对象拆开作为函数参数


```python
divmod(20, 8)

t = (20, 8)
divmod(*t)

quotient, remainder = divmod(*t)
print(quotient)
print(remainder)
```

    2
    4


- 函数用元祖形式返回多个值

> _ 用作占位符，可以用来处理不需要的数据


```python
import os

_, filename = os.path.split('/home/xiao/.ssh/id_rsa.pub')
print(filename)
```

    id_rsa.pub


- 用`*` 处理省下的元素


```python
a, b, *rest = range(5)
print(a, b, rest)

a, b, *rest = range(3)
print(a, b, rest)

a, b, *rest = range(2)
print(a, b, rest)

# * 前缀只能用在一个变量前，该变量可出现在赋值表达式中任意位置
a, *body, c, d = range(5)
print(a, body, c, d)

*head, b, c, d = range(5)
print(head, b, c, d)
```

    0 1 [2, 3, 4]
    0 1 [2]
    0 1 []
    0 [1, 2] 3 4
    [0, 1] 2 3 4


#### 嵌套元祖拆包

```python
metro_areas = [
    ('Tokyo', 'JP', 36.933, (35.689722, 139.691667)),   # <1>
    ('Delhi NCR', 'IN', 21.935, (28.613889, 77.208889)),
    ('Mexico City', 'MX', 20.142, (19.433333, -99.133333)),
    ('New York-Newark', 'US', 20.104, (40.808611, -74.020386)),
    ('Sao Paulo', 'BR', 19.649, (-23.547778, -46.635833)),
]

print('{:15} | {:^9} | {:^9}'.format('', 'lat.', 'long.'))
fmt = '{:15} | {:9.4f} | {:9.4f}'
for name, cc, pop, (latitude, longitude) in metro_areas:  # <2>
    if longitude <= 0:  # <3>
        print(fmt.format(name, latitude, longitude))
```

                    |   lat.    |   long.  
    Mexico City     |   19.4333 |  -99.1333
    New York-Newark |   40.8086 |  -74.0204
    Sao Paulo       |  -23.5478 |  -46.6358


将元祖作为记录仍缺少一个功能：字段命名

#### 具名元祖(numedtuple)

`collections.namedtuple` 是一个工厂函数，用来构建带字段名的元祖和一个有名字的

> namedtuple 构建的类的实例所消耗的内存和元祖是一样的，因为字段名都存在对应的类里。
> 实例和普通的对象实例小一点，因为 Python 不会用 `__dict__` 存放实例的属性


```python
from collections import namedtuple

# 需要两个参数，类名和类各个字段的名字
City = namedtuple('City', 'name country population coordinates')
tokyo = City('Tokyo', 'JP', 36.933, (35.689722, 129.691667))
print(tokyo)
print(tokyo.population)
print(tokyo.coordinates)
```

    City(name='Tokyo', country='JP', population=36.933, coordinates=(35.689722, 129.691667))
    36.933
    (35.689722, 129.691667)


`namedtuple` 除了从普通元祖继承的属性外，还有一些专有属性。
常用的有：

- `_fields` 类属性
- `_make(iterable)` 类方法
- `_asdict()` 实例方法


```python
print(City._fields)
LatLong = namedtuple('LatLong', 'lat long')
delhi_data = ('Delhi NCR', 'IN', 21.935, LatLong(28.613889, 77.208889))
delhi = City._make(delhi_data)
print(delhi._asdict())

for key, value in delhi._asdict().items():
    print(key + ':', value)
```

    ('name', 'country', 'population', 'coordinates')
    OrderedDict([('name', 'Delhi NCR'), ('country', 'IN'), ('population', 21.935), ('coordinates', LatLong(lat=28.613889, long=77.208889))])
    name: Delhi NCR
    country: IN
    population: 21.935
    coordinates: LatLong(lat=28.613889, long=77.208889)

### 切片

在 Python 里, 列表（list），元祖（tuple）和字符串（str）这类序列类型都支持切片操作

#### 为什么切片的区间会忽略最后一个元素

- Python 以0 作为起始下标
- 当只有后一个位置信息时，可以快速导出切片和区间的元素数量
- 当起止位置信息课件是，可以快速计算出切片和区间的长度 （stop - start）
- 可利用任意一个下标把序列分割成不重叠的两部分。`my_list[:x]` `my_list[x:]`


```python
### 对对象进行切片

- 可以通过 s[a:b:c] 的形式对 s 在 a 和 b 区间以 c 为间隔取值
```


```python
s = 'bicycle'
print(s[::3])
print(s[::-1])
print(s[::-2])
```

    bye
    elcycib
    eccb


#### 多维切片和省略

`[]` 运算符可以使用以逗号分开的多个索引或切片。

如 `a[i, j]`，`a[m:n, k:1]`得到二维切片

要正确处理`[]` 运算符，对象的特殊方法 `__getitem__`，`__setitem__` 需要以元祖的形式来接受 `a[i, j]`的索引。

#### 给切片赋值

切片放在赋值语句左边，或作为 del 操作对象，可以对序列进行嫁接、切除或就地修改


```python
l = list(range(10))
print(l)

l[2:5] = [20, 30]
print(l)

del l[5:7]
print(l)

l[3::2] = [11, 22]
print(l)

# l[2:5] = 100 WRONG
```

    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    [0, 1, 20, 30, 5, 6, 7, 8, 9]
    [0, 1, 20, 30, 5, 8, 9]
    [0, 1, 20, 11, 5, 22, 9]


### 对序列使用 + 和 * 

- `+` 和 `*` 不修改原有的操作对象，而是构建一个新的序列


```python
l = [1, 2, 3]
print(l * 5)

print(5 * 'abcd')
```

    [1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
    abcdabcdabcdabcdabcd


#### 建立由列表组成的列表

> a * n，如果在序列 a 中存在对其他可变变量的引用的话，得到的序列中包含的是 n 个对指向同一地址的引用 


```python
board = [['_'] * 3 for i in range(3)]
# 换一种形式
# board = []
# for i in range(3):
#     row = ['_'] * 3
#     board.append(row)
print(board)
board[1][2] = 'X'
print(board)

    
# weird_board = [['_'] * 3] * 3
# 换一种形式
weird_board = []
row = ['_'] * 3
for i in range(3):
    weird_board.append(row)
weird_board[1][2] = 'O'
# 会发现 3 个指向同一列表的引用
print(weird_board)


```

    [['_', '_', '_'], ['_', '_', '_'], ['_', '_', '_']]
    [['_', '_', '_'], ['_', '_', 'X'], ['_', '_', '_']]
    [['_', '_', 'O'], ['_', '_', 'O'], ['_', '_', 'O']]


### 序列的增量赋值 +=、*=

- `+=` 背后的特殊方法是 `__iadd__` 方法，没有则退一步调用 `__add__`
- 同理 `*=` 的特殊方法是 `__imul__`


```python
l = [1, 2, 3]
print(id(l))

l *= 2
print(l)
# 列表ID 无改变
print(id(l))

t = (1, 2, 3)
print(id(t))
t *= 2
print(t)
# 新元祖被创建
print(id(t))
```

    4534358344
    [1, 2, 3, 1, 2, 3]
    4534358344
    4536971408
    (1, 2, 3, 1, 2, 3)
    4546754024


### list.sort方法和内置函数sorted

- list.sort 会就地排序列表，方法返回值为 None
- sorted 会新建一个列表作为返回值
- 两个方法都有 reverse 和 key 作为可选的关键字参数
  reserve 为 True 时，降序输出。默认为 false
  key 只有一个参数的函数，将被用在序列的每一个元素上，其结果作为排序算法依赖的对比关键字


### 用bisect管理已排序的序列

bisect 模块有两个主要函数：

- bisect
- insort
  都利用二分查找法来在有序序列中查找或插入人元素

#### 用 bisect 来搜索

bisect(haystack, needle) 默认为升序，haystack 需要保持有序。
使用方法：
bisect(index, needle) 查找位置 index，再使用 haystack.insert(index, needle) 插入新值

也可以用 insort 来一步到位，且后者速度更快


```python
# BEGIN BISECT_DEMO
import bisect
import sys

HAYSTACK = [1, 4, 5, 6, 8, 12, 15, 20, 21, 23, 23, 26, 29, 30]
NEEDLES = [0, 1, 2, 5, 8, 10, 22, 23, 29, 30, 31]

ROW_FMT = '{0:2d} @ {1:2d}    {2}{0:<2d}'

def demo(bisect_fn):
    for needle in reversed(NEEDLES):
        position = bisect_fn(HAYSTACK, needle)  # <1>
        offset = position * '  |'  # <2>
        print(ROW_FMT.format(needle, position, offset))  # <3>

if __name__ == '__main__':

    if sys.argv[-1] == 'left':    # <4>
        bisect_fn = bisect.bisect_left
    else:
        bisect_fn = bisect.bisect

    print('DEMO:', bisect_fn.__name__)  # <5>
    print('haystack ->', ' '.join('%2d' % n for n in HAYSTACK))
    demo(bisect_fn)

# END BISECT_DEMO
```

    DEMO: bisect_right
    haystack ->  1  4  5  6  8 12 15 20 21 23 23 26 29 30
    31 @ 14      |  |  |  |  |  |  |  |  |  |  |  |  |  |31
    30 @ 14      |  |  |  |  |  |  |  |  |  |  |  |  |  |30
    29 @ 13      |  |  |  |  |  |  |  |  |  |  |  |  |29
    23 @ 11      |  |  |  |  |  |  |  |  |  |  |23
    22 @  9      |  |  |  |  |  |  |  |  |22
    10 @  5      |  |  |  |  |10
     8 @  5      |  |  |  |  |8 
     5 @  3      |  |  |5 
     2 @  1      |2 
     1 @  1      |1 
     0 @  0    0 


#### Array

> 虽然列表既灵活又简单，但面对各类需求时，我们可能会有更好的选择。比如，要存放 1000 万个浮点数的话，数组（array）的效率要高得多，因为数组在背后存的并不是 float 对象，而是数字的机器翻译，也就是字节表述。这一点就跟 C 语言中的数组一样。再比如说，如果需要频繁对序列做先进先出的操作，deque（双端队列）的速度应该会更快。

`array.tofile` 和 `fromfile` 可以将数组以二进制格式写入文件，速度要比写入文本文件快很多，文件的体积也小。

> 另外一个快速序列化数字类型的方法是使用 pickle（https://docs.python.org/3/library/pickle.html）模块。pickle.dump 处理浮点数组的速度几乎跟array.tofile 一样快。不过前者可以处理几乎所有的内置数字类型，包含复数、嵌套集合，甚至用户自定义的类。前提是这些类没有什么特别复杂的实现。

array 具有 `type code` 来表示数组类型：具体可见 [array 文档](https://docs.python.org/3/library/array.html).

#### memoryview

> memoryview.cast 的概念跟数组模块类似，能用不同的方式读写同一块内存数据，而且内容字节不会随意移动。


```python
import array

arr = array.array('h', [1, 2, 3])
memv_arr = memoryview(arr)
# 把 signed short 的内存使用 char 来呈现
memv_char = memv_arr.cast('B') 
print('Short', memv_arr.tolist())
print('Char', memv_char.tolist())
memv_char[1] = 2  # 更改 array 第一个数的高位字节
# 0x1000000001
print(memv_arr.tolist(), arr)
print('-' * 10)
bytestr = b'123'
# bytes 是不允许更改的
try:
    bytestr[1] = '3'
except TypeError as e:
    print(repr(e))
memv_byte = memoryview(bytestr)
print('Memv_byte', memv_byte.tolist())
# 同样这块内存也是只读的
try:
    memv_byte[1] = 1
except TypeError as e:
    print(repr(e))

```

#### Deque

`collections.deque` 是比 `list` 效率更高，且**线程安全**的双向队列实现。

除了 collections 以外，以下 Python 标准库也有对队列的实现：

* queue.Queue (可用于线程间通信)
* multiprocessing.Queue (可用于进程间通信)
* asyncio.Queue
* heapq