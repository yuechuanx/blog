---
title: 编写一个小型静态网站生成器
slug: write-a-small-static-site-generator
date: 2020-09-09T15:52:13+08:00
tags:
- web
draft: false
---

![blog-logo](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/blog-logo.jpeg)

> 转载自 [Writing a small static site generator](https://blog.thea.codes/a-small-static-site-generator/)
>
> 如果你有写博客的习惯以及尝试过自建博客服务，想必会对 Hexo，Hugo 等生成静态页面的框架不陌生。
>
> 那么如何实现一个自己的静态网站生成器呢，本文用极其少量 Python 代码实现 

目前大概有上百种用Python编写的静态站点生成器（还有更多其他语言编写的静态站点生成器）。

所以我决定写我自己的。

为什么？

好吧，我只是希望将博客从 [Ghost](https://ghost.org/) 迁移，并且希望保持真正的简约性。

我决定使用[GitHub Pages](https://pages.github.com/)托管，因为他们最近宣布支持[自定义域的SSL](https://blog.github.com/2018-05-01-github-pages-custom-domains-https/)。

<!--more-->

## 渲染内容

每个静态网站生成器都需要采用某种源格式（例如Markdown或ReStructuredText）并将其转换为HTML。我决定坚持 Markdown。

自从我最近将 [Github风格的Markdown](https://github.github.com/gfm/) 渲染集成到 [Warehouse中](https://github.com/pypa/warehouse) 以来，我决定使用为[cmarkgfm](https://pypi.org/project/cmarkgfm) 创建的基础库。使用以下方式将Markdown渲染为HTML ：

```python
import cmarkgfm


def render_markdown(content: str) -> str:
    content = cmarkgfm.markdown_to_html_with_extensions(
        content,
        extensions=['table', 'autolink', 'strikethrough'])
    return content
```

`cmarkgfm`确实有一个称为的便捷方法`github_flavored_markdown_to_html`，但是它使用了GitHub的[tagfilter](https://github.github.com/gfm/#disallowed-raw-html-extension-)扩展，当我要将脚本和内容嵌入到帖子中时，这是不希望的。因此，我只是选择了我想使用的扩展。

## 遍历

好的，我们有一种渲染Markdown的方法，但是我们还需要一种收集所有源文件的方法。我决定将所有来源存储在下`./src`。我们可以[`pathlib`](https://docs.python.org/3/library/pathlib.html)用来收集它们：

```python
import pathlib
from typing import Iterator


def get_sources() -> Iterator[pathlib.Path]:
    return pathlib.Path('.').glob('srcs/*.md')
```

## Front Matter

许多静态网站生成器都有 Front Matter 的概念 —— 一种为每个源文件设置元数据等的方法。

我想支持 frontmatter，以便让我为每个帖子设置日期和标题。看起来像这样：

```python
---
title: Post time
date: 2018-05-11
---

# Markdown content here.
```

对于frontmatter有一个非常好的和简单的现有库，称为[python-frontmatter](https://pypi.org/project/python-frontmatter/)。我可以使用它来提取 frontmatter 和原始内容：

```python
import frontmatter


def parse_source(source: pathlib.Path) -> frontmatter.Post:
    post = frontmatter.load(str(source))
    return post
```

返回的`post`对象具有`.content`具有发布内容的属性，否则充当字典以获取前项键。

## 渲染

现在我们有了帖子的内容和要点，我们可以渲染它们。我决定使用[jinja2](https://pypi.org/project/jinja2)将`cmarkgfm`渲染后的Markdown和Frontmatter放入一个简单的HTML模板中。

这是模板：

```html
<!doctype html>
<html>
<head><title>{{post.title}}</title></head>
<body>
  <h1>{{post.title}}</h1>
  <em>Posted on {{post.date.strftime('%B %d, %Y')}}</em>
  <article>
    {{content}}
  </article>
</body>
</html>
```

这是渲染它的Python代码：

```python
import jinja2

jinja_env = jinja2.Environment(
    loader=jinja2.FileSystemLoader('templates'),
)


def write_post(post: frontmatter.Post, content: str):
    path = pathlib.Path("./docs/{}.html".format(post['stem']))

    template = jinja_env.get_template('post.html')
    rendered = template.render(post=post, content=content)
    path.write_text(rendered)
```

请注意，我将呈现的HTML存储在中`./docs`。这是因为我将GitHub Pages配置为发布[doc目录中的](https://help.github.com/articles/configuring-a-publishing-source-for-github-pages/#publishing-your-github-pages-site-from-a-docs-folder-on-your-master-branch)内容。

现在我们可以呈现单个帖子，我们可以使用`get_sources`上面创建的函数遍历所有帖子：

```python
from typing import Sequence


def write_posts() -> Sequence[frontmatter.Post]:
    posts = []
    sources = get_sources()

    for source in sources:
        # Get the Markdown and frontmatter.
        post = parse_source(source)
        # Render the markdown to HTML.
        content = render_markdown(post.content)
        # Write the post content and metadata to the final HTML file.
        post['stem'] = source.stem
        write_post(post, content)

        posts.append(post)

    return posts
```

## 索引页面

现在，我们可以渲染帖子，但我们也应该渲染`index.html`列出所有帖子的顶层。我们可以使用另一个jinja2模板以及从返回的帖子列表来执行此操作`write_posts`。

这是模板：

```html
<!doctype html>
<html>
<body>
  <h1>My blog posts</h1>
  <ol>
    {% for post in posts %}
    <li>
      <a href="/{{post.stem}}">{{post.title}}</a>
    <li>
    {% endfor %}
  </ol>
</body>
</html>
```

这是渲染它的Python代码：

```python
def write_index(posts: Sequence[frontmatter.Post]):
    # Sort the posts from newest to oldest.
    posts = sorted(posts, key=lambda post: post['date'], reverse=True)
    path = pathlib.Path("./docs/index.html")
    template = jinja_env.get_template('index.html')
    rendered = template.render(posts=posts)
    path.write_text(rendered)
```

## 整活

现在剩下的就是使用一个`main`函数将其连接起来。

```python
def main():
    posts = write_posts()
    write_index(posts)


if __name__ == '__main__':
    main()
```

## 源码

您可以在[theacodes / blog.thea.codes上](https://github.com/theacodes/blog.thea.codes/)查看完整的源代码，包括语法高亮显示支持。