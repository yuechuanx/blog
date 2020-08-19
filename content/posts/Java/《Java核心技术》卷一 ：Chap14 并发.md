---
title: 《Java核心技术》卷一 ：Chap14 并发
slug: corejava--chap14-concurrency
categories:
  - Java
tags:
- java
date: 2020-08-14 11:18:31
---
# 《Java核心技术》卷一 ：Chap14 并发

1. 解释：多任务(Multitasking)，多线程(Multithreaded)

2. 多进程和多线程区别？

3. 线程执行一个任务的过程？

4. 如何定义一个线程？

   警告：

5. 如何中断线程？

6. 线程有哪些状态？

7. 线程有哪些属性？

8. 为什么存在线程同步？

   因为存在竞争条件(race condition)。竞争条件是指两个或两个以上线程需要共享对同一数据的存取所导致的讹误。之所以会出现是因为执行存取动作并不是原子操作(动作在执行中被中断)。

9. 如何同步存取？

   添加锁对象。