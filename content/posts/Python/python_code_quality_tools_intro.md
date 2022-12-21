---
title: "Python 代码质量工具介绍"
slug: python-code-quality-tools-intro
date: 2021-05-12T17:30:37+08:00
draft: false
tags:
- python
- codestyle
---
![xmid-python-code-quality-tools](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/xmid-python-code-quality-tools.png)

## 目的

- 规范代码格式，提升代码质量
- 减少团队协作时理解成本
- 设置通用规范

## CodeStyle

[PEP 8](https://www.python.org/dev/peps/pep-0008/) 是 Python 代码风格规范。它规定了类似行

- 长度
- 缩进
- 多行表达式
- 变量命名约定

等等

代码风格规范的目标都是在代码库中强制实施一致的标准，使代码的可读性更强、更易于维护。

虽然 PEP8 只是作为 Python 官方推荐的规范，但在实际上它已经成为最广泛认同的 Python 代码风格标准。

以下标准也是广泛流行的 Python 代码风格:

- [Chromium Python Style Guide](https://chromium.googlesource.com/chromium/src/+/HEAD/styleguide/python/python.md)
- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)

## Pylint

[Pylint](https://www.pylint.org/) 是一个用来检查是否符合代码规范和常见错误的库。里面默认 PEP8 规范，也可以根据自身需求来自定义一套规范。

它可以以命令行方式执行，也可以作为插件集成在 IDE 中。

它里面包含了许多 check_list，根据影响程度进行了分类：

- `C` convention related checks (公约)
- `R` refactoring related checks (重构)
- `W` various warnings (警告)
- `E` errors, for probable bugs in the code (错误)
- `F` fatal, if an error occurred which prevented `pylint` from doing further processing. (影响程序执行)

### 安装

```sh
pip install pylint 
```

### 使用

```sh
pylint [OPTION] FILE
pylint [OPTION] DIR
```

![pylint-output](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/pylint-output.png)

### 配置

[Pylint](https://www.pylint.org/) 提供可配置的 check 项，可自定义 Enable/Disable 指定的 check。

全部的 check 项请参阅：[Pylint Checker Features](http://pylint.pycqa.org/en/latest/technical_reference/features.html#format-checker)

```sh
pylint --list-msgs          # 打印所有的 check 项
pylint --list-msgs-enabled  # 开启的 check 项
```

配置文件加载顺序：

1. 当前目录下存在 `pylintrc`，`.pylintrc`
2. 环境变量 `PYLINTRC`
3. 主目录下 `.pylintrc`， `.config/pylintrc`

## Yapf

[Yapf](https://github.com/google/yapf) 是 “Yet another python formatter” 是缩写，它是一个代码格式化工具。

符合 PEP8 的代码并不代表代码看起来美观。yapf 用来将代码重新格式化为符合代码样式指南的最佳格式，针对代码库可以让样式在整个项目中保持一致，让大家不用再为代码样式争论。

### 安装

```sh
pip install yapf
```

### 使用

```sh
yapf [OPTION] [file [files...]]

-d, --diff      显示原代码和格式化后的差异
-i, --in-place     在文件上直接修改
-r, --recursive 在目录上递归运行
-e PATTERN      排除文件
--style STYLE   指定样式，例如 "pep8", "google"
```

### 配置

yapf 主要有两种配置

- `.yapfignore`  忽略无需格化的文件
- `.style.yapf`  yapf 配置文件

查看 yapf 配置项：

```sh
yapf --style-help
yapf --style-help > style.yapf  # 生成配置文件
```

## Radon

[Radon]*(https://radon.readthedocs.io/en/latest/) 是用来量化代码质量指标的工具。它提供以下指标

- 原始指标：SLOC，注释行，空白行

  >SLOT (Source lines of code) 代码行数

- 圈复杂度

- Halstead指标（所有指标）

- 可维护性指数

上述指标的解释可见 [Radon Metrics](https://radon.readthedocs.io/en/latest/intro.html)

### 使用

```shell
radon [cc,raw,mi,hal] ...
```

- cc            

  Analyze the given Python modules and compute Cyclomatic Complexity (CC).

- raw            

  Analyze the given Python modules and compute raw metrics.

- mi             

  Analyze the given Python modules and compute the Maintainability Index.

- hal            

  Analyze the given Python modules and compute their Halstead metrics.

![radon-output](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/radon-output.png)

## 集成 IDE

### 与 PyCharm 集成

1. pylint 插件安装和使用

![pycharm-pylint](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/pycharm-pylint.png)

![pycharm-using-pylint](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/pycharm-using-pylint.png)

2. yapf 插件安装和使用

![pycharm-yapf](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/pycharm-yapf.png)

![pycharm-using-yapf](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/pycharm-using-yapf.png)

3. Radon 作为外部工具的配置和使用

![pycharm-external-tool-radon-setup](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/pycharm-external-tool-radon-setup.png)

![pycharm-external-tool-radon-call](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/pycharm-external-tool-radon-call.png)

![pycharm-external-tool-radon-output](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/pycharm-external-tool-radon-output.png)

