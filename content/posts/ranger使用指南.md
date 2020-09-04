---
title: "Ranger使用指南"
date: 2020-09-04T14:12:06+08:00
draft: true

---

![ranger-preview](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/ranger-preview.png)

> ranger is a console file manager with VI key bindings. It provides a minimalistic and nice curses interface with a view on the directory hierarchy. It ships with `rifle`, a file launcher that is good at automatically finding out which program to use for what file type.
>
> Ranger是具有VI键绑定的控制台文件管理器。它提供了一个简单而美观的curses界面，并具有目录层次结构的视图。它带有`rifle`一个文件启动器，该文件启动器擅长自动找出要用于哪种文件类型的程序。
>
> 本文将介绍 ranger 的用法以及如何配置 ranger

## 特性

- UTF-8支持（如果您的Python支持它）
- 多列显示
- 预览所选文件/目录
- 常用文件操作（创建/ 更改权限 /复制/删除/ ...）
- 一次重命名多个文件
- 类似于VIM的控制台和热键
- 自动确定文件类型并使用正确的程序运行它们
- 退出ranger后更改外壳目录
- 标签，书签，鼠标支持...

<!--more-->

## 依赖

- Python (`>=2.6` 或 `>=3.1`) with the `curses` module and (optionally) wide-unicode support
- A pager (`less` by default)

### 可选依赖

一般用途：

- `file` 用于确定文件类型
- `chardet` （Python软件包）用于改进文本文件的编码检测
- `sudo` 使用“以root用户运行”功能
- `python-bidi` （Python软件包）以正确显示从右到左的文件名（希伯来语，阿拉伯语）

对于增强的文件预览（带有`scope.sh`）：

- `img2txt`（来自`caca-utils`）用于ASCII图像预览
- `w3mimgdisplay`，`ueberzug`，`mpv`，`iTerm2`，`kitty`，`terminology`或`urxvt`用于图像预览
- `convert`（从`imagemagick`）以自动旋转图像并进行SVG预览
- `ffmpegthumbnailer` 用于视频缩略图
- `highlight`，`bat`或`pygmentize`用于代码的语法突出显示
- `atool`，`bsdtar`，`unrar`和/或`7z`预览档案
- `bsdtar`，`tar`，`unrar`，`unzip`和/或`zipinfo`（和`sed`）对预览档案作为其第一图像
- `lynx`，`w3m`或`elinks`预览html页面
- `pdftotext`或`mutool`（和`fmt`）进行文本`pdf`预览，`pdftoppm`以图像预览
- `djvutxt`用于文本DjVu预览，`ddjvu`以图像预览
- `calibre`或`epub-thumbnailer`用于电子书的图像预览
- `transmission-show` 用于查看BitTorrent信息
- `mediainfo`或`exiftool`用于查看有关媒体文件的信息
- `odt2txt`为OpenDocument文本文件（`odt`，`ods`，`odp`和`sxw`）
- `python`或`jq`JSON文件
- `fontimage` 用于字体预览
- `openscad`对于3D模型预览（`stl`，`off`，`dxf`，`scad`，`csg`）

## 安装

- 通过 pip 安装

```bash
pip install ranger-fm
```

- 通过包管理器 

  ```bash
  # macOS
  brew install ranger
  
  # ubuntu
  apt install ranger
  
  # arch 
  pacman -Sy ranger
  ```

## 用法

### **选项**

```bash
renger --help

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -d, --debug           activate debug mode
  -c, --clean           don't touch/require any config files.
  --logfile=file        log file to use, '-' for stderr
  --cachedir=dir        change the cache directory.
                        (/Users/Xiaoy/.cache/ranger)
  -r dir, --confdir=dir
                        change the configuration directory.
                        (/Users/Xiaoy/.config/ranger)
  --datadir=dir         change the data directory.
                        (/Users/Xiaoy/.local/share/ranger)
  --copy-config=which   copy the default configs to the local config
                        directory. Possible values: all, rc, rifle, commands,
                        commands_full, scope
  --choosefile=OUTFILE  Makes ranger act like a file chooser. When opening a
                        file, it will quit and write the name of the selected
                        file to OUTFILE.
  --choosefiles=OUTFILE
                        Makes ranger act like a file chooser for multiple
                        files at once. When opening a file, it will quit and
                        write the name of all selected files to OUTFILE.
  --choosedir=OUTFILE   Makes ranger act like a directory chooser. When ranger
                        quits, it will write the name of the last visited
                        directory to OUTFILE
  --selectfile=filepath
                        Open ranger with supplied file selected.
  --show-only-dirs      Show only directories, no files or links
  --list-unused-keys    List common keys which are not bound to any action.
  --list-tagged-files=tag
                        List all files which are tagged with the given tag,
                        default: *
  --profile             Print statistics of CPU usage on exit.
  --cmd=COMMAND         Execute COMMAND after the configuration has been read.
                        Use this option multiple times to run multiple

```



| 选项                     | 说明                                                         |
| :----------------------- | ------------------------------------------------------------ |
| -d, --debug              | 调试模式：当发生错误时，Ranger 会退出并打印回溯。            |
| -c, --clean              | 干净模式：Ranger 不会读取或者创造任何配置文件，不会在系统内留下任何痕迹。 |
| -r dir, --confdir=dir    | 将 Ranger 的配置文件夹从 ~/.config/ranger 改为 dir。         |
| --copy-config=file       | 复制一份默认的配置文件到 Ranger 的配置文件夹内，已存在的不会被盖写。file 包括 all、commands、commands_full、rc、rifle 和 scope。 |
| --choosefile=targetfile  | 允许你使用 Ranger 选择一个 targetfile 文件，当你用在 Ranger 中用 r 命令打开一个文件时，Ranger 会退出，并将这个文件的绝对路径写入 targetfile 文件。 |
| --choosefiles=targetfile | 可以选择多个文件的绝对路径写入 targetfile 文件，每一个占一行，按字母升序排列。 |
| --choosedir=targetfile   | 将退出 Ranger 后的最后一个访问过的文件的绝对路径写入 targetfile 文件。 |
| --selectfile=targetfile  | Ranger 的光标跳转到 targetfile 文件。                        |
| --list-unused-Keys       | 列出在浏览器环境中未绑定任何动作的按键                       |
| --list-tagged-files=tag  | 列出用给定 tag 标记的所有文件。注意：标签是单个字符，默认标记为 *。 |
| --profile                | 退出时打印 CPU 使用情况的统计信息。                          |
| --cmd=command            | 在配置文件读取完成后执行 command 命令。多次使用此选项运行多个命令。 |
| --version                | 打印版本信息并退出                                           |
| -h, --help               | 打印此选项列表并退出                                         |

## **一些概念**

  这个部分解释了 Ranger 中的一些重要部分是怎么工作的，并且怎么高效地使用它们。

## 预览

  默认情况下，只能预览文本文件，但是你可以通过设定配置 use_preview_script 和 preview_files 为 true 来增加可以预览的文件类型。默认的预览脚本是 ~/.config/ranger/scope.sh，安装如下工具（每种类型只需要一个）就预览对应的文件类型，scope.sh 会自动调用它们：

| 工具                               | 预览文件类型 | 安装                                                         |
| ---------------------------------- | ------------ | ------------------------------------------------------------ |
| **lynx****elinks** **w3m**         | 网页         | sudo apt install lynxsudo apt install elinkssudo apt install w3m |
| **highlight****pygmentize**        | 高亮代码     | sudo apt install highlightpip install pygmentize             |
| **img2txt**                        | 图片         | sudo apt install caca-utils                                  |
| **atool****bsdtar****unrar****7z** | 压缩包       | sudo apt install atoolsudo apt install libarchive-toolssudo apt install unrarsudo apt install p7zip |
| **pdftotext****mutool**            | PDF          | `sudo apt install poppler-utils`<br />`<br />`sudo apt install mupdf-tools` |
| **mediainfo****exiftool**          | 媒体         | `sudo apt install mediainfo`<br />`sudo apt install libimage-exiftool-perl` |
| **ffmpegthumbnailer**              | 视频缩略图   | `sudo apt install ffmpegthumbnailer`                         |
| **fontimage**                      | 字体         | `sudo apt install fontforge`                                 |
| **transmission-show**              | 种子         | `sudo apt install transmission-cli`                          |

  独立于 preview script，有一个通过将图像用字符画的形式直接绘制到终端中的预览功能。要启用此功能，将 preview_images 选项设置为 true 并将 preview_images_method 选项设置为一种图像预览模式（需要安装这些工具）：

| 预览模式       | 是否适用于 ssh | 注意                                                         | 设置 preview_images_method 为 |
| -------------- | -------------- | ------------------------------------------------------------ | ----------------------------- |
| **w3m**        | 否             | 与 tmux 不兼容（尽管它可以工作）。                           | w3m                           |
| **iTerm2**     | 是             | iTerm2 编译时必须添加 image preview support 选项。           | iterm2                        |
| **urxvt**      | 否             | urxvt 编译时必须添加 pixbuf support 选项。此模式本质上是将图像暂时设置为终端背景，这样它将破坏以前设置的任何图像背景。 | urxvt                         |
| **urxvt-full** | 否             | 与 **urxvt** 相同，但使用整个终端窗口预览图片。              | urxvt-full                    |

### **选择**

  选择被定义为**如果有标记，则是所有标记的文件，否则是光标处的文件。**在使用 :delete 命令时一定要注意这一点，它指删除选择的所有文件及文件夹。你可以通过按 SPACE、v 等来标记文件。黄色的 Mrk 符号位于终端右下角，表示此文件夹里有标记的文件。黄色的 Mrk 并不会因为切换目录而消失。

### **环境变量**

  Ranger 中有如下环境变量：

| 环境变量               | 说明                                                         |
| ---------------------- | ------------------------------------------------------------ |
| RANGER_LEVEL           | Ranger 将此环境变量设置为 1，如果它已经存在，则将其递增。外部程序可以通过检查这个变量来确定它们是否是由 Ranger 启动的。 |
| RANGER_LOAD_DEFAULT_RC | 如果将该变量设置为 false，Ranger 将不会加载默认的 rc.conf。如果将整个 rc.conf 复制到 ~/.config/ranger/，则根本不需要默认值，这样可以节省时间。 |
| EDITOR                 | 设置用于 E 键的编辑器。默认为 nano。                         |
| SHELL                  | 设置 Ranger 在 :shell 命令和 S 键使用的 Shell。默认为 /bin/sh。 |
| TERMCMD                | 设置 Ranger 在 :terminal 命令和 t 运行标志使用的终端仿真器命令。默认为 xterm。 |
| XDG_CONFIG_HOME        | 指定配置文件的目录。默认为 $HOME/.config。                   |
| PYTHONOPTIMIZE         | 这个变量决定了python的优化级别。使用 PYTHONOPTIMIZE=1（同 python -O）将使 Python 放弃断言语句,你将丢失一些调试信息。使用 PYTHONOPTIMIZE=2（同 python -OO）将另外丢弃任何文档字符串。使用此选项将禁用 F1 按键。 |
| W3MIMGDISPLAY_PATH     | 设置图像预览的可执行文件的路径。默认设置为 /usr/lib/w3m/w3mimgdisplay。 |

## 帮助文档

| 按键      | 说明       |
| --------- | ---------- |
| ? 或者 F1 | 查看帮助   |
| ?m        | 菜单页     |
| ?k        | 查看快捷键 |
| ?c        | 查看命令   |
| ?s        | 查看设置   |

## 操作

  Ranger 中有**按键**和**命令**两种操作方式，按键是直接键入键盘上的键完成某个操作，命令则需前输入 :，然后输入相应的命令。快捷键在文件 ranger/config/rc.conf 中定义，查看此文件以获取所有快捷键的列表。你可以使用 ranger --copy-config=rc 选项将其复制到本地配置目录中。

  许多快捷键都有一个额外的数字参数。键入 5j 向下移动 5 行，2l 以模式 2 打开文件，10 + SPACE 连续标记 10 个文件。

  下面列出常用操作的快捷键，其中 ^ 代表 CTRL，! 代表 ALT。

### Cheatsheet

![ranger-cheatsheet](https://ranger.github.io/cheatsheet.png)

#### 移动光标

| 按键                            | 说明                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| h j k l<br />方向键             | 左（回到父文件夹）下上右（进入光标所在文件夹或打开光标处文件） |
| ^u 或者 K ^d 或者 J             | 向上翻半页向下翻半页                                         |
| ^b 或者 PAGEUP ^f 或者 PAGEDOWN | 向上翻一页向下翻一页                                         |
| HL                              | 后退到上一个历史记录前进到下一个历史记录                     |
| gg 或者 HOME G 或者 END         | 跳转到顶端跳转到底端                                         |
| []                              | 父目录上移父目录下移                                         |
| g + 对应字母                    | 跳转到相应的目录，如：gh：跳转到 ~ 目录 g?：跳转到 /usr/share/doc/ranger 目录 gR：跳转到 /usr/lib/python2.7/dist-packages/ranger 目录 gd：跳转到 /dev 目录 ge：跳转到 /etc 目录 gm：跳转到 /media 目录 gM：跳转到 /mnt 目录 go：跳转到 /opt 目录 gs：跳转到 /srv 目录 gu：跳转到 /usr 目录 gv：跳转到 /var 目录 gr 或者 g/：跳转到 / 目录 |
| glgL                            | 如果当前条目是一个符号链接（有 -> 符号），那么跳转到它的原始位置。 |
| cd                              | 同 :cd                                                       |

#### 选择条目

Ranger 可以方便快速地选择多个条目（包括文件和文件夹）。

| 按键  | 说明                                                         |
| ----- | ------------------------------------------------------------ |
| SPACE | 选择/取消选择一个条目，之后光标会自动跳到下一个条目。不会因为切换目录而失效。 |
| v     | 反选                                                         |
| V     | 开启/关闭视觉模式。在视觉模式下，移动光标即可选择条目。也可以按 uV 或者 ESC 退出。 |
| uv    | 取消所有选择                                                 |

- 快速选择当前位置到顶端的所有条目：V + gg
- 快速选择当前位置到底端的所有条目：V + G

#### 删除条目

| 按键       | 说明                                          |
| ---------- | --------------------------------------------- |
| dD 或者 F8 | 删除条目（文件或者文件夹），或者 : + delete。 |
| DD         | 将条目移动到回收站里。                        |

#### 新建条目

| 按键   | 说明                         |
| ------ | ---------------------------- |
| F7     | 新建文件夹，等同于 :mkdir 。 |
| INSERT | 新建文件，等同于 :touch 。   |

#### 重命名

| 按键 | 说明                             |
| ---- | -------------------------------- |
| cw   | 重命名（含后缀名）               |
| I    | 重命名，光标在最前               |
| A    | 重命名，光标在最后（含后缀名）   |
| a    | 重命名，光标在最后（不含后缀名） |

#### 复制

| 按键       | 说明                                                        |
| ---------- | ----------------------------------------------------------- |
| yy 或者 F5 | 复制                                                        |
| ya         | add 模式，添加光标处文件到复制队列中（文件夹无效）。        |
| yr         | remove 模式，从复制队列中移除光标处文件（文件夹无效）。     |
| yt         | toggle 模式，切换光标处文件是否在复制队列中（文件夹无效）。 |
| yk         | 将光标处文件和上一文件添加到复制队列中（文件夹无效）。      |
| yj         | 将光标处文件和下一文件添加到复制队列中（文件夹无效）。      |
| ygg        | 将光标处到顶端的所有文件添加到复制队列中（文件夹无效）      |
| yG         | 将光标处到底端的所有文件添加到复制队列中（文件夹无效）      |

#### 剪切

| 按键       | 说明                  |
| ---------- | --------------------- |
| dd 或者 F6 | 剪切                  |
| da         | add 模式，同复制。    |
| dr         | remove 模式，同复制。 |
| dt         | toggle 模式，同复制。 |
| dk         | 同复制                |
| dj         | 同复制                |
| dgg        | 同复制                |
| dG         | 同复制                |
| ud 或者 uy | 取消剪切              |

#### 粘贴

| 按键 | 说明                                                         |
| ---- | :----------------------------------------------------------- |
| pp   | 粘贴，默认 append 模式                                       |
| pP   | append 模式，如果该目录中有同名条目，则在条目后面加上 _、_0、_1……。如果条目是文件，则在文件后缀名后加入。 |
| po   | overwrite 模式，如果该目录中有同名条目，则覆盖原来的条目。   |
| pO   | append 模式 + overwrite 模式。                               |
| pl   | 粘贴为符号链接，不在状态栏显示目标条目的相对路径。           |
| pL   | 粘贴为符号链接（相对路径），在状态栏显示目标条目的相对路径。 |
| phl  | 粘贴为硬链接                                                 |
| pht  | 粘贴为硬链接的子目录（hardlinked subtree）                   |

#### 权限更改

| 按键 | 说明             |
| ---- | ---------------- |
| +    | 显示增加权限列表 |
| -    | 显示取消权限列表 |
| =    | 输入数字赋予权限 |

- u 表示该文件的拥有者（User），g 表示与该文件的拥有者属于同一个群体（Group）者，o 表示其他以外的人（Other），a 表示这三者皆是（All）。图片中左下角从左到右，第一个 d 代表文件夹，否则是 -，然后依次显示 u、g、o 的 rwx 权限。
- \+ 表示增加权限、- 表示取消权限、= 表示唯一设定权限。
- \- 表示不具备任何权限，r 表示可读取（文件夹内可添加和删除文件），w 表示可写入，x 表示可执行，X 表示只有当该文件是个子目录或者该文件已经被设定过为可执行，s 表示赋予程序 sudo 权限，t 表示该文件夹中能够添加文件但同时不能删除文件。
- chmod ugo file，其中 r=4，w=2，x=1，则
  - 若要 rwx 属性则 4+2+1=7；
  - 若要 rw- 属性则 4+2=6；
  - 若要 r-x 属性则 4+1=5。

#### **标记**

  标记是显示在文件名左侧的单个字符。你可以根据需要使用标记。按 t 可切换标签，按 ut 可删除所选内容的所有标记。默认标记是星号（*），但是你可以通过键入 " + Tag 来使用任何标记。

| 按键    | 说明                                                         |
| ------- | ------------------------------------------------------------ |
| t       | 标记/取消标记条目，标记后光标下移，默认 *。文件与文件夹的标记颜色不同，不同文件也不同。 |
| ut      | 取消标记                                                     |
| " + Tag | 用 Tag 标记条目，Tag 为任意字符，如 @。如果一个条目的标记为 @，那么键入 "@ 则取消标记，键入 t 或者 "# 则切换标记。 |

#### **搜索**

| 按键         | 说明                                                         |
| ------------ | ------------------------------------------------------------ |
| /            | 打开搜索框，输入要搜索的字符串，回车后开始搜索。             |
| f            | 查找，等同于运行满足条件的文件或者打开满足条件的文件夹。     |
| zf           | 与命令行 filter 作用一样，只显示符合条件的条目，区分大小写。 |
| nN           | 查找下一个搜索结果查找上一个搜索结果                         |
| c + 对应字母 | 通过对应属性依次遍历，如：ca：通过 atime属性依次遍历 cc：通过 ctime 属性依次遍历 ci：通过 mimetype 属性依次遍历 cm：通过 mtime 属性依次遍历 cs：通过 size 属性依次遍历 ct：通过 tag 属性依次遍历 |

- atime 表示：访问时间（access time）
- ctime 表示：状态修改时间（change time）
- mimetype 表示：MIME 类型（包括文本、图像、音频、视频以及其他应用程序专用的数据）
- mtime 表示：内容修改时间（modify time）
- size 表示：文件大小
- tag 表示：标签
- zf 删选完条目后，可以按 ^r 显示所有条目。

## 显示模式

### 鼠标操作

  Ranger 支持鼠标操作，包括左键、右键和滚轮。如果鼠标不能工作，在 Ranger 的浏览器界面键入 zm 开启鼠标功能。

#### 左键

- 点击主栏的条目，则光标跳转到条目上；
- 点击左栏的父目录上的条目，则主栏跳转到父目录，并且光标跳转到刚才点击的条目上；
- 点击右栏的子目录上的条目，则主栏跳转到子目录，并且光标跳转到刚才点击的条目上；
- 点击右栏的预览窗口，则用系统默认的程序打开该文件；
- 点击标签页，则跳转到相应的标签页；
- 点击左上角的用户名，则跳转到 / 目录。

#### 右键

- 点击主栏文件夹，进入文件夹（左栏和右栏无效）；
- 点击文件，用默认程序运行文件；
- 点击右栏的预览窗口，则用系统默认的程序打开该文件。

#### 滚轮

- 在主栏中，光标上下移动；
- 在左栏中，切换文件夹，同 [ 和 ]；
- 右栏无效。

## 配置

首先复制配置文件到主目录

```bash
$ ranger --copy-config=all
creating: /Users/Xiaoy/.config/ranger/rifle.conf
creating: /Users/Xiaoy/.config/ranger/commands.py
creating: /Users/Xiaoy/.config/ranger/commands_full.py
creating: /Users/Xiaoy/.config/ranger/rc.conf
creating: /Users/Xiaoy/.config/ranger/scope.sh

> Please note that configuration files may change as ranger evolves.
  It's completely up to you to keep them up to date.

> To stop ranger from loading both the default and your custom rc.conf,
  please set the environment variable RANGER_LOAD_DEFAULT_RC to FALSE.

```

其中每个文件代表：

| 文件名           | 内容                                                         |
| ---------------- | ------------------------------------------------------------ |
| bookmarks        | 书签列表，可以在此文件里直接批量添加书签。                   |
| commands.py      | 用户自定义控制台命令，用 Python 编写。                       |
| commands_full.py | Ranger 默认的控制台命令。                                    |
| history          | 控制台命令的历史记录，默认 50 条，最后面的命令最新，需要重启 Ranger 才能更新文件。 |
| rc.conf          | 主要的配置文件                                               |
| rifle.conf       | 配置预览功能                                                 |
| scope.sh         | 预览脚本，键入zv 启动/关闭。                                 |
| tagged           | 标记文件的绝对路径                                           |

还有两个未显示的文件夹：

| 文件夹名      | 内容         |
| ------------- | ------------ |
| colorschemes/ | 颜色主题文件 |
| plugins/      | 插件文件夹   |

所有的设置都在 ~/.config/ranger/rc.conf 中进行，或者用按键 z + 相应字母 切换配置。

#### 

#### **外观**

| 设置项                    | 有效值                         | 说明                                                         |
| ------------------------- | ------------------------------ | ------------------------------------------------------------ |
| column_ratios             | 1,3,4(default)1,1,1,15,3,1等等 | 设置浏览器界面有多少栏，比如 1,1,1 表示一共三栏，并且等宽，而 1,2 表示一共两栏，右栏宽度是左栏的两倍。 |
| colorscheme               | defaultjunglesnow              | 选择颜色主题，snow 是单色主题，jungle 将文件夹的颜色从蓝色替换为绿色，以便在某些终端上更好地显示。 |
| update_title              | truefalse(default)             | 是否设置窗口标题。                                           |
| shorten_title             | n (n ∈ Z+)0                    | 如果窗口变大，是否修剪其标题。数字表示一次显示多少文件夹，默认 3，值为 0 表示关闭此功能。 |
| tilde_in_titlebar         | truefalse(default)             | 是否用 ~ 代替在 Ranger 的标题栏上的 $HOME。                  |
| unicode_ellipsis          | truefalse(default)             | 是否用 ... 代替 ~ 表示因为窗口过小而显示不全的文件名。       |
| update_tmux_title         | truefalse(default)             | 是否在 Tmux 程序中将标题设置为 Ranger。                      |
| dirname_in_tabs           | truefalse(default)             | 是否在标签页显示文件夹名。                                   |
| automatically_count_files | true(default)false             | 是否在文件夹右边和状态栏上显示下一级的文件和文件夹总数。     |

#### **栏目**

| 设置项                      | 有效值             | 说明                   |
| --------------------------- | ------------------ | ---------------------- |
| draw_borders                | truefalse(default) | 是否为每个栏绘制边框。 |
| line_numbers                | true(default)false | 是否在主栏上显示行号。 |
| display_size_in_main_column | true(default)false | 在主栏上显示文件大小。 |
| display_tags_in_all_columns | true(default)false | 在所有栏中显示标记。   |

#### 

#### **状态栏**

| 设置项                          | 有效值             | 说明                                                         |
| ------------------------------- | ------------------ | ------------------------------------------------------------ |
| status_bar_on_top               | truefalse(default) | 设置状态栏是否在顶端。                                       |
| autoupdate_cumulative_size      | truefalse(default) | 在状态栏右下角实时显示目录的累计大小。键入 dc 同效。         |
| display_size_in_status_bar      | true(default)false | 在状态栏显示文件大小。                                       |
| draw_progress_bar_in_status_bar | true(default)false | 在状态栏中绘制进度条，该进度条显示支持进度条的所有当前运行任务的平均状态。 |

#### 

#### **排序**

| 设置项                 | 有效值                                                       | 说明                                                         |
| ---------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| sort                   | atimebasenamectimeextensionmtimenatural(default)typesizerandom | 按什么原则排序，同 z + 相关字母                              |
| sort_directories_first | true(default)false                                           | 排序时文件夹是否在文件前面。键入 zd 同效。                   |
| sort_case_insensitive  | true(default)false                                           | 排列是否区分大小写，如果是，则 a 在 B 前面，即使 a 的 ASCII 值更大。键入 zc 同效。 |
| sort_unicode           | truefalse(default)                                           | 当根据某个字符串进行排序时，是否应该比较 Unicode 字符，而不是查看原始字符值以节省时间。 |
| sort_reverse           | truefalse(default)                                           | 反向排序，与 or 同效。                                       |

#### **预览**

| 设置项                | 有效值                            | 说明                                                         |
| --------------------- | --------------------------------- | ------------------------------------------------------------ |
| preview_files         | true(default)false                | 是否开启预览文件功能。键入 zp 同效。                         |
| preview_directories   | true(default)false                | 是否开启预览文件夹功能。键入 zP 同效。                       |
| use_preview_script    | true(default)false                | 是否采用预览脚本预览文件。键入 zv 同效。                     |
| preview_script        | 预览脚本路径none                  | 设置预览脚本，默认 scope.sh。如果设置的文件不存在，或者设置 none，Ranger 将只打印内容来处理预览。 |
| preview_images        | truefalse(default)                | 是否开启预览图片功能。键入 zi 同效。                         |
| preview_images_method | w3m(default)iterm2urxvturxvt-full | 设置默认的图片预览程序。                                     |
| collapse_preview      | true(default)false                | 当文件预览不可见时，是否应该折叠右栏，使主栏扩大。键入 zc 同效。 |
| padding_right         | true(default)false                | 当 collapse_preview 处于开启状态且无预览结果时，是否保留右栏。如果是，则你可以单击右栏来运行文件。 |
| preview_max_size      | n (n ∈ Z+)0                       | 设置预览文件大小的最大值（以字节为单位），使用值 0 禁用此功能，默认禁止。 |

#### 

#### **版本控制**

| 设置项          | 有效值                        | 说明                                                         |
| --------------- | ----------------------------- | ------------------------------------------------------------ |
| vcs_aware       | truefalse(default)            | 是否收集和显示有关版本控制系统的数据。                       |
| vcs_backend_git | disabledlocalenabled(default) | 设置版本控制的状态，disabled 表示不显示信息，local 表示只显示本地状态，enabled 表示显示本地和远程的状态，Hg 和 Bzr 比较慢。 |
| vcs_backend_hg  | disabled(default)localenabled | 同 vcs_backend_git                                           |
| vcs_backend_bzr | disabled(default)localenabled | 同 vcs_backend_git                                           |

#### 

#### **历史记录**

| 设置项                   | 有效值             | 说明                                                         |
| ------------------------ | ------------------ | ------------------------------------------------------------ |
| save_console_history     | true(default)false | 设置退出 Ranger 时是否保存控制台历史记录。如果禁用，重新启动 Ranger 时将重置控制台历史记录。 |
| max_console_history_size | n (n ∈ Z+)none     | 控制台历史的数目最大值，默认 50 条，none 表示禁止记录。      |
| max_history_size         | n (n ∈ Z+)none     | 目录更改历史的数目最大值，默认 20 条，none 表示禁止记录。    |

#### 

#### **隐藏文件**

| 设置项        | 有效值             | 说明                                                         |
| ------------- | ------------------ | ------------------------------------------------------------ |
| show_hidden   | truefalse(default) | 是否显示隐藏文件。键入 zh 或者 ^h 同效。                     |
| hidden_filter | 正则表达式         | 用正则表达式选择哪些文件需要被隐藏，如 `set hidden_filter ^. |

#### 

#### **书签**

| 设置项                | 有效值             | 说明                                                         |
| --------------------- | ------------------ | ------------------------------------------------------------ |
| autosave_bookmarks    | true(default)false | 立即保存书签，这有助于在多个 Ranger 实例之间同步书签，但会导致轻微的性能损失。如果为 false，则在退出 Ranger 时保存书签。 |
| cd_bookmarks          | true(default)false | 设置输入控制台命令 cd 时是否可以自动补全书签的地址。         |
| show_hidden_bookmarks | true(default)false | 在书签预览窗口中显示 ` 文件。                                |

#### **鼠标**

| 设置项        | 有效值             | 说明                             |
| ------------- | ------------------ | -------------------------------- |
| mouse_enabled | true(default)false | 是否开启鼠标功能。键入 zm 同效。 |
| show_cursor   | true(default)false | 是否在终端显示鼠标箭头。         |

#### 

#### **杂项**

| 设置项                      | 有效值                       | 说明                                                         |
| --------------------------- | ---------------------------- | ------------------------------------------------------------ |
| confirm_on_delete           | alwaysnevermultiple(default) | 运行 :delete 命令时是否要确认，用 multiple，Ranger 只会在你同时删除多个文件时询问你。 |
| scroll_offset               | n (n ∈ Z+)                   | 滚动时,光标与下边界保持多少个空格的距离，默认值为 8。        |
| xterm_alt_key               | truefalse(default)           | 如果带 ALT 键的组合键对不起作用，则启用此选项。（尤其是在 Xterm 上） |
| clear_filters_on_dir_change | truefalse(default)           | 如果设置为 true，则在离开目录时将清除筛选结果。              |
| flushinput                  | true(true)false              | 每次按键后是否刷新输入，一个优点是当用 j 向下滚动，如果你松开 j，会立即停止滚动。一个缺点是，当你盲目地输入命令时，一些键可能会丢失。键入 zI 同效。 |
| idle_delay                  | 100n (n ∈ Z+)                | Ranger 等待用户输入的延迟，以毫秒为单位，为 100 的整数倍。较低的延迟减少了目录更新之间的延迟，但增加了 CPU 负载，默认值为 2000。 |
| metadata_deep_search        | truefalse(false)             | 当元数据管理器模块查找元数据时，它应该只在当前目录中查找 .metadata.json 文件，还是应该深入搜索并检查当前目录之上的所有目录。 |

## **增强 Ranger 的功能**

### **插件**

  Ranger 的插件系统由 Python 文件组成，这些文件位于 ~/.config/ranger/plugins/ 中，在启动 Ranger 时按字母顺序导入。插件通过覆盖或扩展 Ranger 使用的函数来更改 Ranger 的行为。这允许您更改 Ranger 的几乎所有部分，但不能保证随着源代码的发展，将来的版本中还会继续工作。

  除非您知道自己在做什么，否则不应该简单地覆盖一个函数。相反，保存现有函数并从新函数调用它。这样，多个插件可以使用同一个钩子。在 /usr/share/doc/ranger/examples/ 目录中有几个示例插件。

  复制下面的代码，Python 文件名格式为 plugin_ + 插件名字 + .py，然后将文件复制到 ~/.config/ranger/plugins/ 中，最后重启 Ranger 即可生效。

#### 

#### **状态栏显示欢迎语**

```python
# plugin_welcome.py
#
# Compatible with ranger 1.6.0 through 1.7.*
#
# This is a sample plugin that displays "Hello World" in ranger's console after
# it started.
# We are going to extend the hook "ranger.api.hook_ready", so first we need
# to import ranger.api:
import ranger.api

# Save the previously existing hook, because maybe another module already
# extended that hook and we don't want to lose it:

old_hook_ready = ranger.api.hook_ready
# Create a replacement for the hook that...

def hook_ready(fm):

# ...does the desired action...

fm.notify("Welcome to Ranger! Huang Pan")

# ...and calls the saved hook. If you don't care about the return value,

# simply return the return value of the previous hook to be safe.

return old_hook_ready(fm)

Finally, "monkey patch" the existing hook_ready function with our replacement:

ranger.api.hook_ready=hook_ready
```



#### **给条目添加类型符号**

挂载和卸载快捷键

```python
# plugin_pmount.py
#
# Tested with ranger 1.7.2
#
# This plugin creates a bunch of keybindings used to mount and unmount
# the devices using pmount(1).
#
# alt+m       <letter>            <digit>: mount /dev/sd<letter><digit>
# alt+m       <uppercase letter>         : mount /dev/sd<letter>
# alt+shift+m <letter>            <digit>: unmount /dev/sd<letter><digit>
# alt+shift+m <uppercase letter>         : unmount /dev/sd<letter>
# alt+shift+n                            : list the devices

import ranger.api

MOUNT_KEY = '<alt>m'
UMOUNT_KEY = '<alt>M'
LIST_MOUNTS_KEY = '<alt>N'

old_hook_init = ranger.api.hook_init

def hook_init(fm):
    try:
        fm.execute_console("map {key} shell -p lsblk".format(key=LIST_MOUNTS_KEY))
        for disk in "abcdefgh":
            fm.execute_console("map {key}{0} chain shell pmount sd{1}; cd /media/sd{1}".format(disk.upper(), disk, key=MOUNT_KEY))
            fm.execute_console("map {key}{0} chain cd; chain shell pumount sd{1}".format(disk.upper(), disk, key=UMOUNT_KEY))
            for part in "123456789":
                fm.execute_console("map {key}{0}{1} chain shell pmount sd{0}{1}; cd /media/sd{0}{1}".format(disk, part, key=MOUNT_KEY))
                fm.execute_console("map {key}{0}{1} chain cd; shell pumount sd{0}{1}".format(disk, part, key=UMOUNT_KEY))
    finally:
        return old_hook_init(fm)
ranger.api.hook_init = hook_init
```

