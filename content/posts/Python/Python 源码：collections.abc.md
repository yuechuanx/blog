---
title: 阅读 Python 源码：collections.abc
slug: pythonpython-source-code-collectionsabc
categories:
  - Python
date: 2020-08-13 16:38:01
---
![python-logo](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/python-logo.png)

ABC(Abstract Base Class) 抽象基类。

要了解为什么 Python 要设计这个，需要先了解到几个概念。

1. 鸭子类型
2. 接口协议
3. 继承

与 collections.abc 相关的有两个文件：

- abc.py

- _collections_abc.py

其中 abc.py 定义了 ABCMeta 和 ABC 类，和一些装饰器：

函数装饰器：abstractmethod

装饰器类：abstractclassmethod，abstractstaticmethod，abstractproperty

ABCMeta 类是元类，用来描述和生成 ABC 类。 

代码不长，去除 debug 的一些方法。

```Python
class ABCMeta(type):
        """Metaclass for defining Abstract Base Classes (ABCs).
				定义 ABC 的元类
				
				用此元类创建 ABC，抽象基类能被直接用作子类，行为像 mix-in。以及可以
        Use this metaclass to create an ABC.  An ABC can be subclassed
        directly, and then acts as a mix-in class.  You can also register
        unrelated concrete classes (even built-in classes) and unrelated
        ABCs as 'virtual subclasses' -- these and their descendants will
        be considered subclasses of the registering ABC by the built-in
        issubclass() function, but the registering ABC won't show up in
        their MRO (Method Resolution Order) nor will method
        implementations defined by the registering ABC be callable (not
        even via super()).
        """
        def __new__(mcls, name, bases, namespace, **kwargs):
            cls = super().__new__(mcls, name, bases, namespace, **kwargs)
            _abc_init(cls)
            return cls

        def register(cls, subclass):
            """Register a virtual subclass of an ABC.

            Returns the subclass, to allow usage as a class decorator.
            """
            return _abc_register(cls, subclass)

        def __instancecheck__(cls, instance):
            """Override for isinstance(instance, cls)."""
            return _abc_instancecheck(cls, instance)

        def __subclasscheck__(cls, subclass):
            """Override for issubclass(subclass, cls)."""
            return _abc_subclasscheck(cls, subclass)
            
            
class ABC(metaclass=ABCMeta):
    """Helper class that provides a standard way to create an ABC using
    inheritance.
    """
    __slots__ = ()
```

ABCMeta 生成 ABC 类是通过 _abc_init(cls)，在创建实例的过程中，改变了生成类的属性。

ABCMeata 重写了两个方法，可以被注册为虚拟子类，这就是抽象基类的全部作用。