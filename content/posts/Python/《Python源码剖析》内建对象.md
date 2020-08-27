---
title: 《Python源码剖析》内建对象
slug: python-source-code-analysis-built-in-objects
date: 2020-08-27T15:09:03+08:00
categories:
- Python
tags:
- python
draft: true
---

> 对象是 Python 中最核心的概念。在 Python 里一切皆对象。在 Python 里，已经预先定义了一些类型对象。如 int，string，dict，这些我们称之为内建对象类型。
>
> Python 是由 C 实现的，那么对象在 C 的层面究竟是什么模样？ 同时类型对象在 C 的层面是如何实现的？类型对象的作用以及它与实例关系的关系是怎样的？

## Python 内的对象

在 Python 中， 它的对象机制是如何实现的呢？

我们知道在计算机中，它所知道的一切皆为字节，一个对象实际上是一片被分配的内存空间（可能不连续）。在这片内存中存储着一系列数据，以及对数据作操作的代码。

在 Python 中，对象是 C 中结构体在堆上申请的一块内存。唯有类型对象可以被静态初始化，以及在栈空间生存，所以所有的内建类型对象都是被静态初始化的。

在 Python 中，对象一旦被创建，其内存大小就不变了。所以对象只存放变长数据的指针（毕竟地址长度是固定的）。

### 对象机制的基石 PyObject

所有的对象类型的源头是 PyObject，它是 Python 对象机制的核心。

```c
[object.h]
typedef struct _object {
  PyObject_HEAD
} PyObject;
```

Python 对象的秘密隐藏在 `PyObject_HEAD` 这个宏里。

```c
typedef struct _object {
  int ob_refcnt; // 引用计数
  struct _typeobject *ob_type; // 指定一个对象类型的类型对象
} PyObject;
```

所以，对象机制的核心其实有两个：

- 引用计数
- 类型信息

对象除了共有的信息外，还应有其他的信息，那么是什么呢？

```c
typedef struct {
  PyObject_HEAD;
  long ob_ival;
} PyIntOject
```

Python 的整数对象中，除了 `PyObject` 还有一个额外的变量，`ob_ival` 保存的是整数的值。其他类型类似，也保存各自特殊的信息在 `PyObject` 之外。

### 定长对象与变长对象

比较整数对象和字符串，前者不管大小如何都有固定长度，后者则不一定了。前者为定长对象，后者是变长对象。

在 C 中，字符串对象应该维护 “n 个 `char` 型变量”， Python 有一个表示这类对象的结构体 `PyVarObject`。

```c
[object.h]
# define PyObject_VAR_HEAD
	PyObject_HEAD;
	int ob_size; // 容纳元素的个数

typedef struct {
  PyObject_VAR_HEAD
} PyVarOject;
```

从定义能看出，`PyVarOject` 是对 `PyObject` 的拓展而已。

在 Python 内部，每一个对象都有相同的对象头部，这使得对对象的引用将变得非常统一，只需要用一个 `PyOject*` 指针就可以引用任意的一个对象。

![py-obj-type-mem-layout](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/py-obj-type-mem-layout.png)

## 类型对象

不同的对象所需空间不同，那么对象内存空间的大小和信息在哪里呢？

实际上占用内存空间的大小是对象的一种元信息，这与对象所属类型密切相关，所以它一定会出现在对象所对应的类型对象中。让我们查看一下类型对象 `_typeobject`。

```c

```

`_typeobject` 包含了许多的信息，主要分为4类：

- 类型名 tp_name
- 创建该类型对象时分配内存空间大小信息 tp_basicsize 和 tp_itemsize
- 与该类型相关的操作信息 （函数指针）
- 类型信息

事实上 `PyTypeObject` 对象是面向对象 “类” 的概率实现。此处不详细展开。

### 对象的创建

考虑一个问题：如何才能从无到有的创建出一个整数对象？

Python 会有两种方法：

- Python C API
- 类型对象 `PyInt_Type`

Python 对外提供了 C API，分为两类：

- 泛型API。或称为 AOL（Abstract Object Layer）
- 类型相关API。或称为 COL（Concrete Object Layer）

不管哪种C API，Python 内部的最终都是直接分配内存，因为 Python 对于所有内建对象是透明的，无所不知的。

对于用户自定义类型，Python 会根据其实际所对应的类型对象创建实例对象。

```Python
a = int(a)
type(a)
int.__base__
```

![new-obj-from-pyint-type](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/new-obj-from-pyint-type.png)

### 对象的行为

