---
title: 《流畅的Python》函数装饰器与闭包
toc: true
comments: true
tags:
  - python
categories:
  - Python
  - Fluent-Python
slug: fluent-python-function-decorators-and-closures
date: 2020-04-29 16:14:34

---

![fluent-python-logo](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/fluent-python-logo.jpg)


> 有很多人抱怨，把这个特性命名为“装饰器”不好。主要原因是，这个名称与 GoF 书使用的不一致。**装饰器**这个名称可能更适合在编译器领域使用，因为它会遍历并注解语法书。
> —“PEP 318 — Decorators for Functions and Methods”

本章的最终目标是解释清楚函数装饰器的工作原理，包括最简单的注册装饰器和较复杂的参数化装饰器。  

讨论内容：

* Python 如何计算装饰器语法
* Python 如何判断变量是不是局部的
* 闭包存在的原因和工作原理
* `nonlocal` 能解决什么问题
* 实现行为良好的装饰器
* 标准库中有用的装饰器
* 实现一个参数化的装饰器

<!--more-->

## 装饰器基础

装饰器是可调用的对象，其参数是一个函数（被装饰的函数）。

装饰器可能会处理被装饰的函数，然后把它返回，或者将其替换成另一个函数或可调用对象。

装饰器两大特性：

1. 能把被装饰的函数替换成其他函数
2. 装饰器在加载模块时立即执行


```python
# 装饰器通常会把函数替换成另一个函数
def decorate(func):
    def wrapped():
        print('Running wrapped()')
    return wrapped

@decorate
def target():
    print('running target()')
target()

# 以上写法等同于
def target():
    print('running target()')
target = decorate(target)
target()

# 这里真正调用的是装饰器返回的函数

def deco(func):
    def inner():
        print('running iner()')
    return inner

@deco
def target():
    print('running target()')
target()
# target 现在是 inner 的引用
target
```

## *Python* 何时执行装饰器

装饰器在导入时（模块加载时）立即执行


```python
# registration.py

registry = []
def register(func):
    print('running register {}'.format(func))
    registry.append(func)
    return func

@register
def f1():
    print('running f1()')

@register
def f2():
    print('running f2()')

def f3():
    print('running f3()')
    
def main():
    print('running main()')
    print('registry ->', registry)
    f1()
    f2()
    f3()

if __name__=='__main__':
    main()
    
# python3 registration.py
# output:
# running register <function f1 at 0x10b4194d0>
# running register <function f2 at 0x10b419ef0>
# running main()
# registry -> [<function f1 at 0x10b4194d0>, <function f2 at 0x10b419ef0>]
# running f1()
# running f2()
# running f3()

# import registration
# running register <function f1 at 0x10d89e950>
# running register <function f2 at 0x10d89e050>

```

通过上面的例子，强调装饰器函数在导入模块式立即执行，而普通函数在被调用时运行。导入时和运行时的区别。

- 装饰器函数通常与被装饰函数不在同一模块。
- register 装饰器返回的函数没有变化

上面的装饰器会原封不动地返回被装饰的函数，而不一定会对函数做修改。 
这种装饰器叫注册装饰器，通过使用它来中心化地注册函数，例如把 URL 模式映射到生成 HTTP 响应的函数上的注册处。

## 使用装饰器




```python
promos = []

def promotion(promo_func):
    promos.append(promo_func)
    return promo_func

@promotion
def fidelity(order):
    """积分 >= 1000 提供 5% 折扣"""
    return order.total() * .05 if order.customer.fidelity >= 1000 else 0
```

## 变量作用域规则


```python
# 比较两个例子

b = 6
def f1(a):
    print(a)
    print(b)
f1(3)


def f2(a):
    print(a)
    print(b)
    b = 9 # b 此时为局部变量
f2(3)
```

*Python* 假定在函数体内部的变量为局部变量。如果未在局部变量中找到，会逐级向上查找变量。

如果想在函数中赋值时让解释器把 b 当做全局变量，用 global 关键字


```python
def f3(a):
    global b
    print(a)
    print(b)
    b = 9 
f3(3)
```

## 闭包

闭包和匿名函数常被弄混。只有涉及到嵌套函数时才有闭包问题。

闭包指延伸了作用域的函数，其中包含函数定义体中的引用，但非定义体中定义的非全局变量。和函数是否匿名无关。关键是能访问定义体之外定义的非全局变量。


```python
class Averager():
    def __init__(self):
        self.series = []
        
    def __call__(self, new_value):
        self.series.append(new_value)
        total = sum(self.series)
        return total/len(self.series)
    
avg = Averager()
avg(10)
avg(11)
avg(12)

def make_averager():
    series = []  # 自由变量
    
    def averager(new_value):
        series.append(new_value)
        total = sum(series)
        return total/len(series)

    return averager

avg = make_averager()
avg(10)
avg(11)
avg(12)

avg.__code__.co_varnames
avg.__code__.co_freevars
avg.__closure__
avg.__closure__[0].cell_contents
```

在 averager 函数中，series 是自由变量，指未在本地作用域绑定的变量。

通过 `__code__.co_freevars` `__closure__` 查看自由变量和闭包

闭包是一种函数，保留定义函数时存在的自由变量的绑定。调用函数时，虽然定义作用域不可用了，但仍能使用那些绑定

> 只有嵌套在其他函数中的函数才可能需要处理不在全局作用域的外部变量

## nonlocal 声明

下面一个例子有缺陷：


```python
def make_averager():
    count = 0
    total = 0
    
    def averager(new_value):
        count += 1
        total += new_value
        return total / count

    return averager

avg = make_averager()
avg(10)
```

注意 count， total 的赋值语句使它们成为局部变量，在赋值是会隐式创建局部变量，这样它们就不是自由变量了，因此不会保存在闭包中。

为解决这个问题，*Python3* 引入了 nonlocal 声明，作用是吧变量标记为自由变量，即使在函数中为变量新值了，也会变成自由变量。在闭包中的绑定也会更新

> 对于没有 nonlocal 的 *Python2* PEP3104


```python
def make_averager():
    count = 0
    total = 0
    
    def averager(new_value):
        nonlocal count, total
        count += 1
        total += new_value
        return total / count

    return averager

avg = make_averager()
avg(10)
```

## 实现一个简单的装饰器


```python
import time

def clock(func):
    def clocked(*args):
        t0 = time.perf_counter()
        result = func(*args)
        elapsed = time.perf_counter() - t0
        name = func.__name__
        arg_str = ', '.join(repr(arg) for arg in args)
        print('[%0.8fs] %s(%s) -> % r' %(elapsed, name, arg_str, result))
        return result
    return clocked

@clock 
def snooze(seconds):
    time.sleep(seconds)
    
@clock
def factorial(n):
    return 1 if n < 2 else n * factorial(n-1)

if __name__=='__main__':
    print('*' * 40, 'Calling snooze(.123)')
    snooze(.123)
    print('*' * 40, 'Calling factorial(6)')
    print('6! =', factorial(6))
```

装饰器的典型行为：把被装饰的函数替换成新函数，二者接受相同的参数，而且(通常)返回被装装饰函数本该返回的值，同时做一些额外操作


```python
factorial.__name__
```

上述实现的 clock 装饰器有几个缺点：不支持关键字参数，而且遮盖了被装饰函数的 `__name__`, `__doc__` 属性

functools.wraps 装饰器把相关属性从 func 复制到 clocked 中，还能正确处理关键字函数


```python
import time
import functools

def clock(func):
    @functools.wraps(func)
    def clocked(*args, **kwargs):
        t0 = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - t0
        name = func.__name__
        arg_lst = []
        if args:
            arg_str = ', '.join(repr(arg) for arg in args)
        if kwargs:
            pairs = ['%s=%s' % (k, w) for k, w in sorted(kwargs.items())]
            arg_lst.append(', '.join(pairs))
        arg_str = ', '.join(arg_lst)
        print('[%0.8fs] %s(%s) -> % r' %(elapsed, name, arg_str, result))
        return result
    return clocked

if __name__=='__main__':
    print('*' * 40, 'Calling snooze(.123)')
    snooze(.123)
    print('*' * 40, 'Calling factorial(6)')
    print('6! =', factorial(6))
```

## 标准库中的装饰器

Python 内置的三个装饰器分别为 `property`, `classmethod` 和 `staticmethod`.  

但 Python 内置的库中，有两个装饰器很常用，分别为 `functools.lru_cache` 和 [`functools.singledispatch`](https://docs.python.org/3/library/functools.html#functools.singledispatch).


```python
@clock
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-2) + fibonacci(n-1)

print(fibonacci(6))

@functools.lru_cache() # () 是因为 lru_cache 可以接受配置参数
# functools.lru_cache(maxsize=128, typed=False)
@clock # 叠放装饰器
def fibonacci(n):
    if n < 2:
        return n
    return fibonacci(n-2) + fibonacci(n-1)

print(fibonacci(6))
```

## 单分派反函数

*Python* 不支持重载方法或函数，所以我们不能使用不同的签名定义 htmlize 的辩题，也无法使用不同的方式处理不同的数据类型。

一种常见的方法是把 htmlize 编程一个分派函数，使用 if-elif-else 分别调用专门的函数。但这样不便于模块的拓展，而且臃肿

functoos.singledispatch 装饰器可以把整体方案拆分成多个模块，甚至可以为你无法修改的类提供专门的函数。
使用 functoos.singledispatch 装饰的普通函数会变成反函数。


```python
# 生成 HTML 显示不同类型的 python 对象
import html

def htmlize(obj):
    content = html.escape(repr(obj))
    return '<pre>{}</pre>'.format(content)

# htmlize({1, 2, 3})
# htmlize(abs)
# htmlize('hwimich & Co.\n- a game')
# htmlize(42)
# print(htmlize(['alpha', 66, {3, 2, 1}]))

from functools import singledispatch
from collections import abc 
import numbers

@singledispatch # 标记处理 object 类型的基函数
def htmlize(obj):
    content = html.escape(repr(obj))
    return '<pre>{}</pre>'.format(content)

@htmlize.register(str)
def _(text):
    content = html.escape(text).replace('\n', '<br>\n')
    return '<p>{0}</p>'.format(content)

@htmlize.register(numbers.Integral) # Integral 是 int 的虚拟超类
def _(n):
    return '<pre>{0} (0x{0:x})</pre>'.format(n)

@htmlize.register(tuple)
@htmlize.register(abc.MutableSequence)
def _(seq):
    inner = '</li>\n<li>'.join(htmlize(item) for item in seq)
    return '<ul>\n<li>' + inner + '</li>\n<ul>'

htmlize({1, 2, 3})
htmlize(abs)
htmlize('hwimich & Co.\n- a game')
htmlize(42)
print(htmlize(['alpha', 66, {3, 2, 1}]))
```

只要可能，注册的专门函数应该处理抽象基类(numbers.Integral, abc.MutableSequence)， 不要处理具体实现（int，list）

这样代码支持的兼容类型更广泛。

使用 singledispatch 可以在系统的任何地方和任何模块注册专门函数。



## 叠放装饰器

```python
@d1
@d2
def func():
    pass

# 等同于
func = d1(d2(func))
```

## 参数化装饰器

为了方便理解，可以把参数化装饰器看成一个函数：这个函数接受任意参数，返回一个装饰器（参数为 func 的另一个函数）。



```python
# 参数化的注册装饰器
registry = set()

# 这是一个工厂函数，用来构建装饰器函数
def register(active=True):
    # decorate 是真正的装饰器
    def decorate(func):
        print('running register(active=%s)->decorate(%s)' % (active, func))
        if active:
            registry.add(func)
        else:
            registry.discard(func) 
        return func
    return decorate

@register(active=False)
def f1():
    print('running f1()')
    
@register()
def f2():
    print('running f2()')
    
def f3():
    print('running f3()')
    
f1()
f2()
f3()
register()(f3)
registry
register(active=False)(f2)
```

## 参数化 clock 装饰器

为 clock 装饰器添加一个功能，让用户传入一个格式化字符串，控制被装饰函数的输出。


```python
import time

DEFAULT_FMT = '[{elapsed:0.8f}s] {name}({args}) -> {result}'

def clock(fmt=DEFAULT_FMT):
    def decorate(func):
        def clocked(*_args):
            t0 = time.time()
            _result = func(*_args)
            elapsed = time.time() - t0
            name = func.__name__
            args = ', '.join(repr(arg) for arg in _args)
            result = repr(_result)
            print(fmt.format(**locals()))
            return _result
        return clocked
    return decorate

# @clock()
# @clock('{name}: {elapsed}s')
@clock('{name}{args} dt={elapsed:0.3f}s')
def snooze(seconds):
    time.sleep(seconds)

for i in range(3):
    snooze(.123)
```

## 小结

本节先编写了一个没有内部函数的 @register 装饰器。 然后实现了有两层嵌套函数的参数化装饰器 @clock()

参数化装饰器基本上设计至少两层嵌套函数。

标准库 functools 提供两个非常重要的装饰器 @lru_cache() 和 @singledispatch

理解装饰器，需要区分导入时、运行时、变量作用域，闭包等。


推荐阅读：[decorator 第三方库](http://decorator.readthedocs.io/en/latest/)


```python

```