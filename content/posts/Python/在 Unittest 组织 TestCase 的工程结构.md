---
title: 使用 Unittest 组织 TestCase 的工程结构
slug: organize-the-project-structure-of-testcase-in-unittest
categories: 
- Python
tags:
- unitest
date: 2020-08-13 16:01:58
---
# 使用 Unittest 组织 TestCase 的工程结构

单文件的 TestCase 很容易被执行，只需用执行命令 `python test_xxx.py`。

随着 TestCase 的增多，我们可能面对这样的情况：

- 执行多个 TestCase 作为一组被执行
- 指定某一些 TestCase 执行

此时我们需要把 TestCase 按照一定层次结构组织。

## 环境

- Python 3+ 

## TestLoader

在 import unittest 时，会自动导入 TestLoader 类，在类中封装了 5 中组织 TestCase 的方法。

```python
class TestLoader(object):
    """
    该类负责根据各种标准加载测试并将它们包装在TestSuite中
    """
    
    def loadTestsFromTestCase(self, testCaseClass):
    """
    返回testCaseClass中包含的所有测试用例的套件
    """
    
    def loadTestsFromModule(self, module, *args, pattern=None, **kws):
    """
    返回给定模块中包含的所有测试用例的套件
    """
    
    def loadTestsFromName(self, name, module=None):
    """
    返回给定用例名的测试用例的套件
    """
    
    def loadTestsFromNames(self, names, module=None):
    """
    返回给定的一组用例名的测试用例的套件
    """
    
    def discover(self, start_dir, pattern='test*.py', top_level_dir=None):
    """
    查找并返回指定的起始目录中的所有测试模块，递归到子目录中以查找它们并返回在其
    中找到的所有测试。仅加载与模式匹配的测试文件。
    必须可以从项目的顶层导入测试模块。如果起始目录不是顶级目录，则必须单独指定顶级目录。
    """
    
defaultTestLoader = TestLoader()
"""
defaultTestLoader是TestLoader()的实例对象
"""
```

## Unittest 组织 TestCase 的方式

##### 工程目录

```sh
test
├── run_from_discover.py
├── run_from_test_case_class.py
├── run_from_test_case_moudle.py
├── run_from_test_case_name.py
├── run_from_test_case_names.py
└── test_case
    ├── __init__.py
    ├── test_add.py
    └── test_sub.py
```

- test_case 用来放置 TestCase 的实现
- test_case 需要组织为包（包含 `__init__.py`）
- run_from_*.py 为测试执行入口

### 1. 加载测试类中的用例

```python
loadTestsFromTestCase(self, testCaseClass)
```

- 使用loadTestsFromTestCase这个方法，需传入unittest测试类的类名
- 以项目为例子，传入 testCaseClass ：AddCase

*run_from_test_case_class.py*

```python
# encoding:utf8

import unittest
from test_case.test_add import AddCase

cases = unittest.TestLoader().loadTestsFromTestCase(AddCase)
runner = unittest.TextTestRunner(verbosity=2)
runner.run(cases)
```

运行 

```python
python run_from_test_case_class.py

test_add_1 (test_case.test_add.AddCase)
加法冒烟测试 ... ok
test_add_2 (test_case.test_add.AddCase) ... FAIL
```

### 2、加载模块中的测试用例

```python
loadTestsFromModule(self, module, *args, pattern=None, **kws)
```

- 使用loadTestsFromModule这个方法，需传入被测试模块
- 以项目为例子，传入参数 module ：test_add

*run_from_test_case_moudle.py*

```python
# encoding:utf8

import unittest
from test_case import test_add

cases = unittest.TestLoader().loadTestsFromModule(test_add)
runner = unittest.TextTestRunner(verbosity=2)
runner.run(cases)
```

运行 run_from_test_case_moudle.py

```python
python run_from_test_case_moudle.py
```

运行结果

```python
test_add_1 (test_case.test_add.AddCase)
加法冒烟测试 ... ok
test_add_2 (test_case.test_add.AddCase) ... FAIL
```

## **3、加载指定的单个测试用例**

```python
loadTestsFromName(self, name, module=None)
```

- 使用loadTestsFromName这个方法，需传入测试用例的方法名
- 传入测试用例的方法名格式：moudleName.testCaseClassName.testCaseName
- 以项目为例子，我想测试test_add.py 里面的用例 test_add_1
- 我需要传入的参数 name：test_add.AddCase.test_add_1
- loadTestsFromName这个方法是在 sys.path 里面的路径去寻找测试模块test_add.py,然后再寻找测试类AddCase 最后再寻找测试用例test_add_1

*run_from_case_name.py*

```python
# encoding:utf8

import unittest
import os
import sys

# 获取 "how_to_run_test_case" 的绝对路径
dir_run_test_case = os.path.dirname(os.path.abspath(__file__))
# 获取 "test_case" 的绝对路径
dir_test_case = dir_run_test_case + '/test_case'
# 把 "test_case" 的绝对路径 加入 sys.path
sys.path.insert(0,dir_test_case)

case= unittest.TestLoader().loadTestsFromName('test_add.AddCase.test_add_1')
runner = unittest.TextTestRunner(verbosity=2)
runner.run(cases)
```

运行 run_from_case_name.py

```python
python run_from_case_name.py
```

运行结果

```python
test_add_1 (test_add.AddCase)
加法冒烟测试 ... ok
```

## **4、加载指定的多个测试用例**

```python
loadTestsFromNames(self, names, module=None)
```

-  使用loadTestsFromNames这个方法,需要传入一个数组
-  数组里面里面的元素必须是字符串
-  数组元素可以是模块、类、方法
-  数组元素 - 传入格式1：moudleName
-  数组元素 - 传入格式2：moudleName.testCaseClassName
-  数组元素 - 传入格式3：moudleName.testCaseClassName.testCaseName
-  以项目为例，我想测试test_add.py 里面的用例 test_add_1 ，以及test_sub.py 里面的用例 test_sub_1
-  我需要传入的参数 names：['test_sub.SubCase.test_sub_2','test_add.AddCase.test_add_1']
-  loadTestsFromNames这个方法是在 sys.path 里面的路径去寻找匹配的测试用例
-  执行用例是根据数组元素的的顺序执行

*run_from_case_names.py*

```python
# encoding:utf8

import unittest
import sys
import os

# 获取 "how_to_run_test_case" 的绝对路径
dir_run_test_case = os.path.dirname(os.path.abspath(__file__))
# 获取 "test_case" 的绝对路径
dir_test_case = dir_run_test_case + '/test_case'
# 把 "test_case" 的绝对路径 加入 sys.path
sys.path.insert(0,dir_test_case)

cases = ['test_sub.SubCase.test_sub_1','test_add.AddCase.test_add_1']
suite = unittest.TestLoader().loadTestsFromNames(cases)
runner = unittest.TextTestRunner(verbosity=2)
runner.run(suite)
```

运行 run_from_case_names.py

```sh
python run_from_case_names.py
```

运行结果

```python
test_sub_1 (test_sub.SubCase)
减法冒烟测试 ... ok
test_add_1 (test_add.AddCase)
加法冒烟测试 ... ok
```

### 5、加载指定目录下所有的测试用例

```python
discover(self, start_dir, pattern='test*.py', top_level_dir=None)
```

- start_dir ： 查找用例的起始目录
- pattern='test*py' : 查找模块名为test开头的python文件
- top_level_dir=None ：测试模块顶级目录

*run_from_discover.py*

```python
# encoding:utf8

import unittest
import os

dir_how_to_run_test_case = os.path.dirname(os.path.abspath(__file__))
dir_test_case = dir_how_to_run_test_case + '/test_case'

cases = unittest.defaultTestLoader.discover(dir_test_case)
runner = unittest.TextTestRunner(verbosity=2)
runner.run(cases)
```

运行 run_from_discover.py

```sh
python run_from_discover.py
```

运行结果

```python
test_add_1 (test_add.AddCase)
加法冒烟测试 ... ok
test_add_2 (test_add.AddCase) ... FAIL
test_sub_1 (test_sub.SubCase)
减法冒烟测试 ... ok
test_sub_2 (test_sub.SubCase) ... FAIL
```