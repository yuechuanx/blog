---
title: 深入了解Python的官方Docker镜像
slug: official-docker-python-image
date: 2020-08-28T15:56:07+08:00
categories:
- Python
tags:
- python 
- docker
---

> 翻译：[A deep dive into the official Docker image for Python](https://pythonspeed.com/articles/official-python-docker-image/) 
>
> Docker的官方Python镜像非常流行，实际上，[我建议将其变体之一作为基础镜像](https://pythonspeed.com/articles/base-image-python-docker-images/)。但是许多人不太了解它的作用，这可能导致混乱和破裂。
>
> 因此，在这篇文章中，我将介绍它的构造方式，为什么有用，如何正确使用它以及它的局限性。特别是，我将通读[截至2020年8月19日](https://github.com/docker-library/python/blob/1b78ff417e41b6448d98d6dd6890a1f95b0ce4be/3.8/buster/slim/Dockerfile)的`python:3.8-slim-buster`变体，[并](https://github.com/docker-library/python/blob/1b78ff417e41b6448d98d6dd6890a1f95b0ce4be/3.8/buster/slim/Dockerfile)在进行过程中对其进行解释。

## 阅读 `Dockerfile`

### 基础镜像

我们从基础镜像开始：

```dockerfile
FROM debian:buster-slim
```

也就是说，基础镜像是Debian GNU / Linux 10，这是Debian发行版的当前稳定发行版，也称为Buster。

>  Debian 的所有发行版均以 Toy Story 中的角色命名。如果您想知道，[Buster是Andy的爱犬](https://toystorymovies.fandom.com/wiki/Buster)。

因此，首先，这是一个Linux发行版，可确保长期稳定，同时提供错误修复。该`slim`变体安装的软件包较少，因此没有提供编译器。

### 环境变量

接下来设置环境变量。首先确保`/usr/local/bin`在 `$PATH` 中：

```dockerfile
# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH
```

基本上，Python 镜像是将 Python 安装到`/usr/local`中，因此可以确保所安装的 Python 可执行文件是默认使用的。

接下来，设置区域设置：

```dockerfile
# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8
```

据我所知，即使不这样做，现代Python 3仍将默认为UTF-8，因此我不确定目前是否有必要。

还有一个环境变量可以告诉您当前的Python版本：

```dockerfile
ENV PYTHON_VERSION 3.8.5
```

还有一个带有GPG密钥的环境变量，用于在下载Python时验证其源代码。

### 运行时依赖

运行 Python 需要一些其他软件包：

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		netbase \
	&& rm -rf /var/lib/apt/lists/*
```

- `ca-certificates`是标准证书颁发机构的证书列表，与您的浏览器用来验证`https://URLs` 的证书相当。这使Python，wget和其他工具可以验证服务器提供的证书。

- `netbase`安装了一些文件到`/etc`。这些文件在将某些名称映射到相应的端口或协议时所需。例如，在这种情况下，`/etc/services`将服务名称映射`https`到相应的端口号`443/tcp`。

### 安装Python

接下来，安装编译器工具链，下载Python源代码，编译Python，然后卸载不需要的Debian软件包：

```dockerfile
RUN set -ex \
	\
	&& savedAptMark="$(apt-mark showmanual)" \
	&& apt-get update && apt-get install -y --no-install-recommends \
		dpkg-dev \
		gcc \
		libbluetooth-dev \
		libbz2-dev \
		libc6-dev \
		libexpat1-dev \
		libffi-dev \
		libgdbm-dev \
		liblzma-dev \
		libncursesw5-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		make \
		tk-dev \
		uuid-dev \
		wget \
		xz-utils \
		zlib1g-dev \
# as of Stretch, "gpg" is no longer included by default
		$(command -v gpg > /dev/null || echo 'gnupg dirmngr') \
	\
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
		LDFLAGS="-Wl,--strip-all" \
	&& make install \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
			-o \( -type f -a -name 'wininst-*.exe' \) \
		\) -exec rm -rf '{}' + \
	\
	&& ldconfig \
	\
	&& apt-mark auto '.*' > /dev/null \
	&& apt-mark manual $savedAptMark \
	&& find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& python3 --version
```

里面有很多东西，但是基本结果是：

1. Python已安装到中`/usr/local`。
2. 所有`.pyc`文件被删除。
3. `gcc`一旦不再需要编译Python所需的程序包等，便将其删除。

由于所有这些操作均在单个`RUN`命令中发生，因此镜像最终不会将编译器存储在其任何层中，从而使镜像变得更小。

您可能会注意到的一件事是Python需要`libbluetooth-dev`进行编译。这令人惊讶，所以我追根究底，很明显，Python可以创建蓝牙套接字，但前提是必须在安装了此软件包的情况下进行编译的。

### 设置别名

接下来，`/usr/local/bin/python3`获取一个别名`/usr/local/bin/python`，两种方式都可调用到：

```dockerfile
# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config
```

## 安装 `pip`

该`pip`包下载工具都有其自己的发布时间表，与Python的不同。例如，这`Dockerfile`将安装2020年7月发布的Python3.8.5。 `pip`20.2.2已于8月发布，但要`Dockerfile`确保包含较新的版本`pip`：

```dockerfile
# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 20.2.2
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/5578af97f8b2b466f4cdbebe18a3ba2d48ad1434/get-pip.py
ENV PYTHON_GET_PIP_SHA256 d4d62a0850fe0c2e6325b2cc20d818c580563de5a2038f917e3cb0e25280b4d1

RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends wget; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py
```

同样，所有`.pyc`文件均被删除。

### Entrypoint

最后，`Dockerfile`具体说明 Entrypoint：

```dockerfile
CMD ["python3"]
```

使用`CMD`不加 `ENTRYPOINT`，`python`默认情况下会在运行镜像时进入 REPL：

```bash
$ docker run -it python:3.8-slim-buster
Python 3.8.5 (default, Aug  4 2020, 16:24:08)
[GCC 8.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> 
```

但是，您还可以根据需要指定其他可执行文件：

```bash
$ docker run -it python:3.8-slim-buster bash
root@280c9b73e8f9:/# 
```

## 我们学到了什么？

对`slim-buster`变体，这里有一些要点。

### 该`python`官方镜像如何包含的Python

尽管这一点似乎很明显，但值得注意的*是*它是*如何*包含的：它是自定义安装Python到`/usr/local`。

常见错误是通过使用Debian的Python版本再次安装Python：

```dockerfile
FROM python:3.8-slim-buster

# THIS IS NOT NECESSARY:
RUN apt-get update && apt-get install python3-dev
```

这会在`/usr`中而不是在`/usr/local`中安装额外的Python，并且通常会是其他版本的Python。您可[不希望同一镜像中有两个不同版本的Python](https://pythonspeed.com/articles/importerror-docker/)。大多数情况下，这只会导致混乱。

如果您确实要使用Debian版本的Python，请`debian:buster-slim`改为使用基本镜像。

### `python`官方镜像包括了最新的`pip`

例如，Python 3.5的最新版本是在2019年11月，但是`python:3.5-slim-buster`包含的Docker镜像是`pip`从2020年8月开始的。（通常）这是一件好事，这意味着您可以获得最新的错误修复，性能改进以及对较新版本的支持。

### `python`官方镜像删除所有`.pyc`文件

如果要稍微加快启动速度，则可能希望`.pyc`使用[`compileall`](https://docs.python.org/3/library/compileall.html)将标准库源代码编译到自己的镜像中。

### `python`官方镜像不安装Debian安全更新

尽管经常会重新生成`debian:buster-slim`和`python`镜像，但是在某些窗口中已发布了新的Debian安全修复程序，但是尚未重新生成镜像。您应该[将安全更新安装到基础Linux发行版](https://pythonspeed.com/articles/system-packages-docker/)。