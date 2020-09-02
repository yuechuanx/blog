---
title: 《流畅的Python》可迭代的对象、迭代器和生成器
toc: true
comments: true
categories:
  - Python
  - Fluent-Python
slug: fluent-python-iterable-objects-iterators-and-generators
date: 2020-07-22 16:25:04
tags:
 - python

---

![fluent-python-logo](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/fluent-python-logo.jpg)

> 当我在自己的程序中发现用到了模式，我觉得这就表明某个地方出错了。程序的形式应该仅仅反映它所要解决的问题。代码中其他任何外加的形式都是一个信号，（至少对我来说）表明我对问题的抽象还不够深——这通常意味着自己正在手动完成事情，本应该通过写代码来让宏的扩展自动实现。
>
> ——Paul Graham, Lisp 黑客和风险投资人

迭代是数据处理的基石。扫描内存中放不下的数据集时，我们需要一种惰性获取数据项的方式，即按需一次获取一个数据项。这就是迭代器模式（Iterator pattern）。

本章说明 Python 是如何内置迭代器模式。

> `yield` 关键字用于构建生成器，其作用于迭代器一样

> 所有的生成器都是迭代器。它们都实现了迭代器接口，区别于迭代器用于从集合中取出元素，生成器用来生成元素。

在 Python 中，所有集合都可以迭代，迭代器用于支持

- for 循环
- 构建和拓展集合类型
- 逐行遍历文本文件
- 列表推导、字典推导和集合推导
- 元祖拆包
- 调用函数时， * 拆包实参

本章覆盖话题：

- 使用 `iter(...)` 内置参数处理可迭代对象的方式
- 如何使用 Python 实现迭代器模式
- 生成器函数的工作原理
- 使用生成器 函数/表达式 代替迭代器
- 使用标准库中的通用生成器函数
- 使用 `yield from` 语句合并生成器
- 案例： 数据库转换工具中使用生成器函数处理大型数据集
- 生成器和协程的差异

<!--more-->

先来写一个可迭代的 *Sentence* 类


```python
"""
Sentence class v1
"""

import re
import reprlib

RE_WORD = re.compile('\w+')

class Sentence:
    
    def __init__(self, text):
        self.text = text
        self.words = RE_WORD.findall(text)
        
    def __getitem__(self, index):
        return self.words[index]
    
    def __len__(self):
        return len(self.words)
    
    def __repr__(self):
        return 'Sentence(%s)' % reprlib.repr(self.text)
    
s = Sentence('"The time has come", the Walrus said,')
print(s)

for word in s:
    print(word)
    
print(list(s))
```

## 迭代器协议

Python 解释器在迭代一个对象时，会自动调用 `iter(x)`。  
内置的 `iter` 函数会做以下操作：

1. 检查对象是否实现了 `__iter__` 方法（`abc.Iterable`），若实现，且返回的结果是个迭代器（`abc.Iterator`），则调用它，获取迭代器并返回；
2. 若没实现，但实现了 `__getitem__` 方法（`abc.Sequence`），若实现则尝试从 0 开始按顺序获取元素并返回；
3. 以上尝试失败，抛出 `TypeError`，表明对象不可迭代。

判断一个对象是否可迭代，最好的方法不是用 `isinstance` 来判断，而应该直接尝试调用 `iter` 函数。

注：可迭代对象和迭代器不一样。从鸭子类型的角度看，可迭代对象 `Iterable` 要实现 `__iter__`，而迭代器 `Iterator` 要实现 `__next__`. 不过，迭代器上也实现了 `__iter__`，用于[返回自身](https://github.com/python/cpython/blob/3.7/Lib/_collections_abc.py#L268)。

## 迭代器的具体实现

《设计模式：可复用面向对象软件的基础》一书讲解迭代器设计模式时，在“适用性”一 节中说：
迭代器模式可用来：

* 访问一个聚合对象的内容而无需暴露它的内部表示

* 支持对聚合对象的多种遍历

* 为遍历不同的聚合结构提供一个统一的接口（即支持多态迭代）

为了“支持多种遍历”，必须能从同一个可迭代的实例中获取多个**独立**的迭代器，而且各个迭代器要能维护自身的内部状态，因此这一模式正确的实现方式是，每次调用 `iter(my_iterable)` 都新建一个独立的迭代器。

### 序列可迭代的原因：`iter`函数

解释器需要迭代对象 x 时，会自动调用 `iter(x)`:

1. 检查对象是否实现了 `__iter__` 方法并调用，获取到迭代器

2. 如果没有实现`__iter__`, 检查是否有 `__getitem__` 函数，尝试按顺序下标获取元素

3. 如果上述状况都不符合， 抛出 "C object is not iterable" 异常

这就是为什么这个示例需要定义 `SentenceIterator` 类。所以，不应该把 Sentence 本身作为一个迭代器，否则每次调用 `iter(sentence)` 时返回的都是自身，就无法进行多次迭代了。

上面的例子中，我们的 `SentenceIterator` 对象继承自 `abc.Iterator` 通过了迭代器测试。而且 `Iterator` 替我们实现了 `__iter__` 方法。  
但是，如果我们不继承它，我们就需要同时实现 `__next__` 抽象方法和*实际迭代中并不会用到的* `__iter__` 非抽象方法，才能通过 `Iterator` 测试。

## 可迭代对象与迭代器的比较

- 可迭代对象

  使用 iter 内置函数可以获取迭代器的对象。

- 迭代器

  迭代器是一种对象：实现了 `__next__` 方法，返回序列中的下一个元素，并在无元素可迭代时抛出 `StopIteration` 异常。


```python
"""
Sentence class v2: 加上一个迭代器
"""

import re
import reprlib

RE_WORD = re.compile('\w+')

class Sentence:
    
    def __init__(self, text):
        self.text = text
        self.words = RE_WORD.findall(text)
    
    def __iter__(self):
        return SentenceIterator(self.words)
    
    def __repr__(self):
        return 'Sentence(%s)' % reprlib.repr(self.text)
    
class SentenceIterator:
    
    def __init__(self, words):
        self.words = words
        self.index = 0
        
    def __next__(self):
        try:
            word = self.words[self.index]
        except IndexError:
            raise StopIteration()
        self.index += 1
        return word
    
    def __iter__(self):
        return self
    
s = Sentence('"The time has come", the Walrus said,')
print(s)

for word in s:
    print(word)
    
print(list(s))
```


## 生成器函数

### 生成器函数的工作原理

- 只要函数的定义体中有 `yield` 关键字，该函数就是生成器函数。

- 调用生成器函数会返回生成器对象。


如果懒得自己写一个迭代器，可以直接用 Python 的生成器函数来在调用 `__iter__` 时生成一个迭代器。

> 在 Python 社区中，大家并没有对“生成器”和“迭代器”两个概念做太多区分，很多人是混着用的。不过无所谓啦。


```python
"""
Sentence class v3：生成器函数
"""

import re
import reprlib

RE_WORD = re.compile('\w+')

class Sentence:
    
    def __init__(self, text):
        self.text = text
        self.words = RE_WORD.findall(text)
    
    def __iter__(self):
        for word in self.words:
            yield word
    
    def __repr__(self):
        return 'Sentence(%s)' % reprlib.repr(self.text)
    
s = Sentence('"The time has come", the Walrus said,')
print(s)

for word in s:
    print(word)
    
print(list(s))
```

```python
"""
Sentence class v4：惰性求值
"""
import re

RE_WORD = re.compile('\w+')

class Sentence:
    def __init__(self, text):
        self.text = text

    def __iter__(self):
        for match in RE_WORD.finditer(self.text):
            yield match.group()

s = Sentence('"The time has come", the Walrus said,')
print(s)

for word in s:
    print(word)
    
print(list(s))
```



```python
"""
Sentence class v5: 生成器函数
"""
import re

RE_WORD = re.compile('\w+')

class Sentence:
    def __init__(self, text):
        self.text = text

    def __iter__(self):
        return (match.group()
                for match in RE_WORD.finditer(self.text))

s = Sentence('"The time has come", the Walrus said,')
print(s)

for word in s:
    print(word)
    
print(list(s))
```

## 何时使用生成器表达式

- 如果生成器表达式要分多行写，倾向定义生成器函数。

## 案例：使用 `itertools`模块生成等差数列


```python
# 实用模块
import itertools

# takewhile & dropwhile
print(list(itertools.takewhile(lambda x: x < 3, [1, 5, 2, 4, 3])))
print(list(itertools.dropwhile(lambda x: x < 3, [1, 5, 2, 4, 3])))
# zip
print(list(zip(range(5), range(3))))
print(list(itertools.zip_longest(range(5), range(3))))

# itertools.groupby
animals = ['rat', 'bear', 'duck', 'bat', 'eagle', 'shark', 'dolphin', 'lion']
# groupby 需要假定输入的可迭代对象已经按照分组标准进行排序（至少同组的元素要连在一起）
print('----')
for length, animal in itertools.groupby(animals, len):
    print(length, list(animal))
print('----')
animals.sort(key=len)
for length, animal in itertools.groupby(animals, len):
    print(length, list(animal))
print('---')
# tee
g1, g2 = itertools.tee('abc', 2)
print(list(zip(g1, g2)))
```


```python
# 使用 yield from 语句可以在生成器函数中直接迭代一个迭代器
from itertools import chain

def my_itertools_chain(*iterators):
    for iterator in iterators:
        yield from iterator

chain1 = my_itertools_chain([1, 2], [3, 4, 5])
chain2 = chain([1, 2, 3], [4, 5])
print(list(chain1), list(chain2))
```

    [1, 2, 3, 4, 5] [1, 2, 3, 4, 5]


`iter` 函数还有一个鲜为人知的用法：传入两个参数，使用常规的函数或任何可调用的对象创建迭代器。这样使用时，第一个参数必须是可调用的对象，用于不断调用（没有参数），产出各个值；第二个值是哨符，这是个标记值，当可调用的对象返回这个值时，触发迭代器抛出 StopIteration 异常，而不产出哨符。


```python
# iter 的神奇用法
# iter(callable, sentinel)
import random

def rand():
    return random.randint(1, 6)
# 不停调用 rand(), 直到产出一个 5
print(list(iter(rand, 5)))
```

    [2, 6, 6, 4, 1, 3, 4]


## 标准库中的生成器函数

这里作者将常见生成器函数按照作用分类如下：

// 625 页

## `yield from`

如果生成器函数需要产出的是另外一个生成器的值，传统的方法是用嵌套 `for` 循环。


```python
def chain(*iterables):
    for it in iterables:
        for i in it:
            yield i
            
s = 'ABC'
t = tuple(range(3))
print(list(chain(s, t)))

def chain(*iterables):
    for i in iterables:
        yield from i
            
s = 'ABC'
t = tuple(range(3))
print(list(chain(s, t)))
```

    ['A', 'B', 'C', 0, 1, 2]
    ['A', 'B', 'C', 0, 1, 2]


可以看出 `yield from` 替代了内层循环，后面会说明为什么 `yield from` 不只是语法糖。

> [PEP 380 -- Syntax for Delegating to a Subgenerator][https://www.python.org/dev/peps/pep-0380/]

## 可迭代的规约函数

规约函数是指：函数都接受一个可迭代对象，然后返回单个结果

// 640 页

与此相对，接受一个可迭代对象返回不同的值的函数 `sorted`。

## 深入分析 `iter` 函数

`iter` 函数还有一个鲜为人知的用法：传入两个参数，使用常规的函数或任何可调用对象创建迭代器，第一个参数是可调用对象，第二个是哨符。当可调用对象返回哨符时，触发 ~StopIteration~ 异常，不产出哨符。


```python
from random import randint

def d6():
    return randint(1, 6)

d6_iter = iter(d6, 1)

for roll in d6_iter:
    print(roll)
```

内置函数 [`iter` 文档](https://docs.python.org/3/library/functions.html#iter)

里面一个实用的例子


```python
# 逐行读取文件，直到遇到空行或到达文件末尾
with open('mydata.txt') as fp:
    for line in iter(fp.readline, '\n'):
        process_line(line)
```

## 把生成器当做协程

(PEP 342 -- Coroutines via Enhanced Generators)[https://www.python.org/dev/peps/pep-0342/] 提案为生成器对象添加了额外的方法和功能

其中最值得注意的是 `.send()` 方法。它使生成器前进道下一个 `yield` 语句，还允许使用生成器的客户把数据发给自己。而 `.__next__()` 方法只允许客户从生成器中获取数据。

这使得生成器变身成协程。这里关于生成器和协程的一些提醒：

- 生成器用于生成供迭代的数据

- 协程是数据的消费者

- 不要把两个概念混为一谈

- 协程与迭代无关

- 虽然协程中会使用 `yield` 产出值，但这与迭代无关