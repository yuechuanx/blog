---
title: 用 prettytable 在终端输出漂亮的表格
tags:
  - python
  - linux
categories:
  - Python
slug: use-prettytable-to-output-a-pretty-table-in-the-terminal
date: 2020-06-05 15:07:28
---

> 转载来源：https://linuxops.org/blog/python/prettytable.html

## 一、前言

最近在用python写一个小工具，这个工具主要就是用来管理各种资源的信息，比如阿里云的ECS等信息，因为我工作的电脑使用的是LINUX，所以就想着用python写一个命令行的管理工具，基本的功能就是同步阿里云的资源的信息到数据库，然后可以使用命令行查询。

因为信息是展现在命令行中的，众所周知，命令行展现复杂的文本看起来着实累人，于是就想着能像表格那样展示，那看起来就舒服多了。

prettytable库就是这么一个工具，prettytable可以打印出美观的表格，并且对中文支持相当好（如果有试图自己实现打印表格，你就应该知道处理中文是多么的麻烦）

<!-- more -->

> 说明：本文使用Markdown语法编写，为了展示方便，以及复制方便，所以本文中没有使用截图，因为格式控制的问题，文章中的运行结果会出现一些分割线的偏移，在终端中呈现并此问题，请各位手动去操作验证。

## 二、安装

prettytable并非python的内置库，通过 `pip install prettytable`即可安装。

## 三、一个小示例

我们先来看一个示例：

```python
#!/usr/bin/python
#**coding:utf-8**
import sys
from prettytable import PrettyTable
reload(sys)
sys.setdefaultencoding('utf8')

table = PrettyTable(['编号','云编号','名称','IP地址'])
table.add_row(['1','server01','服务器01','172.16.0.1'])
table.add_row(['2','server02','服务器02','172.16.0.2'])
table.add_row(['3','server03','服务器03','172.16.0.3'])
table.add_row(['4','server04','服务器04','172.16.0.4'])
table.add_row(['5','server05','服务器05','172.16.0.5'])
table.add_row(['6','server06','服务器06','172.16.0.6'])
table.add_row(['7','server07','服务器07','172.16.0.7'])
table.add_row(['8','server08','服务器08','172.16.0.8'])
table.add_row(['9','server09','服务器09','172.16.0.9'])
print(table)
```

以上示例运行结果如下：

```bash
linuxops@deepin:~$ python p.py 
+------+----------+----------+------------+
| 编号 |  云编号  |   名称   |   IP地址   |
+------+----------+----------+------------+
|  1   | server01 | 服务器01 | 172.16.0.1 |
|  2   | server02 | 服务器02 | 172.16.0.2 |
|  3   | server03 | 服务器03 | 172.16.0.3 |
|  4   | server04 | 服务器04 | 172.16.0.4 |
|  5   | server05 | 服务器05 | 172.16.0.5 |
|  6   | server06 | 服务器06 | 172.16.0.6 |
|  7   | server07 | 服务器07 | 172.16.0.7 |
|  8   | server08 | 服务器08 | 172.16.0.8 |
|  9   | server09 | 服务器09 | 172.16.0.9 |
+------+----------+----------+------------+
```

在以上的示例中，我们通过`form`导入了表格库。 `table`实例化了一个表格库，并且添加了`['编号','云编号','名称','IP地址']`为表头，如果没有添加表头，那么会以默认的Field+编号显示，例如：

```bash
+---------+----------+----------+------------+
| Field 1 | Field 2  | Field 3  |  Field 4   |
+---------+----------+----------+------------+
```

所以为更直观看出每一列的意义，还是要添加表头的。

## 四、添加数据

prettytable提供了多种的添加数据的方式，最常用的应该就是按行按列添加数据了。

### A、按行添加数据 table.add_row

在上面简单的示例中，我们就是按行添加数据的。

添加的数据必须要是列表的形式，而且数据的列表长度要和表头的长度一样。在实际的使用中，我们应该要关注到添加的数据是否和表头对应，这一点很重要。

### B、按列添加数据 table.add_column()

看下面的示例：

```python
#!/usr/bin/python
#**coding:utf-8**
import sys
from prettytable import PrettyTable
reload(sys)
sys.setdefaultencoding('utf8')

table = PrettyTable()
table.add_column('项目', ['编号','云编号','名称','IP地址'])
table.add_column('值', ['1','server01','服务器01','172.16.0.1'])
print(table)
```

运行结果如下：

```bash
+-------+--------+------------+
| index | 项目 |    值     |
+-------+--------+------------+
|   1   |  编号  |     1      |
|   2   | 云编号 |  server01  |
|   3   |  名称  |  服务器01   |
|   4   | IP地址 | 172.16.0.1 |
+-------+--------+------------+
```

以上示例中，我们通过`add_column`来按列添加数据，按列添加数据不需要在实例化表格的时候制定表头，它的表头是在添加列的时候指定的。

`table.add_column('项目', ['编号','云编号','名称','IP地址'])` 这一行代码为例，`项目`指定了这个列的表头名为"项目"，`['编号','云编号','名称','IP地址']`为列的值，同样为列表。

### C、从csv文件添加数据

PrettyTable不仅提供了手动按行按列添加数据，也支持直接从csv文件中读取数据。

```python
#!/usr/bin/python
#**coding:utf-8**
import sys
from prettytable import PrettyTable
from prettytable import from_csv 
reload(sys)
sys.setdefaultencoding('utf8')

table = PrettyTable()
fp = open("res.csv", "r") 
table = from_csv(fp) 
print(table)
fp.close()
```

如果要读取cvs文件数据，必须要先导入`from_csv`，否则无法运行。上面的示例运行结果如下：

```bash
+------+----------+----------+------------+
| 编号 |  云编号  |   名称   |   IP地址   |
+------+----------+----------+------------+
|  1   | server01 | 服务器01 | 172.16.0.1 |
|  2   | server02 | 服务器02 | 172.16.0.2 |
|  3   | server03 | 服务器03 | 172.16.0.3 |
|  4   | server04 | 服务器04 | 172.16.0.4 |
|  5   | server05 | 服务器05 | 172.16.0.5 |
|  6   | server06 | 服务器06 | 172.16.0.6 |
|  7   | server07 | 服务器07 | 172.16.0.7 |
|  8   | server08 | 服务器08 | 172.16.0.8 |
|  9   | server09 | 服务器09 | 172.16.0.9 |
+------+----------+----------+------------+
```

> csv文件不能通过xls直接重命名得到，会报错。如果是xls文件，请用另存为csv获得csv文件

### D、从sql查询值添加

从数据库查询出来的数据可以直接导入到表格打印，下面的例子使用了`sqlite3`,如果使用的是mysql也是一样的，只要能查询到数据就能导入到表格中

```python
#!/usr/bin/python
#**coding:utf-8**
import sys
from prettytable import PrettyTable
from prettytable import from_db_cursor 
import sqlite3
reload(sys)
sys.setdefaultencoding('utf8')

conn = sqlite3.connect("/tmp/aliyun.db")
cur = conn.cursor()
cur.execute("SELECT * FROM res") 
table = from_db_cursor(cur)
print(table)
```

运行结果如下：

```bash
+------+----------+----------+------------+
| 编号 |  云编号  |   名称   |   IP地址   |
+------+----------+----------+------------+
|  1   | server01 | 服务器01 | 172.16.0.1 |
|  2   | server02 | 服务器02 | 172.16.0.2 |
|  3   | server03 | 服务器03 | 172.16.0.3 |
|  4   | server04 | 服务器04 | 172.16.0.4 |
|  5   | server05 | 服务器05 | 172.16.0.5 |
|  6   | server06 | 服务器06 | 172.16.0.6 |
|  7   | server07 | 服务器07 | 172.16.0.7 |
|  8   | server08 | 服务器08 | 172.16.0.8 |
|  9   | server09 | 服务器09 | 172.16.0.9 |
+------+----------+----------+------------+
```

### E、从HTML导入数据

支持从html的表格中导入，请看下面这个例子：

```python
#!/usr/bin/python
#**coding:utf-8**
import sys
from prettytable import PrettyTable
from prettytable import from_html 
reload(sys)
sys.setdefaultencoding('utf8')

html_string='''<table>
<tr>
<th>编号</th>
<th>云编号</th>
<th>名称</th>
<th>IP地址</th>
</tr>
<tr>
<td>1</td>
<td>server01</td>
<td>服务器01</td>
<td>172.16.0.1</td>
</tr>
<tr>
<td>2</td>
<td>server02</td>
<td>服务器02</td>
<td>172.16.0.2</td>
</tr>
</table>'''

table = from_html(html_string)

print(table[0])
```

运行结果如下：

```bash
+------+----------+----------+------------+
| 编号 |  云编号  |   名称   |   IP地址   |
+------+----------+----------+------------+
|  1   | server01 | 服务器01 | 172.16.0.1 |
|  2   | server02 | 服务器02 | 172.16.0.2 |
+------+----------+----------+------------+
```

如上示例中，我们可以导入html的表格，但是不一样的地方是`print`语句，使用html表格导入数据的时候print的必须是列表中的第一个元素，否则有可能会报`[<prettytable.PrettyTable object at 0x7fa87feba590>]`这样的错误。

这是因为`table`并不是PrettyTable对象，而是包含单个PrettyTable对象的列表，它通过解析html而来，所以无法直接打印`table`，而需要打印`table[0]`

## 五、表格输出格式

正如支持多种输入一样，表格的输出也支持多种格式，我们在上面中的例子中已经使用了print的方式输出，这是一种常用的输出方式。

### A、print

直接通过`print`打印出表格。这种方式打印出的表格会带边框。

### B、输出HTML格式的表格

`print(table.get_html_string())`可以打印出html标签的表格。

在上面的例子中，使用`print(table.get_html_string())`会打印出如下结果：

```bash
<table>
    <tr>
        <th>编号</th>
        <th>云编号</th>
        <th>名称</th>
        <th>IP地址</th>
    </tr>
    <tr>
        <td>1</td>
        <td>server01</td>
        <td>服务器01</td>
        <td>172.16.0.1</td>
    </tr>
    <tr>
        <td>2</td>
        <td>server02</td>
        <td>服务器02</td>
        <td>172.16.0.2</td>
    </tr>
</table>
```

## 六、选择性输出

prettytable在创建表格之后，你依然可以有选择的输出某些特定的行.

### A、输出指定的列

`print table.get_string(fields=["编号", "IP地址"])`可以输出指定的列

### B、输出前两行

通过`print(table.get_string(start = 0, end = 2))`的可以打印出指定的列，当然`start`和`end`参数让我可以自由控制显示区间。当然区间中包含`start`不包含`end`，是不是很熟悉这样的用法？

> 根据输出指定行列的功能，我们可以同时指定行和列来输出，这里就不说明了。

### C、将表格切片

从上面的输出区间，我们做一个大胆的假设，既然区间包含`start`不包含`end`这种规则和切片的一样，我们可以不可通过切片来生成一个新的表格然后将其打印。

事实上是可以的。

```python
new_table = table[0:2]
print(new_table)
```

如上代码段中，我们就可以打印出0到1行共2行的表格，python的切片功能异常强大，配合切片我们可以自由的输入任意的行。

### D、输出排序

有时候我们需要对输出的表格进行排序，使用`print table.get_string(sortby="编号", reversesort=True)`就可以对表格进行排序，其中`reversesort`指定了是否倒序排序,默认为`False`，即默认正序列排序。

`sortby`指定了排序的字段。

## 七、表格的样式

### A、内置样式

通过`set_style()`可以设置表格样式，prettytable内置了多种的样式个人觉得`MSWORD_FRIENDLY`，`PLAIN_COLUMNS`，`DEFAULT` 这三种样式看起来比较清爽，在终端下显示表格本来看起就很累，再加上一下花里胡哨的东西看起来就更累。

除了以上推荐的三种样式以外，还有一种样式不得不说，那就是`RANDOM`，这是一种随机的样式，每一次打印都会在内置的样式中随机选择一个，比较好玩。

具体内置了几种样式，请各位参考官网完整自己尝试输出看看。

```python
#!/usr/bin/python
#**coding:utf-8**
import sys
from prettytable import PrettyTable
from prettytable import MSWORD_FRIENDLY
from prettytable import PLAIN_COLUMNS
from prettytable import RANDOM
from prettytable import DEFAULT

reload(sys)
sys.setdefaultencoding('utf8')

table = PrettyTable(['编号','云编号','名称','IP地址'])
table.add_row(['1','server01','服务器01','172.16.0.1'])
table.add_row(['3','server03','服务器03','172.16.0.3'])
table.add_row(['2','server02','服务器02','172.16.0.2'])
table.add_row(['9','server09','服务器09','172.16.0.9'])
table.add_row(['4','server04','服务器04','172.16.0.4'])
table.add_row(['5','server05','服务器05','172.16.0.5'])
table.add_row(['6','server06','服务器06','172.16.0.6'])
table.add_row(['8','server08','服务器08','172.16.0.8'])
table.add_row(['7','server07','服务器07','172.16.0.7'])
table.set_style(DEFAULT)

print(table)
```

### B、自定义样式

除了内置的样式以外，PrettyTable也提供了用户自定义，例如对齐方式，数字输出格式，边框连接符等等

### C、设置对齐方式

`align`提供了用户设置对齐的方式，值有`l`，`r`，`c`方便代表左对齐，右对齐和居中 如果不设置，默认居中对齐。

### D、控制边框样式

在PrettyTable中，边框由三个部分组成，横边框，竖边框，和边框连接符（横竖交叉的链接符号）

如下示例：

```python
#!/usr/bin/python
#**coding:utf-8**
import sys
from prettytable import PrettyTable

reload(sys)
sys.setdefaultencoding('utf8')

table = PrettyTable(['编号','云编号','名称','IP地址'])
table.add_row(['1','server01','服务器01','172.16.0.1'])
table.add_row(['3','server03','服务器03','172.16.0.3'])
table.add_row(['2','server02','服务器02','172.16.0.2'])
table.add_row(['9','server09','服务器09','172.16.0.9'])
table.add_row(['4','server04','服务器04','172.16.0.4'])
table.add_row(['5','server05','服务器05','172.16.0.5'])
table.add_row(['6','server06','服务器06','172.16.0.6'])
table.add_row(['8','server08','服务器08','172.16.0.8'])
table.add_row(['7','server07','服务器07','172.16.0.7'])
table.align[1] = 'l'

table.border = True
table.junction_char='$'
table.horizontal_char = '+'
table.vertical_char = '%'

print(table)
table.border`控制是否显示边框，默认是`True
```

`table.junction_char`控制边框连接符

`table.horizontal_char`控制横边框符号

`table.vertical_char`控制竖边框符号

上例运行如下：

```bash
$++++++$++++++++++$++++++++++$++++++++++++$
% 编号 %  云编号  %   名称   %   IP地址   %
$++++++$++++++++++$++++++++++$++++++++++++$
%  1   % server01 % 服务器01 % 172.16.0.1 %
%  3   % server03 % 服务器03 % 172.16.0.3 %
%  2   % server02 % 服务器02 % 172.16.0.2 %
%  9   % server09 % 服务器09 % 172.16.0.9 %
%  4   % server04 % 服务器04 % 172.16.0.4 %
%  5   % server05 % 服务器05 % 172.16.0.5 %
%  6   % server06 % 服务器06 % 172.16.0.6 %
%  8   % server08 % 服务器08 % 172.16.0.8 %
%  7   % server07 % 服务器07 % 172.16.0.7 %
$++++++$++++++++++$++++++++++$++++++++++++$
```

以上简单介绍了表格常用的一些样式设置，具体的请参考官方网站。

https://github.com/jazzband/prettytable

https://code.google.com/archive/p/prettytable/wikis/Tutorial.wiki