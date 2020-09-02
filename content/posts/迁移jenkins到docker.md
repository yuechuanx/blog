---
title: 迁移 Jenkins 到 Docker
slug: migrate-jenkins-on-docker
date: 2020-08-18T15:36:13+08:00
tags: 
- jenkins
---

![jenkins-logo](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/logo-jenkins.png)

> Jenkins 天然程序和数据分离的属性，使得它能够容易的迁移与升级。
>
> 本文记录想把 Jenkins Service 迁移到 docker 容器内。

## 备份

### 通过脚本打包

最简单的方式是将 Jenkins 的工作目录打包。一般为 `/var/jenkins_home`，或者 `/var/lib/jenkins`。如果你的数据量相当小，请直接用 `tar` 打包。再直接迁移到需要重新部署的 Jenkins 工作目录即可。

> 本文中宿主机的 Jenkins 在 `/var/lib/jenkins` 目录

然而由于当前的 `jenkins_home`里面存放了一些临时文件，以及 `jobs`, `workspace` 目录数据量已经相当大，所以我们打包的时候需要排除一些文件。

*backup.sh*

```bash
#!/bin/bash

current_date=`date "+%Y%m%d%H%M"`
jenkins_backup_path='/home/jks-master/jenkins/backups/backup_'$current_date'.tar'
jenkins_home='/var/lib/jenkins'

#echo $jenkins_backup_path
tar -zcvf $jenkins_backup_path --exclude-from=exclude.txt $jenkins_home
```

*exclude.txt*

```txt
/var/lib/jenkins/jobs
/var/lib/jenkins/workspace

/var/lib/jenkins/backups
/var/lib/jenkins/inbox
/var/lib/jenkins/Anaconda3
/var/lib/jenkins/anaconda3
/var/lib/jenkins/caches
/var/lib/jenkins/.cache
/var/lib/jenkins/Pipeline_*
```

### 通过插件备份

目前 Jenkins 中比较成熟的插件是 ThinBackup。里面提供了相对丰富的配置项

![jenkins-plugin-thinbackup-settings](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/jenkins-plugin-thinbackup-settings.png)得到的压缩文件为下一步迁移作准备。

## 迁移

选择使用的 docker 镜像是 `jenkins/jenkins:lts`。

假定将备份文件解压到`/var/jenkins_home`目录，若之前打包文件包含了 `jobs/`, `workspace/`文件夹，那么只需将文件解压出来再挂载到 docker 容器内即可。

由于文中的实验环境没有将以上两个目录打包进来，所以在启动容器时会挂载多个目录。

如果 *Jenkins* 需要自定义一些工具依赖，环境配置，可以将这些写入 *Dockerfile* ，使用 `docker build` 生成新镜像。

```dockerfile
FROM jenkins/jenkins:lts

USER root

ENV TOOL_CHAIN_PATH=/opt/toolchain

COPY gcc-linaro-5.4.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz /tmp/
COPY gcc-arm-none-eabi-5_2-2015q4-20151219-linux.tar.bz2 /tmp/
COPY jcli-linux-amd64.tar.gz /tmp/

RUN mkdir ${TOOL_CHAIN_PATH} \
    && tar -Jxvf /tmp/gcc-linaro-5.4.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz -C ${TOOL_CHAIN_PATH} \
    && tar -jxvf /tmp/gcc-arm-none-eabi-5_2-2015q4-20151219-linux.tar.bz2 -C ${TOOL_CHAIN_PATH} \
    && tar -zxvf /tmp/jcli-linux-amd64.tar.gz -C /tmp \
    && cp /tmp/jcli /usr/local/bin \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone \
    && sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && apt update && apt install --no-install-recommends -y zlib1g-dev libmagickwand-dev \
        lib32z1 lib32ncurses5 lib32stdc++6 squashfs-tools mtd-utils texinfo autopoint bison flex \
        liblz4-tool u-boot-tools \
        curl fakeroot wget vim htop python3 python3-pip python3-setuptools tree git autoconf automake make gcc \
    && pip3 install --upgrade pip \
    && rm -rf /tmp/*

USER jenkins
```

`COPY` 后的文件需和 *dockerfile* 放置在同一目录下，`docker build . -t jenkins:<YOUR TAG>`

## 磁盘RAID（可选）

由于我们是通过 mount 主机的目录到容器中 `jenkins_home`，为了保证数据可靠性，把数据所在的磁盘组了 RAID1 。

## 安装 `mdadm`

```bash
apt install mdamd
```

mdadm 参数

- -Cv 创建阵列

- -l -n -x 阵列级别 几个硬盘组raid 几个热备盘

- -D 查看信息

- -D -s 写入配置文件

- -f -r -a 模拟损坏 拔除硬盘 插回硬盘

- -G -n 将新增的热备盘加入阵列

- -S 停止raid

### 创建磁盘阵列

```bash
# 创建阵列
mdadm -Cv /dev/md5 -l5 -n3 -x1 /dev/sd[bcde] 
# -C 创建冗余 
# v显示过程 
# -l raid级别
# n raid硬盘数 
# x热备盘数量

# 查看同步进度
madam -D /dev/md5 
# 另一种查看方法
*cat /proc/mdstat 

# 创建文件系统
mkfs.ext4 /dev/md5

mdadm -D -s >/etc/mdadm.conf 生成配置文件并在末尾加auto=yes (*不生成配置文件 开机raid损坏)

mdadm /dev/md5 -f /dev/sdb 模拟sdb损坏 -f损坏

mdadm /dev/md5 -r /dev/sdb 拔出模拟损坏的sdb

mdadm /dev/md5 -a /dev/sdb 插回模拟损坏的sdb

mdadm -G /dev/md5 -n4     raid拉伸 把热备盘sdb也加入磁盘阵列

resize2fs /dev/md5 在线动态格式化 使新加入的sdb容量也被挂在上
```

### 正确完成创建后

```bash
NAME    MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
loop0     7:0    0   276K  1 loop  /snap/gnome-characters/539
loop1     7:1    0   276K  1 loop  /snap/gnome-characters/550
loop2     7:2    0   2.2M  1 loop  /snap/gnome-system-monitor/148
loop3     7:3    0  62.1M  1 loop  /snap/gtk-common-themes/1506
loop4     7:4    0    55M  1 loop  /snap/core18/1880
loop5     7:5    0   2.2M  1 loop  /snap/gnome-system-monitor/145
loop6     7:6    0   956K  1 loop  /snap/gnome-logs/93
loop7     7:7    0  54.8M  1 loop  /snap/gtk-common-themes/1502
loop8     7:8    0 161.4M  1 loop  /snap/gnome-3-28-1804/128
loop9     7:9    0   2.4M  1 loop  /snap/gnome-calculator/730
loop10    7:10   0   956K  1 loop  /snap/gnome-logs/100
loop11    7:11   0 140.7M  1 loop  /snap/gnome-3-26-1604/100
loop12    7:12   0  55.3M  1 loop  /snap/core18/1885
loop13    7:13   0   2.4M  1 loop  /snap/gnome-calculator/748
loop14    7:14   0 160.2M  1 loop  /snap/gnome-3-28-1804/116
loop15    7:15   0 255.6M  1 loop  /snap/gnome-3-34-1804/36
loop16    7:16   0  96.6M  1 loop  /snap/core/9804
loop17    7:17   0    97M  1 loop  /snap/core/9665
loop18    7:18   0 140.7M  1 loop  /snap/gnome-3-26-1604/98
loop19    7:19   0 255.6M  1 loop  /snap/gnome-3-34-1804/33
sda       8:0    0 238.5G  0 disk
├─sda1    8:1    0   512M  0 part  /boot/efi
└─sda2    8:2    0   238G  0 part  /
sdb       8:16   0   7.3T  0 disk
└─md127   9:127  0   7.3T  0 raid1 /mnt/hdd
sdc       8:32   0   7.3T  0 disk
└─md127   9:127  0   7.3T  0 raid1 /mnt/hdd
```

### 正确删除软raid方法

```bash
1 umount /md5  先卸载阵列

2 mdadm -S /dev/md5 停止raid运行 (*大S stop)

3 mdadm --misc --zero-superblock /dev/sd[bcdef] 删除磁盘

4 删除配置文件 (*如果fstab或rc.local配置了自动挂载都要删除)
```

### 总结

- 创建完raid要等同步到100%后再格式化

- raid拉伸后要把拉伸的部分resize2fs格式化

- 删除时 停止挂载 停止raid 删除硬盘 删配置文件

涉及目录

- /etc/mdadm.conf 要手动生成这个配置文件 里面内容末尾加上auto=yes 否则开机会raid损坏

- /proc/mdstat 通过查看这个文件可以监控raid工作状态 几个U代表几个盘在工作

## 启动

*start_docker_jenkins.sh*

```bash
#!/bin/bash

docker run -d \
-u 1000:1000 \
-v /var/jenkins_home:/var/jenkins_home \
-v /var/lib/jenkins/jobs:/var/jenkins_home/jobs \
-v /var/lib/jenkins/workspace:/var/jenkins_home/workspace \
-p 8080:8080 \
-p 50000:50000 \
jenkins/jenkins:<TAG>
```

> 50000 端口用来作为 slave 通信，在 异常情况 第二种提到

启动后，获取到容器的 id，使用 `docker logs [ID]` 查看是否有错误。

## 异常情况

- `jenkins.model.InvalidBuildsDir: ${ITEM_ROOTDIR}/builds does not exist and probably cannot be created`

  这个错误的原因是权限问题。需要检查启动 docker 的用户所挂载的目录是否有权限读写。如果没有的话可更改目录的持有者：

  `chown -R [USER] [DIR] `

  > 关于 docker容器的权限问题可以见参考一节前两篇文章
  
- Windows Node 无法与 Master 通信

  ![jenkins-master-slave-connection-error](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/jenkins-master-slave-connection-error.png)

  在 Manage Jenkins -> Configure Global Security -> Agents 中配置

   ![jenkins-agents-port-config](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/jenkins-agents-port-config.png)

## 参考

[docker挂载volume的用户权限问题,理解docker容器的uid](https://www.cnblogs.com/woshimrf/p/understand-docker-uid.html)

[理解 docker 容器中的 uid 和 gid](https://www.cnblogs.com/sparkdev/p/9614164.html)

