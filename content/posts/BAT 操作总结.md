吐槽 batch file，资料非常零散，整理官方文档的东西，建立索引

哪里能找到命令的 help 文档？

[Windows 命令官方文档](https://docs.microsoft.com/zh-cn/windows-server/administration/windows-commands/windows-commands)

一些常用的例子？既然是作介绍，那么需要哪些东西？

- 命令的介绍，一句话
- 命令的 usage？非全部，常用的即可，不行再查
- 一些 sample，代码片段

一些实际例子：

- 获取时间戳以及格式化

```
set yyyy=%date:~,4%
set mm=%date:~5,2%
set dd=%date:~8,2%
set YYYYmmdd=%yyyy%%mm%%dd%
set filename=sdkgui_%YYYYmmdd%
```



- 压缩、解压缩
- 网络挂载-挂载盘符 



文件操作

删除：

- [del/erase](https://docs.microsoft.com/zh-cn/windows-server/administration/windows-commands/del) 删除一个或多个文件
- [rd/rmdir](https://docs.microsoft.com/zh-cn/windows-server/administration/windows-commands/rd) 删除文件夹

创建：

- [md/mkdir](https://docs.microsoft.com/zh-cn/windows-server/administration/windows-commands/mkdir) 新建文件夹

文件拷贝：

- [copy](https://docs.microsoft.com/zh-cn/windows-server/administration/windows-commands/copy)
- [xcopy](https://docs.microsoft.com/zh-cn/windows-server/administration/windows-commands/xcopy)
- [robocopy](https://docs.microsoft.com/zh-cn/windows-server/administration/windows-commands/robocopy)

打开文件

- start

系统信息

- date
- 查看系统软硬件信息

网络相关

任务

硬盘

