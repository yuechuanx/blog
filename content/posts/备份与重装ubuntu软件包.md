---
title: 备份与重装 Apt 软件包
slug: backup-apt-packages
date: 2020-09-08T19:58:33+08:00
tags:
- linux
---

> 作为基本在 Linux/Unix 环境下干活的来说，配环境就是家常便饭。
>
>  有时你需要把一台机器的环境在另外一台机器重新配置，这就很烦啊…...

## APT 软件包备份

使用 apt-clone 包就能备份系统上已安装软件列表

### 安装 `apt-clone`

```bash
sudo apt install apt-clone
```

### 备份

新建个文件夹保存备份文件，之后直接开始备份就好了

```bash
mkdir ~/mypackages
sudo apt-clone clone ~/mypackages
not installable: sogoupinyin, atom, lantern version mismatch: libwebkit2gtk-4.0-37, unattended-upgrades, liblouis-data, firefox-locale-en, ubuntu-release-upgrader-core, ubuntu-release-upgrader-gtk, gir1.2-webkit2-4.0, update-manager-core, firefox-locale-zh-hans, python3-louis, update-manager, python3-distupgrade, libjavascriptcoregtk-4.0-18, gir1.2-javascriptcoregtk-4.0, python3-update-manager, firefox, liblouis14

Note that you can use --with-dpkg-repack to include those packges in the clone file.
```

`~/mypackages`文件夹下应该有一个名为`apt-clone-state-*.tar.gz`压缩包

```bash
cd ~/mypackages
tar -xvf apt-clone-state-ubuntu.tar.gz
```

解压之后文件夹结构大概如下

```bash
.
├── etc
│   └── apt
│       ├── preferences.d
│       ├── sources.list
│       ├── sources.list.d
│       │   ├── google-chrome.list
│       │   ├── notepadqq-team-ubuntu-notepadqq-bionic.list
│       │   ├── numix-ubuntu-ppa-bionic.list
│       │   ├── sogoupinyin.list
│       │   ├── vscode.list
│       │   └── webupd8team-ubuntu-atom-bionic.list
│       ├── trusted.gpg
│       └── trusted.gpg.d
│           ├── microsoft.gpg
│           ├── notepadqq-team_ubuntu_notepadqq.gpg
│           ├── numix_ubuntu_ppa.gpg
│           ├── sogou-archive-keyring.gpg -> /usr/share/keyrings/sogou-archive-keyring.gpg
│           ├── ubuntu-keyring-2012-archive.gpg
│           ├── ubuntu-keyring-2012-cdimage.gpg
│           └── webupd8team_ubuntu_atom.gpg
└── var
    └── lib
        └── apt-clone
            ├── extended_states
            ├── foreign.pkgs
            ├── installed.pkgs
            └── uname

8 directories, 19 files
```

其中 var/lib/apt-clone/installed.pkgs 记录已安装的包，另外 apt-clone 还会备份软件源等其他一些设置。

### 恢复

```bash
# 查看备份包信息
apt-clone info mypackages/apt-clone-state-ubuntu.tar.gz 
```

使用如下命令在新系统中恢复安装备份的软件包

```bash
sudo apt-clone restore apt-clone-state-ubuntu.tar.gz
```

## 参考

 - [Backup Installed Packages And Restore Them On Freshly Installed Ubuntu System](https://link.zhihu.com/?target=https%3A//www.ostechnix.com/backup-installed-packages-and-restore-them-on-freshly-installed-ubuntu-system/)

