背景，抛出问题

- 内容组织
- 资料备份，本地以及远端。
- 图片的格式剪裁，尺寸优化，
- 文本内容的创作
- 资源文件管理
- 发布流程管理



## 内容组织。

写博客文章的时候，往往会带有资源文件，如何去管理这些资源文件？

- 代码片段
- 图片
- 音视频

这里的组织可以通过放置在同级目录下来管理。类似于

```
content
└── post
    ├── first-post
    │   ├── images
    │   │   ├── a.jpg
    │   │   ├── b.jpg
    │   │   └── c.jpg
    │   ├── index.md (root of page bundle)
    │   ├── latest.html
    │   ├── manual.json
    │   ├── notice.md
    │   ├── office.mp3
    │   ├── pocket.mp4
    │   ├── rating.pdf
    │   └── safety.txt
    └── second-post
        └── index.md (root of page bundle)
```

不过这里会有个痛点，就是 git repo 里面只适合管理代码或者文本，对于类 media的是不合适的，以及去要去加载media 考虑国内的网络环境是非常慢的。

所以需要一个地方去托管资源文件，这些资源文件也需要一定层级的组织，与文档的内容对应。



## 发布流程

个人来说是想把 hugo 的代码和内容进行分开，这样两边的改动是各自独立的，调试的时候应该是把内容覆盖进去，再实际看看，确认无误之后做发布。

因为搞一下每天都自动提交，还要加一个 daily build

需要拆分 site 和 articles 两个 repo。

hugo 提供什么样的功能和方式

