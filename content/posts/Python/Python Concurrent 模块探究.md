---
title: "Python Concurrent 模块探究"
slug: python-concurrent-module-analysis
date: 2021-01-20T14:44:45+08:00
tags: 
- python
- concurrent
---

## Python 如何执行并发任务

Python 中有 `concurrent` 模块用来作为对并行支持，目前，此包中只有一个模块：

- [`concurrent.futures`](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#module-concurrent.futures) —— 启动并行任务

[`concurrent.futures`](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#module-concurrent.futures) 模块提供异步执行回调高层接口。

## 里面有什么？

这个模块里面包含了什么？一个接口类/抽象类，两个不同的实现子类。

一个接口类/抽象类

`concurrent.futures.Executor`

`Executor` 是一个抽象类，抽象类提供异步执行调用方法。要通过它的子类调用，而不是直接调用。

两个不同的实现子类

ThreadPoolExecutor 和 ProcessPoolExecutor

它们实现了 Executor 类，它们都可以进行异步执行调用。

异步执行可以由 [`ThreadPoolExecutor`](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#concurrent.futures.ThreadPoolExecutor) 使用线程或由 [`ProcessPoolExecutor`](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#concurrent.futures.ProcessPoolExecutor) 使用单独的进程来实现。 两者都是实现抽像类 [`Executor`](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#concurrent.futures.Executor) 定义的接口。

Future

Future 类将可调用对象封装为异步执行。[`Future`](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#concurrent.futures.Future) 实例由 [`Executor.submit()`](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#concurrent.futures.Executor.submit) 创建。

什么是 Future？为什么设计它？它是怎样实现的？

[**PEP 3148**](https://www.python.org/dev/peps/pep-3148)

以及一些 Exception 类。

使用线程池和进程的区别是什么？

它使用进程池来异步地执行调用。 [`ProcessPoolExecutor`](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#concurrent.futures.ProcessPoolExecutor) 会使用 [`multiprocessing`](https://docs.python.org/zh-cn/3/library/multiprocessing.html#module-multiprocessing) 模块，这允许它绕过 [全局解释器锁](https://docs.python.org/zh-cn/3/glossary.html#term-global-interpreter-lock) 但也意味着只可以处理和返回可封存的对象。

[python concurrent.futures 文档](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#module-concurrent.futures)

## 如何使用

= = ，似乎忘记介绍里面的方法了，所以我们首先要看看 Executor 类所提供的接口方法：

- `submit(fn, /, *args, **kargs)` 

  调度可调用对象 *fn*，以 `fn(*args **kwargs)` 方式执行并返回 [`Future`](https://docs.python.org/zh-cn/3/library/concurrent.futures.html#concurrent.futures.Future) 对象代表可调用对象的执行

- `map(func, *iterables, timeout=None, chunksize=1)`

  类似于 [`map(func, *iterables)`](https://docs.python.org/zh-cn/3/library/functions.html#map) 函数，除了以下两点：

  - *iterables* 是立即执行而不是延迟执行的；
  - *func* 是异步执行的，对 *func* 的多个调用可以并发执行。

  > 这里如何判断 func 能不能并发执行

- `shutdown(wait=True, *, cancel_futures=Flase)`

  使用 with 语句可以避免显式调用

### 使用 ThreadPoolExecutor

`ThreadPoolExecutor`(*max_workers=None*, *thread_name_prefix=''*, *initializer=None*, *initargs=()*)

假如我们想要同时下载很多很多图片，而现在我们已经有这些图片的 urls。

~~~python
import requests
import concurrent.future

def download_image(img_url):
    img_bytes = requests.get(img_url).content
    img_name = img_url.split('/')[3]
    img_name = f'{img_name}.jpg'
    with open(img_name, 'wb') as img_file:
        img_file.write(img_bytes)
        print(f'{img_name} was downloaded...')


with concurrent.futures.ThreadPoolExecutor() as executor:
    executor.map(download_image, img_urls)
~~~

### 使用 ProcessPoolExecutor

`ProcessPoolExecutor`(*max_workers=None*, *mp_context=None*, *initializer=None*, *initargs=()*)

~~~python
import concurrent.futures
import math

PRIMES = [
    112272535095293,
    112582705942171,
    112272535095293,
    115280095190773,
    115797848077099,
    1099726899285419]

def is_prime(n):
    if n < 2:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False

    sqrt_n = int(math.floor(math.sqrt(n)))
    for i in range(3, sqrt_n + 1, 2):
        if n % i == 0:
            return False
    return True

def main():
    with concurrent.futures.ProcessPoolExecutor() as executor:
        for number, prime in zip(PRIMES, executor.map(is_prime, PRIMES)):
            print('%d is prime: %s' % (number, prime))

if __name__ == '__main__':
    main()
~~~

