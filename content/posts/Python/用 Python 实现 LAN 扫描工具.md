---
title: 用 Python 实现 LAN 扫描工具
slug: use-python-to-implement-lan-scanning-tool
categories:
  - Python
tags:
  - network
date: 2020-08-13 16:37:05
---
# 用 Python 实现 LAN 扫描工具

> 树莓派没装 GUI，插上网线后找不到 IP 

当然有很多种方法可以解决这个场景

- arp -a 可以查看所在局域网里所有的设备 IP 与 MAC 
- nmap 

如果在 Mac 情况下，可以通过 APPStore 下载 LANScan

![LanScan](https://img-blog.csdnimg.cn/20190324140709443.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0JsdWVCbHVlU2t5Wg==,size_16,color_FFFFFF,t_70)



这里写一个简单的 python 脚本来达到相似的效果。

```Python
#!/usr/bin/env python3
# -*- coding: UTF-8 -*-
"""
扫描网关所在子网 Host 信息
"""

import os
import sys
import netifaces
import nmap

from collections import namedtuple
from prettytable import PrettyTable


def switch_root():
    """ 提升到root权限 """
    if os.geteuid():
        args = [sys.executable] + sys.argv
        # 下面两种写法，一种使用su，一种使用sudo，都可以
        # os.execlp('su', 'su', '-c', ' '.join(args))
        os.execlp('sudo', 'sudo', *args)

    # 从此处开始是正常的程序逻辑
    print('Running at root privilege.')


def get_gateway():
    """ 获取默认网关 """
    return netifaces.gateways()['default'][netifaces.AF_INET][0]


def lan_scan(gateway):
    nm = nmap.PortScanner()
    infos = []
    lan_net = gateway + '/24'
    scan_rst = nm.scan(lan_net, arguments='-sn')
    scanstats = scan_rst['nmap']['scanstats']
    for host in sorted(nm.all_hosts(), key=lambda x: int(x.split('.')[-1])):
        addr = scan_rst['scan'][host]['addresses']['ipv4']
        mac = scan_rst['scan'][host]['addresses'].get('mac', 'None')
        hostname = scan_rst['scan'][host]['hostnames'][0]['name']
        vendor = scan_rst['scan'][host]['vendor'].get(mac, 'None')
        info = [addr, mac, hostname, vendor]
        infos.append(info)
    return infos


def print_table(ips_info):
    table = PrettyTable(['index', 'addr', 'mac', 'hostname', 'vendor'])
    table.board = True
    for i, info in enumerate(ips_info):
        table.add_row([i] + info)
    print(table)


def main():
    switch_root()
    print_table(lan_scan(get_gateway()))


if __name__ == "__main__":
    main()

```

如果想要生成涵盖更多信息的表格，需要调整 `nm.scan()` 里的 `arguments` 参数内容。

