---
title: 迁移 Jenkins 到 Docker
slug: migrate-jenkins-on-docker
date: 2020-08-18T15:36:13+08:00
tags: 
- jenkins
draft: true
---

![jenkins-logo](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/logo-jenkins.png)

> Jenkins 天然程序和数据分离的属性，使得它能够容易的迁移与升级。
>
> 这次想把通过在 Host 上运行的 Jenkins 迁移到 docker 容器内。

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

目前 Jenkins 中比较成熟的插件是 ThinBackup



得到的压缩文件为下一步迁移作准备。

## 迁移

选择使用的 docker 镜像是 `jenkins/jenkins:lts`。

假定将备份文件解压到`/var/jenkins_home`目录，若之前打包文件包含了 `jobs/`, `workspace/`文件夹，那么只需将文件解压出来再挂载到 docker 容器内即可。

由于文中的实验环境没有将以上两个目录打包进来，所以在启动容器时会挂载多个目录。

*start_docker_jenkins.sh*

```bash
#!/bin/bash

docker run -d \
-u 1000:1000 \
-v /var/jenkins_home:/var/jenkins_home \
-v /var/lib/jenkins/jobs:/var/jenkins_home/jobs \
-v /var/lib/jenkins/workspace:/var/jenkins_home/workspace \
-p 8081:8080 \
-p 50001:50000 \
jenkins/jenkins:lts
```

启动后，获取到容器的 id，使用 `docker logs [ID]` 查看是否有错误。

## 异常情况

- `jenkins.model.InvalidBuildsDir: ${ITEM_ROOTDIR}/builds does not exist and probably cannot be created`

  这个错误的原因是权限问题。需要检查启动 docker 的用户所挂载的目录是否有权限读写。如果没有的话可更改目录的持有者：

  `chown -R [USER] [DIR] `

  > 关于 docker容器的权限问题可以见参考一节前两篇文章

## 参考

[docker挂载volume的用户权限问题,理解docker容器的uid](https://www.cnblogs.com/woshimrf/p/understand-docker-uid.html)

[理解 docker 容器中的 uid 和 gid](https://www.cnblogs.com/sparkdev/p/9614164.html)

