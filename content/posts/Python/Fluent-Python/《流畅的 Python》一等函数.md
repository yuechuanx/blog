---
title: 《流畅的 Python》一等函数
slug: fluent-python-first-class-function
toc: true
comments: true
tags:
  - python
categories:
  - Python
  - Fluent-Python
date: 2020-04-22 16:38:39
---

> 不管别人怎么说或怎么想，我从未觉得 Python 受到来自函数式语言的太多影响。我非常熟悉命令式语言，如 C 和 Algol 68，虽然我把函数定为一等对象，但是我并不把 Python 当作函数式编程语言。  
> —— Guido van Rossum: Python 仁慈的独裁者

在 Python 中，函数是一等对象。  
编程语言理论家把“一等对象”定义为满足下述条件的程序实体：

* 在运行时创建
* 能赋值给变量或数据结构中的元素
* 能作为参数传给函数
* 能作为函数的返回结果

## 函数即为对象


```python
def factorial(n):
    """returns n!"""
    return 1 if n < 2 else n * factorial(n-1)

factorial(42)
factorial.__doc__
type(factorial)
```

通过 `type(factorial)` 可以看到 `function` 是一种类型，或者说，函数也是对象，可以通过`__doc__` 去访问它的属性。

那么作为对象的函数，也能作为参数被传递。函数式风格编程也基于此


```python
fact = factorial
fact
fact(5)
map(factorial, range(11))
list(map(fact, range(11)))
```

## 高阶函数

输入或者输出是函数的即为*高阶函数*(higher order function)。例如：`map`， `sorted`。


```python
fruits = ['strawberry', 'fig', 'apple', 'cherry', 'raspberry', 'banana']
# function len() as key
sorted(fruits, key=len)
```

## map、filter 和 reduce 的替代品

函数式语言通常提供 `map`、`filter` 和 `reduce` 三个高阶函数。
在 *Python* 中引入了列表推导和生成式表达式，可以替代它们且更容易阅读。


```python
list(map(fact, range(6)))
[fact(n) for n in range(6)]
list(map(factorial, filter(lambda n : n % 2, range(6))))
[factorial(n) for n in range(6) if n % 2]
```

`map` 和 `filter` 返回生成器，可用生成器表达式替代
`reduce` 常用求和，目前最好使用 `sum` 替代


```python
from functools import reduce
from operator import add

reduce(add, range(100))
sum(range(100))
```

`sum` 和 `reduce` 把操作连续应用在序列元素上，得到返回值

`all(iterable)`, `any(iterable)` 也是规约函数

- `all(iterable)`: 每个元素为真，返回真
- `any(iterable)`: 存在一个元素为真，返回真

## 匿名函数

*Python* 支持 *lambda* 表达式。 它是函数对象，在句法上被限制只能用存表达式。

参数列表中最适合使用匿名函数。


```python
# 根据单词末尾字符排序

fruits = ['strawberry', 'fig', 'apple', 'cherry', 'raspberry', 'banana']
sorted(fruits, key=lambda word: word[::-1])
```

Python 的可调用对象

* 用户定义的函数：使用 `def` 或 `lambda` 创建
* 内置函数：如 `len` 或 `time.strfttime`
* 内置方法：如 `dict.get`
* 类：先调用 `__new__` 创建实例，再对实例运行 `__init__` 方法
* 类的实例：如果类上定义了 `__call__` 方法，则实例可以作为函数调用
* 生成器函数：使用 yield 关键字的函数或方法，调用生成器函数会返回生成器对象

判断对象是否能调用，使用内置的 `callable()` 函数


```python
abs, str, 13
[callable(obj) for obj in (abs, str, 13)]
```

## 用户定义的可调用类型

任何 *Python* 对象都可以表现得像函数，只需实现实例方法 `__call__`


```python
import random 

class BingoCage:
    def __init__(self, items):
        self._items = list(items)
        random.shuffle(self._items)
        
    def pick(self):
        try:
            return self._items.pop()
        except IndexError:
            raise LookupError('pick from empty BingoCage')
    
    def __call__(self):
        return self.pick()
    
bingo = BingoCage(range(3))
bingo.pick()
bingo()
callable(bingo)
```

实现 `__call__` 方法的类是创建函数类对象的简便方式。
函数类对象有自己的状态，即为实例变量。装饰器函数也可以有.

## 函数内省

内省（introspection）可以查看函数内部的细节，函数有许多属性。使用 dir 函数可以查看，或使用 __code__ 属性


```python
dir(factorial)
# factorial.__code__.co_varnames
```


```python
# eg:5-9
# 列出常规对象没有而函数有的属性

class C: pass
obj = C()
def func(): pass
sorted(set(dir(func)) - set(dir(obj)))
```

函数属性说明 
// 插入表格

## 从定位参数到仅限关键字参数

本节讨论 python 参数处理机制。py3 提供了仅限关键字参数（keyword-only argument）
调用函数使用 * 和 ** 展开可迭代对象。

- positional argument 位置参数
- keyword-only argument 仅限关键字参数


```python
def tag(name, *content, cls=None, **attrs):
    """生成一个或多个 HTML 标签"""
    if cls is not None:
        attrs['class'] = cls
    if attrs:
        attr_str = ''.join(' %s="%s"' % (attr, value)
                          for attr, value in sorted(attrs.items()))
    else: 
        attr_str = ''
    if content:
        return '\n'.join('<%s%s>%s</%s>' % (name, attr_str, c, name) for c in content)
    else:
        return '<%s%s />' % (name, attr_str)
    
tag('br')
tag('p', 'hello')
tag('p', 'hello', 'world') # 'hello', 'world' -> *content
tag('p', 'hello', id=33)   # id=33 -> **attrs
tag('p', 'hello', 'world', cls='sidebar')
tag(content='testing', name="img")
my_tag = {
    'name': 'img',
    'title': 'Sunset Boulevard',
    'src': 'sunset.jpg',
    'cls': 'framed'
}
tag(**my_tag)
```

`cls` 参数只能通过关键字指定，而不能通过位置参数指定。

定义函数时若只想定仅限关键字参数，要把它放在带有 * 参数后面，如果不想支持数量不定的位置参数，但支持 keyowrd-only, 在函数签名中放一个 *


```python
def f(a, *, b):
    return a, b

# f(1, 2)
f(1, b=2) 
```

## 获取关于参数的信息

上面提到，函数内省可以查看函数内部信息，通过 HTTP 微框架 Bobo 作为例子来看下


```python
# eg: 5-12
# hello.py
import bobo

@bobo.query('/')
def hello(person):
    return 'Hello %s!' % person

# 在环境中执行 bobo -f hello.py, 若运行端口为 http://localhost:8080/
# 没有传入参数
# curl -i http://localhost:8080/
# HTTP/1.0 403 Forbidden
# Date: Wed, 22 Apr 2020 06:23:33 GMT
# Server: WSGIServer/0.2 CPython/3.7.4
# Content-Type: text/html; charset=UTF-8
# Content-Length: 103

# <html>
# <head><title>Missing parameter</title></head>
# <body>Missing form variable person</body>
# </html>

# 传入参数
# curl -i http://localhost:8080/?person=Jim
# HTTP/1.0 200 OK
# Date: Wed, 22 Apr 2020 06:24:47 GMT
# Server: WSGIServer/0.2 CPython/3.7.4
# Content-Type: text/html; charset=UTF-8
# Content-Length: 10

# Hello Jim!% 
```

Bobo 如何知道函数需要哪个参数呢？

函数对象有 `__defaults__` 属性，其值为一个元祖，保存着位置参数和关键字参数的默认值。

keyword-only 参数默认值保存在 `__kwdefaults__` 属性中。

参数的名称在 `__code__` 属性中，其值为 *code* 对象的引用。


```python
def clip(text, max_len=80):
    """在 max_len 前后的第一个空格处截断文本"""
    end = None
    if (len(text)) > max_len:
        space_before = text.rfind(' ', 0, max_len)
        if space_before >= 0:
            end = space_before
        else:
            space_after = text.rfind(' ', max_len)
            if space_after >= 0:
                end = space_after
    if end is None:
        end = len(text)
        
    return text[:end].rstrip()


clip.__defaults__
# clip.__code__
# clip.__code__.co_varnames
# clip.__code__.co_argcount
```

函数签名信息，参数和默认值是分开的。可以使用 inspect 模块提取这些信息


```python
from inspect import signature

sig = signature(clip)
sig
str(sig)
for name, param in sig.parameters.items():
    print(param.kind, ':', name, '=', param.default)
```

kind 属性值在 `_Parameterkind` 类中，列举如下：

- POSTIONAL_OR_KEYWORD
- VAR_POSITIONAL
- VAR_KEYWORD
- KEYWORD-ONLY
- POSITIONAL_ONLY

*inspect.Signature* 有 `bind` 方法，可以把任意个参数绑定在签名中的形参上。

框架可以使用此方法在调用函数前验证参数


```python
import inspect
sig = inspect.signature(tag)
my_tag = {
    'name': 'img',
    'title': 'Sunset Boulevard',
    'src': 'sunset.jpg',
    'cls': 'framed'}
bound_args = sig.bind(**my_tag)
bound_args

del my_tag['name']
# missing argument error
bound_args = sig.bind(**my_tag)
```

框架和 IDE 工具可以使用这些信息验证代码

## 函数注解（annotation）

各个参数可以在 : 后添加注解表达式。

参数有默认值，注解放在参数名和 = 号之间，注解返回值在函数声明末尾添加 -> 和表达式

注解不会做任何处理，只存储在函数 `__annotations__` 属性中。

注解只是元数据，可以供 IDE，框架和装饰器等工具使用

`inspect.signature()` 函数知道怎么提取注解


```python
def clip(text: str, max_len: 'int > 0' = 80) -> str:
    pass

clip.__annotations__
```


```python
from inspect import signature

sig = signature(clip)
sig.return_annotation

for param in sig.parameters.values():
    note = repr(param.annotation).ljust(13)
    print(note, ':', param.name, '=', param.default)

```

## 支持函数式编程的包

### operator 模块

`operator` 里有很多函数，对应着 Python 中的内置运算符，使用它们可以避免编写很多无趣的 `lambda` 函数，如：

* `add`: `lambda a, b: a + b`
* `or_`: `lambda a, b: a or b`
* `itemgetter`: `lambda a, b: a[b]`
* `attrgetter`: `lambda a, b: getattr(a, b)`


```python
from functools import reduce
from operator import mul

def fact(n):
    return reduce(lambda a, b: a*b, range(1, n+1))

def fact(n):
    return reduce(mul, range(1, n+1))
```

还有一类函数，能替代从序列中取出或读取元素属性的 *lambda* 表达式。如 `itemgetter`，`attrgetter`


```python
metro_data = [
    ('Tokyo', 'JP', 36.933, (35.689722, 139.691667)),   # <1>
    ('Delhi NCR', 'IN', 21.935, (28.613889, 77.208889)),
    ('Mexico City', 'MX', 20.142, (19.433333, -99.133333)),
    ('New York-Newark', 'US', 20.104, (40.808611, -74.020386)),
    ('Sao Paulo', 'BR', 19.649, (-23.547778, -46.635833)),
]

from operator import itemgetter

for city in sorted(metro_data, key=lambda fields: fields[1]):
    print(city)

for city in sorted(metro_data, key=itemgetter(1)):
    print(city)

# itemgetter 返回提取的值构成的元祖，可以用来提取指定字段或调整元祖顺序
cc_name = itemgetter(1, 0)
for city in metro_data:
    print(cc_name(city))
```

itemgetter 使用 `[]` 运算符，因为它不仅支持序列，还支持映射和任何实现 `__getitem__` 的类

attrgetter 作用相似，它创建的函数根据名称提取对象的属性。包含 `.` 的，会进入到嵌套对象提取属性


```python
from collections import namedtuple

LatLong = namedtuple('Latlong', 'lat long')
Metorpolis = namedtuple('Metorpolis', 'name cc pop coord')

metro_areas = [Metorpolis(name, cc, pop, LatLong(lat, long)) 
              for name, cc, pop, (lat, long) in metro_data]

metro_areas[0]
metro_areas[0].coord.lat

from operator import attrgetter
name_lat = attrgetter('name', 'coord.lat')

for city in sorted(metro_areas, key=attrgetter('coord.lat')):
    print(name_lat(city))
```


```python
import operator
[name for name in dir(operator) if not name.startswith('_')]
```

*operator* 模块的函数可以通过 `dir(operator)` 查看。

介绍 methodcaller, 它的作用与前两个函数相似，它创建的函数会在对象调用参数指定的方法


```python
from operator import methodcaller

s = 'The time has come'
upcase = methodcaller('upper')
upcase(s)
hiphenate = methodcaller('replace', ' ', '-')
hiphenate(s)
```

## 使用 functools.partial 冻结参数

`functools` 最常用的函数有 `reduce`，之前已经介绍过。余下函数中最有用的是 `partial` 及其变体 `partialmethod`

它的作用是：把原函数某些参数固定。

`partial` 第一个函数是可调用对象，后面跟任意个位置参数和关键字参数


```python
from operator import mul
from functools import partial

triple = partial(mul, 3)
triple(7)

list(map(triple, range(1, 10)))

picture = partial(tag, 'img', cls='pic-frame')
picture(src='wumpus.jepg')
picture
picture.func
picture.args
picture.keywords
```

functoos.partialmethod 作用与 partial 一样，不过适用于处理方法的

## 小结

探讨 *Python* 函数的一等特性。意味着可以把函数赋值给变量，传入其他函数，存储于数据结构中，以及访问函数属性。

高阶函数是函数式编程的重要组成。

`Python` 的可调用对象: 7种

函数及其注解有丰富的特性。可通过 `inspect` 模块读取

最后介绍了 `operator` 模块中的一些函数，可以替换掉功能有限的 *lambda* 表达式。