---
title: 问题梳理-Java多线程
categories:
  - Java
tags:
  - multithread
  - interview
translate_title: problem-combingjava-multithreading
date: 2019-01-03 20:10:39
---

## 1. 简述线程，程序、进程的基本概念。以及他们之间关系是什么？

**线程**与进程相似，但线程是一个比进程更小的执行单位。一个进程在其执行的过程中可以产生多个线程。与进程不同的是同类的多个线程共享同一块内存空间和一组系统资源，所以系统在产生一个线程，或是在各个线程之间作切换工作时，负担要比进程小得多，也正因为如此，线程也被称为轻量级进程。  

**程序**是含有指令和数据的文件，被存储在磁盘或其他的数据存储设备中，也就是说程序是静态的代码。

**进程**是程序的一次执行过程，是系统运行程序的基本单位，因此进程是动态的。系统运行一个程序即是一个进程从创建，运行到消亡的过程。简单来说，一个进程就是一个执行中的程序，它在计算机中一个指令接着一个指令地执行着，同时，每个进程还占有某些系统资源如CPU时间，内存空间，文件，文件，输入输出设备的使用权等等。换句话说，当程序在执行时，将会被操作系统载入内存中。

**线程** 是 **进程** 划分成的更小的运行单位。线程和进程最大的不同在于基本上各进程是独立的，而各线程则不一定，因为同一进程中的线程极有可能会相互影响。从另一角度来说，进程属于操作系统的范畴，主要是同一段时间内，可以同时执行一个以上的程序，而线程则是在同一程序内几乎同时执行一个以上的程序段。

**线程上下文的切换比进程上下文切换要快很多**

- 进程切换时，涉及到当前进程的CPU环境的保存和新被调度运行进程的CPU环境的设置。
- 线程切换仅需要保存和设置少量的寄存器内容，不涉及存储管理方面的操作。

## 2. 线程有哪些基本状态？这些状态是如何定义的?

1. **新建(new)**：新创建了一个线程对象。
2. **可运行(runnable)**：线程对象创建后，其他线程(比如main线程）调用了该对象的start()方法。该状态的线程位于可运行线程池中，等待被线程调度选中，获 取cpu的使用权。
3. **运行(running)**：可运行状态(runnable)的线程获得了cpu时间片（timeslice），执行程序代码。
4. **阻塞(block)**：阻塞状态是指线程因为某种原因放弃了cpu使用权，也即让出了cpu timeslice，暂时停止运行。直到线程进入可运行(runnable)状态，才有 机会再次获得cpu timeslice转到运行(running)状态。阻塞的情况分三种：
  - **(一). 等待阻塞**：运行(running)的线程执行o.wait()方法，JVM会把该线程放 入等待队列(waiting queue)中。
  - **(二). 同步阻塞**：运行(running)的线程在获取对象的同步锁时，若该同步  锁 被别的线程占用，则JVM会把该线程放入锁池(lock pool)中。
  - **(三). 其他阻塞**: 运行(running)的线程执行Thread.sleep(long ms)或t.join()方法，或者发出了I/O请求时，JVM会把该线程置为阻塞状态。当sleep()状态超时join()等待线程终止或者超时、或者I/O处理完毕时，线程重新转入可运行(runnable)状态。
5. **死亡(dead)**：线程run()、main()方法执行结束，或者因异常退出了run()方法，则该线程结束生命周期。死亡的线程不可再次复生。

![](https://user-gold-cdn.xitu.io/2018/8/9/1651f19d7c4e93a3?w=876&h=492&f=png&s=128092)

备注： 可以用早起坐地铁来比喻这个过程（下面参考自牛客网某位同学的回答）：

1. 还没起床：sleeping 
2. 起床收拾好了，随时可以坐地铁出发：Runnable 
3. 等地铁来：Waiting 
4. 地铁来了，但要排队上地铁：I/O阻塞 
5. 上了地铁，发现暂时没座位：synchronized阻塞 
6. 地铁上找到座位：Running 
7. 到达目的地：Dead


##  3. 何为多线程？

多线程就是多个线程同时运行或交替运行。单核CPU的话是顺序执行，也就是交替运行。多核CPU的话，因为每个CPU有自己的运算器，所以在多个CPU中可以同时运行。


## 4. 为什么多线程是必要的？

1. 使用线程可以把占据长时间的程序中的任务放到后台去处理。
2. 用户界面可以更加吸引人，这样比如用户点击了一个按钮去触发某些事件的处理，可以弹出一个进度条来显示处理的进度。
3. 程序的运行速度可能加快。

## 5 使用多线程常见的三种方式

### ①继承Thread类

MyThread.java

```java
public class MyThread extends Thread {
	@Override
	public void run() {
		super.run();
		System.out.println("MyThread");
	}
}
```
Run.java

```java
public class Run {

	public static void main(String[] args) {
		MyThread mythread = new MyThread();
		mythread.start();
		System.out.println("运行结束");
	}

}

```
运行结果：
![结果](https://user-gold-cdn.xitu.io/2018/3/20/16243e80f22a2d54?w=161&h=54&f=jpeg&s=7380)
从上面的运行结果可以看出：线程是一个子任务，CPU以不确定的方式，或者说是以随机的时间来调用线程中的run方法。

### ②实现Runnable接口
推荐实现Runnable接口方式开发多线程，因为Java单继承但是可以实现多个接口。

MyRunnable.java

```java
public class MyRunnable implements Runnable {
	@Override
	public void run() {
		System.out.println("MyRunnable");
	}
}
```

Run.java

```java
public class Run {

	public static void main(String[] args) {
		Runnable runnable=new MyRunnable();
		Thread thread=new Thread(runnable);
		thread.start();
		System.out.println("运行结束！");
	}

}
```
运行结果：
![运行结果](https://user-gold-cdn.xitu.io/2018/3/20/16243f4373c6141a?w=137&h=46&f=jpeg&s=7316)

### ③使用线程池

**在《阿里巴巴Java开发手册》“并发处理”这一章节，明确指出线程资源必须通过线程池提供，不允许在应用中自行显示创建线程。**

**为什么呢？**

> **使用线程池的好处是减少在创建和销毁线程上所消耗的时间以及系统资源开销，解决资源不足的问题。如果不使用线程池，有可能会造成系统创建大量同类线程而导致消耗完内存或者“过度切换”的问题。**

**另外《阿里巴巴Java开发手册》中强制线程池不允许使用 Executors 去创建，而是通过 ThreadPoolExecutor 的方式，这样的处理方式让写的同学更加明确线程池的运行规则，规避资源耗尽的风险**

> Executors 返回线程池对象的弊端如下：
> 
> - **FixedThreadPool 和 SingleThreadExecutor** ： 允许请求的队列长度为 Integer.MAX_VALUE,可能堆积大量的请求，从而导致OOM。
> - **CachedThreadPool 和 ScheduledThreadPool** ： 允许创建的线程数量为 Integer.MAX_VALUE ，可能会创建大量线程，从而导致OOM。

对于线程池感兴趣的可以查看我的这篇文章：[《Java多线程学习（八）线程池与Executor 框架》](http://mp.weixin.qq.com/s?__biz=MzU4NDQ4MzU5OA==&mid=2247484042&idx=1&sn=541dbf2cb969a151d79f4a4f837ee1bd&chksm=fd9854ebcaefddfd1876bb96ab218be3ae7b12546695a403075d4ed22e5e17ff30ebdabc8bbf#rd) 点击阅读原文即可查看到该文章的最新版。


## 6 线程的优先级

每个线程都具有各自的优先级，**线程的优先级可以在程序中表明该线程的重要性，如果有很多线程处于就绪状态，系统会根据优先级来决定首先使哪个线程进入运行状态**。但这个并不意味着低
优先级的线程得不到运行，而只是它运行的几率比较小，如垃圾回收机制线程的优先级就比较低。所以很多垃圾得不到及时的回收处理。

**线程优先级具有继承特性。** 比如A线程启动B线程，则B线程的优先级和A是一样的。

**线程优先级具有随机性。** 也就是说线程优先级高的不一定每一次都先执行完。

Thread类中包含的成员变量代表了线程的某些优先级。如**Thread.MIN_PRIORITY（常数1）**，**Thread.NORM_PRIORITY（常数5）**,
**Thread.MAX_PRIORITY（常数10）**。其中每个线程的优先级都在**Thread.MIN_PRIORITY（常数1）** 到**Thread.MAX_PRIORITY（常数10）** 之间，在默认情况下优先级都是**Thread.NORM_PRIORITY（常数5）**。

学过操作系统这门课程的话，我们可以发现多线程优先级或多或少借鉴了操作系统对进程的管理。


## 7 Java多线程分类

### 用户线程

运行在前台，执行具体的任务，如程序的主线程、连接网络的子线程等都是用户线程

### 守护线程

运行在后台，为其他前台线程服务.也可以说守护线程是JVM中非守护线程的 **“佣人”**。


- **特点：** 一旦所有用户线程都结束运行，守护线程会随JVM一起结束工作
- **应用：** 数据库连接池中的检测线程，JVM虚拟机启动后的检测线程
- **最常见的守护线程：** 垃圾回收线程


**如何设置守护线程？**

可以通过调用 Thead 类的 `setDaemon(true)` 方法设置当前的线程为守护线程。

注意事项：

	1.  setDaemon(true)必须在start（）方法前执行，否则会抛出IllegalThreadStateException异常
	2. 在守护线程中产生的新线程也是守护线程
	3. 不是所有的任务都可以分配给守护线程来执行，比如读写操作或者计算逻辑


##  8 sleep()方法和wait()方法简单对比

- 两者最主要的区别在于：**sleep方法没有释放锁，而wait方法释放了锁** 。 
- 两者都可以暂停线程的执行。
- Wait通常被用于线程间交互/通信，sleep通常被用于暂停执行。
- wait()方法被调用后，线程不会自动苏醒，需要别的线程调用同一个对象上的notify()或者notifyAll()方法。sleep()方法执行完成后，线程会自动苏醒。


## 9 为什么我们调用start()方法时会执行run()方法，为什么我们不能直接调用run()方法？

这是另一个非常经典的java多线程面试问题，而且在面试中会经常被问到。很简单，但是很多人都会答不上来！

new一个Thread，线程进入了新建状态;调用start()方法，会启动一个线程并使线程进入了就绪状态，当分配到时间片后就可以开始运行了。 
start()会执行线程的相应准备工作，然后自动执行run()方法的内容，这是真正的多线程工作。 而直接执行run()方法，会把run方法当成一个mian线程下的普通方法去执行，并不会在某个线程中执行它，所以这并不是多线程工作。

**总结： 调用start方法方可启动线程并使线程进入就绪状态，而run方法只是thread的一个普通方法调用，还是在主线程里执行。**



