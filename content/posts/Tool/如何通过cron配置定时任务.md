---
title: 如何通过cron配置定时任务
date: 2020-08-19T15:38:23+08:00
categories:
- Tool
tags:
- tools
draft: true
---

> *cron* 是一个在 Unix 及类似操作系统上执行计划任务的程序。用户可以在指定的时间段周期性地运行命令或 shell 脚本，通常用于系统的自动化维护或者管理。
>
> [Wikipedia](https://en.wikipedia.org/wiki/Cron)
>
> 本文将介绍如何配置和使用 cron

<!--more-->

## 安装

- Debian/Ubuntu

  ```bash
  sudo apt install cron
  ```

- Arch

  cron 有多个实现程序，但是基础系统默认使用 [systemd/Timers](https://wiki.archlinux.org/index.php/Systemd/Timers_(简体中文))。

  > 关于 Systemd/Timers 使用，可以阮一峰老师的 [Systemd 定时器教程](http://www.ruanyifeng.com/blog/2018/03/systemd-timer.html)

  下面的实现都没有安装，用户可以选择其一进行安装。[Gentoo Linux Cron 指南](http://www.gentoo.org/doc/en/cron-guide.xml) 提供了一个这些实现之间的比较。软件包:

  - [cronie](https://www.archlinux.org/packages/?name=cronie)
  - [fcron](https://www.archlinux.org/packages/?name=fcron)
  - [dcron](https://aur.archlinux.org/packages/dcron/)AUR
  - [vixie-cron](https://aur.archlinux.org/packages/vixie-cron/)AUR
  - [scron-git](https://aur.archlinux.org/packages/scron-git/)AUR

- macOS

  略

## 配置

### 激活以及开机启动

### 处理任务的错误

## Crontab

### 格式



### 相关命令

## 范例

## 参考

[Archlinux Wiki Cron](https://wiki.archlinux.org/index.php/Cron_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

[Crontab 编辑器](https://crontab.guru/)

