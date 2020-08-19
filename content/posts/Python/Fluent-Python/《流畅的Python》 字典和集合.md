---
title: 《流畅的Python》 字典和集合
toc: true
comments: true
tags:
  - python
categories:
  - Python
  - Fluent-Python
slug: fluent-python-dict-and-collections
date: 2019-12-24 16:08:14
---
> 字典这个数据结构活跃在所有 Python 程序的背后，即便你的源码里并没有直接用到它。  
> ——A. M. Kuchling 

`dict` 是 Python 语言的基石。

可散列对象需要实现 `__hash__` 和 `__eq__` 函数。  
如果两个可散列对象是相等的，那么它们的散列值一定是一样的。

## 范映射类型

collections.abc 模块中有 Mapping 和 MutableMapping 两个抽象基类，起作用是为 dict 和其他类似的类型定义形式接口。

//pic

但非抽象映射类型一般不会直接继承这些抽象基类，而是直接对 dict 或 collections.User.Dict 进行扩展。

这些抽象基类的主要作用是作为形式化的文档，以及跟 isinstance 一起被用来判定某个数据是否为广义上的映射类型。


```python
my_dict = {}
isinstance(my_dict, collections.abc.Mapping)
```




    True



> 用 instance 而不是用 type 是用来避免参数可能不是 dict 而是其他的映射类型

标准库的所有映射类型都是利用 dict 实现。

什么是可散列的数据类型？


字典的提供了多种构造方法
link


```python
# 字典提供了很多种构造方法
a = dict(one=1, two=2, three=3)
b = {'one': 1, 'two': 2, 'three': 3} 
c = dict(zip(['one', 'two', 'three'], [1, 2, 3])) 
d = dict([('two', 2), ('one', 1), ('three', 3)]) 
e = dict({'three': 3, 'one': 1, 'two': 2})
a == b == c == d == e
```




    True



## 字典推导

字典推导（dictcomp）可以从任何以键值对为元素的可迭代对象构建出字典


```python
DIAL_CODES = [
    (86, 'China'),
    (91, 'India'),
    (1, 'United States')
]

country_code = {country: code for code, country in DIAL_CODES}
country_code
```




    {'China': 86, 'India': 91, 'United States': 1}



## 常见的映射方法

dict、defaultdict、OrderedDict 的常见方法，后两个数据类型是 dict 的变种，位于 collections 模块内。

- setdefault 处理找不到的键

    d[k] 无法找到正确的键时，会抛出异常。

    用 d.get(k, default) 来代替 d[k], 可以对找不到的键设置默认返回值。


```python
"""
03-dict-set/index0.py
创建一个从单词到其出现频率的映射
"""

import sys
import re

WORD_RE = re.compile(r'\w+')

index = {}
with open(sys.argv[1], encoding='uft-8') as fp:
    for line_no, line in enumerate(fp, 1):
        for match in WORD_RE.finditer(line):
            word = match.group()
            column_no = match.start() + 1
            location = (line_no, column_no)
            # 提取单词出现情况，如果没有出现过返回 []
            occurences = index.get(word, [])
            occurences.append(location)
            index[word] = occurences

# 以字符顺序打印结果
for word in sorted(index, key=str.upper):
    print(word, index[word])
```

```sh
$ python index0.py zen.txt
a [(19, 48), (20, 53)]
Although [(11, 1), (16, 1), (18, 1)]
ambiguity [(14, 16)]
and [(15, 23)]
are [(21, 12)]
aren [(10, 15)]
at [(16, 38)]
bad [(19, 50)]
be [(15, 14), (16, 27), (20, 50)]
beats [(11, 23)]
Beautiful [(3, 1)]
better [(3, 14), (4, 13), (5, 11), (6, 12), (7, 9), (8, 11), (17, 8), (18, 25)]
break [(10, 40)]
by [(1, 20)]
cases [(10, 9)]
complex [(5, 23)]
...

```

使用 dict.setdefault


```python
"""
03-dict-set/index.py
创建一个从单词到其出现频率的映射
"""

import sys
import re

WORD_RE = re.compile(r'\w+')

index = {}
with open(sys.argv[1], encoding='uft-8') as fp:
    for line_no, line in enumerate(fp, 1):
        for match in WORD_RE.finditer(line):
            word = match.group()
            column_no = match.start() + 1
            location = (line_no, column_no)
            # 注意这行与上面的区别
            index.setdefault(word, []).append(location)
            # 效果等同于：
            # if key not in my_dict:
            #    my_dict[key] = []
            # my_dict[key].append(new_value)

# 以字符顺序打印结果
for word in sorted(index, key=str.upper):
    print(word, index[word])
```

## 映射的弹性键查询

某个键不存在时，希望读取时能得到一个默认值，有两个方式：
- 通过 defaultdict 类型
- 自定义 dict 子类

### defaultdict 处理找不到的键



```python
"""
03-dict-set/index_default.py
创建一个从单词到其出现频率的映射
"""

import sys
import re
import collections

WORD_RE = re.compile(r'\w+')

index = collections.defaultdict(list)     
with open(sys.argv[1], encoding='utf-8') as fp:
    for line_no, line in enumerate(fp, 1):
        for match in WORD_RE.finditer(line):
            word = match.group()
            column_no = match.start()+1
            location = (line_no, column_no)
            # index 如何没有 word 的记录， default_factory 会被调用，这里是创建一个空列表返回
            index[word].append(location)  

# print in alphabetical order
for word in sorted(index, key=str.upper):
    print(word, index[word])

```

defaultdict 里的 default_factory 只在 __getitem__ 里调用。
实际上，上面的机制是通过特殊方法 __missing__ 支持的。

### __missing__

如果 dict 继承类提供了 __missing__ 方法，且 __getitem__ 遇到找不到键的情况是会自动调用它，而不是抛出异常



```python
class StrKeyDict0(dict):  # <1>

    def __missing__(self, key):
        if isinstance(key, str):  # <2>
            raise KeyError(key)
        return self[str(key)]  # <3>

    def get(self, key, default=None):
        try:
            return self[key]  # <4>
        except KeyError:
            return default  # <5>

    def __contains__(self, key):
        return key in self.keys() or str(key) in self.keys()  # <6>

d = StrKeyDict0([('2', 'Two'), ('4', 'Four')])
print(d['2'])
print(d['4'])
# d[1] error

print(d.get('2'))
print(d.get('4'))
print(d.get(1, 'N/A'))

# defaultdcit & __missing__
class mydefaultdict(dict):
    def __init__(self, value, value_factory):
        super().__init__(value)
        self._value_factory = value_factory

    def __missing__(self, key):
        # 要避免循环调用
        # return self[key]
        self[key] = self._value_factory()
        return self[key]

d = mydefaultdict({1:1}, list)
print(d[1])
print(d[2])
d[3].append(1)
print(d)
```

    Two
    Four
    Two
    Four





    'N/A'



## 字典的变种

> 此节总结了标准库 collections 模块中，除了 defaultdict 之外的不同映射类型

- collections.OrderedDict

- collections.ChainMap 

    容纳多个不同的映射对象，然后在进行键查找操作时会从前到后逐一查找，直到被找到为止

- collections.Counter

- collections.UserDict

    dict 的纯 Python 实现，让用户集成写子类的



```python
# UserDict
# 定制化字典时，尽量继承 UserDict 而不是 dict
from collections import UserDict

class mydict(UserDict):
    def __getitem__(self, key):
        print('Getting key', key)
        return super().__getitem__(key)

d = mydict({1:1})
print(d[1], d[2])
```


```python
# MyppingProxyType 用于构建 Mapping 的只读实例
from types import MappingProxyType

d = {1: 1}
d_proxy = MappingProxyType(d)
print(d_proxy[1])
try:
    d_proxy[1] = 1
except Exception as e:
    print(repr(e))

d[1] = 2
print(d_proxy[1])
```


```python
# set 的操作
# 子集 & 真子集
a, b = {1, 2}, {1, 2}
print(a <= b, a < b)

# discard
a = {1, 2, 3}
a.discard(3)
print(a)

# pop
print(a.pop(), a.pop())
try:
    a.pop()
except Exception as e:
    print(repr(e))
```

### 集合字面量
除空集之外，集合的字面量——`{1}`、`{1, 2}`，等等——看起来跟它的数学形式一模一样。**如果是空集，那么必须写成 `set()` 的形式**，否则它会变成一个 `dict`.  
跟 `list` 一样，字面量句法会比 `set` 构造方法要更快且更易读。

### 集合和字典的实现
集合和字典采用散列表来实现：
1. 先计算 key 的 `hash`, 根据 hash 的某几位（取决于散列表的大小）找到元素后，将该元素与 key 进行比较
2. 若两元素相等，则命中
3. 若两元素不等，则发生散列冲突，使用线性探测再散列法进行下一次查询。

这样导致的后果：
1. 可散列对象必须支持 `hash` 函数；
2. 必须支持 `__eq__` 判断相等性；
3. 若 `a == b`, 则必须有 `hash(a) == hash(b)`。

注：所有由用户自定义的对象都是可散列的，因为他们的散列值由 id() 来获取，而且它们都是不相等的。


### 字典的空间开销
由于字典使用散列表实现，所以字典的空间效率低下。使用 `tuple` 代替 `dict` 可以有效降低空间消费。  
不过：内存太便宜了，不到万不得已也不要开始考虑这种优化方式，**因为优化往往是可维护性的对立面**。

往字典中添加键时，如果有散列表扩张的情况发生，则已有键的顺序也会发生改变。所以，**不应该在迭代字典的过程各种对字典进行更改**。


```python
# 字典中就键的顺序取决于添加顺序

keys = [1, 2, 3]
dict_ = {}
for key in keys:
    dict_[key] = None

for key, dict_key in zip(keys, dict_):
    print(key, dict_key)
    assert key == dict_key

# 字典中键的顺序不会影响字典比较
```
