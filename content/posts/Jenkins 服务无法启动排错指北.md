---
title: Jenkins 服务无法启动排错指北
slug: jenkins-service-cannot-be-started
date: 2020-08-14 11:12:59
---
# Jenkins 服务无法启动排错指北

## 问题定位

start service:

`service jenkins start ` 

then check service status:

`service jenkins status ` 

for detail log info:

`journalctl -xe -u jenkins.service`

## 常见原因

1. 端口争用

   如果 jenkins 服务端口在 8080，可以查看 8080 端口是否被其他服务所占用

   `sudo lsof -i:8080`

   假设是被一个叫 `http-alt` 的服务占用了，接下来把 8080 端口的服务 kill 掉

   `sudo htop`

   > 这里加 `sudo` 是为了为 htop 里面 kill 赋予 root 权限

   `/http-alt` 查找到服务，可能有多行，摁下 F5 sort 下，找到父进程 

   再摁下 F9 发送 kill 信号

   最后摁下 9 

   相当于执行 `kill PID -9`



Have fun

