---
title: Python 中的方法解析顺序(MRO)
slug: method-resolution-order-mro-in-python
toc: true
comments: true
categories:
  - Python
tags:
- python
date: 2020-07-20 15:19:06

---
> 文章转载自：
>
>  https://hanjianwei.com/2013/07/25/python-mro/

## 什么是MRO

对于支持继承的编程语言来说，其方法（属性）可能定义在当前类，也可能来自于基类，所以在方法调用时就需要对当前类和基类进行搜索以确定方法所在的位置。

而搜索的顺序就是所谓的「方法解析顺序」（Method Resolution Order，或MRO）。对于只支持单继承的语言来说，MRO 一般比较简单；而对于 Python 这种支持多继承的语言来说，MRO 就复杂很多。

先看一个「菱形继承」的例子：

![菱形继承](https://hanjianwei.com/2013/07/25/python-mro/class_diamond.svg)

如果 `x` 是 `D` 的一个实例，那么 `x.show()` 到底会调用哪个 `show` 方法呢？

如果按照 `[D, B, A, C]` 的搜索顺序，那么 `x.show()` 会调用 `A.show()`；

如果按照 `[D, B, C, A]` 的搜索顺序，那么 `x.show()` 会调用 `C.show()`。

由此可见，MRO 是把类的继承关系线性化的一个过程，而线性化方式决定了程序运行过程中具体会调用哪个方法。既然如此，那什么样的 MRO 才是最合理的？Python 中又是如何实现的呢？

Python 至少有[三种不同的 MRO](http://python-history.blogspot.com/2010/06/method-resolution-order.html)：

1. 经典类（classic class）的深度遍历。
2. Python 2.2 的新式类（new-style class）预计算。
3. Python 2.3 的新式类的[ C3 算法](http://en.wikipedia.org/wiki/C3_linearization)。它也是 Python 3 唯一支持的方式。

## 经典类的 MRO

Python 有[两种类](http://wiki.python.org/moin/NewClassVsClassicClass)：经典类（classic class）和新式类（new-style class）。两者的不同之处在于新式类继承自 `object`。

在 Python 2.1 以前，经典类是唯一可用的形式；Python 2.2 引入了新式类，使得类和内置类型更加统一；在 Python 3 中，新式类是唯一支持的类。

经典类采用了一种很简单的 MRO 方法：从左至右的[深度优先遍历](http://en.wikipedia.org/wiki/Depth-first_search)。以上述「菱形继承」为例，其查找顺序为 `[D, B, A, C, A]`，如果只保留重复类的第一个则结果为 `[D, B, A, C]`。我们可以用 `inspect.getmro` 来获取类的 MRO：

```python
>>> import inspect
>>> class A:
...     def show(self):
...         print "A.show()"
...
>>> class B(A): pass
>>> class C(A):
...     def show(self):
...         print "C.show()"
...
>>> class D(B, C): pass
>>> inspect.getmro(D)
(<class __main__.D at 0x105f0a6d0>, <class __main__.B at 0x105f0a600>, <class __main__.A at 0x105f0a668>, <class __main__.C at 0x105f0a738>)
>>> x = D()
>>> x.show()
A.show()
```

这种深度优先遍历对于简单的情况还能处理的不错，但是对于上述「菱形继承」其结果却不尽如人意：虽然 `C.show()` 是 `A.show()` 的更具体化版本（显示了更多的信息），但我们的 `x.show()` 没有调用它，而是调用了 `A.show()`。这显然不是我们希望的结果。

对于新式类而言，所有的类都继承自 `object`，所以「菱形继承」是非常普遍的现象，因此不可能采用这种 MRO 方式。

## Python 2.2 的新式类 MRO

为解决经典类 MRO 所存在的问题，Python 2.2 针对新式类提出了一种新的 MRO 计算方式：在定义类时就计算出该类的 MRO 并将其作为类的属性。因此新式类可以直接通过 `__mro__` 属性获取类的 MRO。

Python 2.2 的新式类 MRO 计算方式和经典类 MRO 的计算方式非常相似：它仍然采用从左至右的深度优先遍历，但是如果遍历中出现重复的类，只保留最后一个。重新考虑上面「菱形继承」的例子，由于新式类继承自 `object` 因此类图稍有改变：

![新式类菱形继承](https://hanjianwei.com/2013/07/25/python-mro/newclass_diamond.svg)

按照深度遍历，其顺序为 `[D, B, A, object, C, A, object]`，重复类只保留最后一个，因此变为 `[D, B, C, A, object]`。代码为：

```python
>>> class A(object):
...     def show(self):
...         print "A.show()"
...
>>> class B(A): pass
>>> class C(A):
...     def show(self):
...         print "C.show()"
...
>>> class D(B, C): pass
>>> D.__mro__
(<class '__main__.D'>, <class '__main__.B'>, <class '__main__.C'>, <class '__main__.A'>, <type 'object'>)
>>> x = D()
>>> x.show()
C.show()
```

这种 MRO 方式已经能够解决「菱形继承」问题，再让我们看个稍微复杂点的例子：

![类型冲突](https://hanjianwei.com/2013/07/25/python-mro/class_conflict.svg)

```python
>>> class X(object): pass
>>> class Y(object): pass
>>> class A(X, Y): pass
>>> class B(Y, X): pass
>>> class C(A, B): pass
```

首先进行深度遍历，结果为 `[C, A, X, object, Y, object, B, Y, object, X, object]`；然后，只保留重复元素的最后一个，结果为 `[C, A, B, Y, X, object]`。Python 2.2 在实现该方法的时候进行了调整，使其更尊重基类中类出现的顺序，其实际结果为 `[C, A, B, X, Y, object]`。

这样的结果是否合理呢？首先我们看下各个类中的方法解析顺序：对于 `A` 来说，其搜索顺序为 `[A, X, Y, object]`；对于 `B`，其搜索顺序为 `[B, Y, X, object]`；对于 `C`，其搜索顺序为 `[C, A, B, X, Y, object]`。我们会发现，`B` 和 `C` 中 `X`、`Y` 的搜索顺序是相反的！也就是说，当 `B` 被继承时，它本身的行为竟然也发生了改变，这很容易导致不易察觉的错误。此外，即使把 `C` 搜索顺序中 `X` 和 `Y` 互换仍然不能解决问题，这时候它又会和 `A` 中的搜索顺序相矛盾。

事实上，不但上述特殊情况会出现问题，在[其它情况](http://mail.python.org/pipermail/python-dev/2002-October/029035.html)下也可能出问题。其原因在于，上述继承关系违反了线性化的「 **单调性原则** 」。[Michele Simionato](http://www.python.org/download/releases/2.3/mro/)对单调性的定义为：

> A MRO is monotonic when the following is true: if C1 precedes C2 in the linearization of C, then C1 precedes C2 in the linearization of any subclass of C. Otherwise, the innocuous operation of deriving a new class could change the resolution order of methods, potentially introducing very subtle bugs.

也就是说，子类不能改变基类的方法搜索顺序。在 Python 2.2 的 MRO 算法中并不能保证这种单调性，它不会阻止程序员写出上述具有二义性的继承关系，因此很可能成为错误的根源。

除了单调性之外，Python 2.2 及 经典类的 MRO 也可能违反继承的「 **局部优先级** 」，具体例子可以参见[官方文档](http://www.python.org/download/releases/2.3/mro/#bad-method-resolution-orders)。采用一种更好的 MRO 方式势在必行。

### C3 MRO

为解决 Python 2.2 中 MRO 所存在的问题，Python 2.3以后采用了[ C3 方法](http://en.wikipedia.org/wiki/C3_linearization)来确定方法解析顺序。你如果在 Python 2.3 以后版本里输入上述代码，就会产生一个异常，禁止创建具有二义性的继承关系：

```python
>>> class C(A, B): pass
Traceback (most recent call last):
  File "<ipython-input-8-01bae83dc806>", line 1, in <module>
    class C(A, B): pass
TypeError: Error when calling the metaclass bases
    Cannot create a consistent method resolution
order (MRO) for bases X, Y
```

我们把类 `C` 的线性化（MRO）记为 `L[C] = [C1, C2,…,CN]`。其中 `C1` 称为 `L[C]` 的头，其余元素 `[C2,…,CN]` 称为尾。如果一个类 `C` 继承自基类 `B1`、`B2`、……、`BN`，那么我们可以根据以下两步计算出 `L[C]`：

1. `L[object] = [object]`
2. `L[C(B1…BN)] = [C] + merge(L[B1]…L[BN], [B1]…[BN])`

这里的关键在于 `merge`，其输入是一组列表，按照如下方式输出一个列表：

1. 检查第一个列表的头元素（如 `L[B1]` 的头），记作 `H`。
2. 若 `H` 未出现在其它列表的尾部，则将其输出，并将其从所有列表中删除，然后回到步骤1；否则，取出下一个列表的头部记作 `H`，继续该步骤。
3. 重复上述步骤，直至列表为空或者不能再找出可以输出的元素。如果是前一种情况，则算法结束；如果是后一种情况，说明无法构建继承关系，Python 会抛出异常。

该方法有点类似于图的[拓扑排序](http://en.wikipedia.org/wiki/Topological_sorting)，但它同时还考虑了基类的出现顺序。我们用 C3 分析一下刚才的例子。

`object`，`X`，`Y` 的线性化结果比较简单：

```plaintext
L[object] = [object]
L[X] = [X, object]
L[Y] = [Y, object]
```

`A` 的线性化计算如下：

```plaintext
L[A] = [A] + merge(L[X], L[Y], [X], [Y])
     = [A] + merge([X, object], [Y, object], [X], [Y])
     = [A, X] + merge([object], [Y, object], [Y])
     = [A, X, Y] + merge([object], [object])
     = [A, X, Y, object]
```

注意第3步，`merge([object], [Y, object], [Y])` 中首先输出的是 `Y` 而不是 `object`。这是因为 `object` 虽然是第一个列表的头，但是它出现在了第二个列表的尾部。所以我们会跳过第一个列表，去检查第二个列表的头部，也就是 `Y`。`Y` 没有出现在其它列表的尾部，所以将其输出。

同理，`B` 的线性化结果为：

```plaintext
L[B] = [B, Y, X, object]
```

最后，我们看看 `C` 的线性化结果：

```plaintext
L[C] = [C] + merge(L[A], L[B], [A], [B])
     = [C] + merge([A, X, Y, object], [B, Y, X, object], [A], [B])
     = [C, A] + merge([X, Y, object], [B, Y, X, object], [B])
     = [C, A, B] + merge([X, Y, object], [Y, X, object])
```

到了最后一步我们没有办法继续计算下去 了：`X` 虽然是第一个列表的头，但是它出现在了第二个列表的尾部；`Y` 虽然是第二个列表的头，但是它出现在了第一个列表的尾部。因此，我们无法构建一个没有二义性的继承关系，只能手工去解决（比如改变 `B` 基类中 `X`、`Y` 的顺序）。

我们再看一个没有冲突的例子：

![C3例子](https://hanjianwei.com/2013/07/25/python-mro/c3_example.svg)

计算过程如下：

```plaintext
L[object] = [object]
L[D] = [D, object]
L[E] = [E, object]
L[F] = [F, object]
L[B] = [B, D, E, object]
L[C] = [C, D, F, object]
L[A] = [A] + merge(L[B], L[C], [B], [C])
     = [A] + merge([B, D, E, object], [C, D, F, object], [B], [C])
     = [A, B] + merge([D, E, object], [C, D, F, object], [C])
     = [A, B, C] + merge([D, E, object], [D, F, object])
     = [A, B, C, D] + merge([E, object], [F, object])
     = [A, B, C, D, E] + merge([object], [F, object])
     = [A, B, C, D, E, F] + merge([object], [object])
     = [A, B, C, D, E, F, object]
```

当然，可以用代码验证类的 MRO，上面的例子可以写作：

```python
>>> class D(object): pass
>>> class E(object): pass
>>> class F(object): pass
>>> class B(D, E): pass
>>> class C(D, F): pass
>>> class A(B, C): pass
>>> A.__mro__
(<class '__main__.A'>, <class '__main__.B'>, <class '__main__.C'>, <class '__main__.D
```
