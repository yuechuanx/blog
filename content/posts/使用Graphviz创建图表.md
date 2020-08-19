---
title: 使用Graphviz创建图表
translate_title: create-graphs-with-graphviz
toc: true
comments: true
tags:
  - graph
  - tool
date: 2020-06-15 14:53:31
---

# 使用Graphviz创建图表

> 转载自：https://ncona.com/2020/06/create-diagrams-with-code-using-graphviz/

您是否曾为绘制过架构图时重复的单击和拖动而感到乏味？

您是否需要对该图进行修改发现改动却很复杂？

[Graphviz](https://www.graphviz.org/) 是一个开源的图形可视化软件，它使我们能够使用代码描述图表，并为我们自动绘制。如果将来需要修改该图，我们只需要修改描述代码，节点和边将自动为我们重新定位。

## 绘制图形

在开始编写图形之前，我们需要学习如何将代码转换为图像，以便可以测试正在做的事情。

[Webgraphviz.com](http://www.webgraphviz.com/) 可用于从浏览器绘制图形。

我们可以使用 apt 在 Ubuntu 中安装命令行工具：

```sh
1 sudo apt install graphviz 
```

在 macOS 环境 使用 brew 安装

~~~sh
brew install graphviz	
~~~

除其他外，这将安装 `dot` CLI，该CLI可用于从文本文件生成图像：

```sh
1 dot -Tpng input.gv -o output.png 
```

在上面的示例中，我们将 png 指定为output（`-Tpng`），但是有许多[可用的选项](https://www.graphviz.org/doc/info/output.html)。如我们所见，输入文件通常使用`gv`扩展名。

## DOT

DOT是用于描述要由Graphviz解析的图形的最常见格式。

### 基本

一个简单的图形具有以下形式：

```
graph MyGraph { 
	begin -- end 
} 
```

[![具有两个节点的基本图](https://ncona.com/images/posts/graphviz-basic.png)](https://ncona.com/images/posts/graphviz-basic.png)

如果要使用有向图（带箭头），则需要使用`digraph`：

```
digraph MyGraph {  
	begin -> end 
} 
```

[![基本有向图](https://ncona.com/images/posts/graphviz-directed-graph.png)](https://ncona.com/images/posts/graphviz-directed-graph.png)

箭头可以单向或双向：

```
digraph MyGraph {  
  a -> b  
  a -> c [dir=both] 
} 
```

[![带有双向箭头的图](https://ncona.com/images/posts/graphviz-bidirectional-arrow.png)](https://ncona.com/images/posts/graphviz-bidirectional-arrow.png)

### 形状

如果我们不喜欢椭圆形，可以使用其他形状：

```
digraph MyGraph {
  a [shape=box]
  b [shape=polygon,sides=6]
  c [shape=triangle]
  d [shape=invtriangle]
  e [shape=polygon,sides=4,skew=.5]
  f [shape=polygon,sides=4,distortion=.5]
  g [shape=diamond]
  h [shape=Mdiamond]
  i [shape=Msquare]
  a -> b
  a -> c
  a -> d
  a -> e
  a -> f
  a -> g
  a -> h
  a -> i
}
```

[![节点形状](https://ncona.com/images/posts/graphviz-shapes.png)](https://ncona.com/images/posts/graphviz-shapes.png)

可以在[其文档](https://www.graphviz.org/doc/info/shapes.html)的“ [节点形状”部分中](https://www.graphviz.org/doc/info/shapes.html)找到不同的受支持形状。

我们还可以向节点添加一些颜色和样式：

```
digraph MyGraph {
  a [style=filled,color=green]
  b [peripheries=4,color=blue]
  c [fontcolor=crimson]
  d [style=filled,fillcolor=dodgerblue,color=coral4,penwidth=3]
  e [style=dotted]
  f [style=dashed]
  g [style=diagonals]
  h [style=filled,color="#333399"]
  i [style=filled,color="#ff000055"]
  j [shape=box,style=striped,fillcolor="red:green:blue"]
  k [style=wedged,fillcolor="green:white:red"]
  a -> b
  a -> c
  a -> d
  a -> e
  b -> f
  b -> g
  b -> h
  b -> i
  d -> j
  j -> k
}
```

[![节点形状样式](https://ncona.com/images/posts/graphviz-shapes-styles.png)](https://ncona.com/images/posts/graphviz-shapes-styles.png)

可以在 [颜色名称文档](http://www.graphviz.org/doc/info/colors.html) 中找到不同的 [颜色名称](http://www.graphviz.org/doc/info/colors.html)。

### 箭头

箭头的尾巴和头部也可以修改：

```
digraph MyGraph {
  a -> b [dir=both,arrowhead=open,arrowtail=inv]
  a -> c [dir=both,arrowhead=dot,arrowtail=invdot]
  a -> d [dir=both,arrowhead=odot,arrowtail=invodot]
  a -> e [dir=both,arrowhead=tee,arrowtail=empty]
  a -> f [dir=both,arrowhead=halfopen,arrowtail=crow]
  a -> g [dir=both,arrowhead=diamond,arrowtail=box]
}
```

[![箭](https://ncona.com/images/posts/graphviz-arrows.png)](https://ncona.com/images/posts/graphviz-arrows.png)

可以在[箭头形状文档中](https://www.graphviz.org/doc/info/arrows.html)找到不同的箭头类型。

以及向箭头线添加样式：

```
digraph MyGraph {
  a -> b [color="black:red:blue"]
  a -> c [color="black:red;0.5:blue"]
  a -> d [dir=none,color="green:red:blue"]
  a -> e [dir=none,color="green:red;.3:blue"]
  a -> f [dir=none,color="orange"]
  d -> g [arrowsize=2.5]
  d -> h [style=dashed]
  d -> i [style=dotted]
  d -> j [penwidth=5]
}
```

[![箭](https://ncona.com/images/posts/graphviz-arrows-styles.png)](https://ncona.com/images/posts/graphviz-arrows-styles.png)

如果我们注意上面的代码和图表，我们可以看到，当我们为箭头指定多种颜色时，如果不指定任何权重，每种颜色将只有一行。如果我们想要一个带有多种颜色的箭头，则至少一种颜色必须指定要覆盖的线条的重量百分比：

```
1  a -> e [dir=none,color="green:red;.3:blue"] 
```

### 标签

我们可以向节点添加标签：

```
digraph MyGraph {
  begin [label="This is the beginning"]
  end [label="It ends here"]
  begin -> end
}
```

[![标签](https://ncona.com/images/posts/graphviz-labels.png)](https://ncona.com/images/posts/graphviz-labels.png)

以及顶点：

```
digraph MyGraph {
  begin
  end
  begin -> end [label="Beginning to end"]
}
```

[![Vertix标签](https://ncona.com/images/posts/graphviz-vertix-label.png)](https://ncona.com/images/posts/graphviz-vertix-label.png)

我们可以设置标签样式：

```
digraph MyGraph {
  begin [label="This is the beginning",fontcolor=green,fontsize=10]
  end [label="It ends here",fontcolor=red,fontsize=10]
  begin -> end [label="Beginning to end",fontcolor=gray,fontsize=16]
}
```

[![标签样式](https://ncona.com/images/posts/graphviz-label-styles.png)](https://ncona.com/images/posts/graphviz-label-styles.png)

### 集群

聚类也称为子图。集群的名称必须以开头`cluster_`，否则将不会包含在框中。

```
digraph MyGraph {
  subgraph cluster_a {
    b
    c -> d
  }
  a -> b
  d -> e
}
```

[![集群](https://ncona.com/images/posts/graphviz-cluster.png)](https://ncona.com/images/posts/graphviz-cluster.png)

集群可以根据需要嵌套：

```
digraph MyGraph {
  subgraph cluster_a {
    subgraph cluster_b {
      subgraph cluster_c {
        d
      }
      c -> d
    }
    b -> c
  }
  a -> b
  d -> e
}
```

[![嵌套集群](https://ncona.com/images/posts/graphviz-clusters-nested.png)](https://ncona.com/images/posts/graphviz-clusters-nested.png)

### HTML

HTML使我们可以创建更复杂的节点，这些节点可以分为多个部分。可以在图中独立地引用每个部分：

~~~html
digraph MyGraph {
    a [shape=plaintext,label=<
      <table>
        <tr>
          <td>Hello</td>
          <td>world!</td>
        </tr>
        <tr>
          <td colspan="2" port="a1">are you ok?</td>
        </tr>
      </table>
    >]
    b [shape=plaintext,label=<
      <table border="0" cellborder="1" cellspacing="0">
        <tr>
          <td rowspan="3">left</td>
          <td>top</td>
          <td rowspan="3" port="b2">right</td>
        </tr>
        <tr>
          <td port="b1">center</td>
        </tr>
        <tr>
          <td>bottom</td>
        </tr>
      </table>
    >]

    a:a1 -> b:b1
    a:a1 -> b:b2
}
~~~



[![HTML节点](https://ncona.com/images/posts/graphviz-html.png)](https://ncona.com/images/posts/graphviz-html.png)

只有HTML的一个子集可用于创建节点，并且规则非常严格。为了使节点正确显示，我们需要将设置`shape`为`plaintext`。

需要注意的另一件事是`port`属性，它使我们可以使用冒号（`a:a1`）来引用该特定单元格。

我们可以设置HTML节点的样式，但只能使用HTML的子集：

~~~html
digraph MyGraph {
    a [shape=plaintext,label=<
      <table>
        <tr>
          <td color="#ff0000" bgcolor="#008822"><font color="#55ff00">Hello</font></td>
          <td>world!</td>
        </tr>
        <tr>
          <td colspan="2" color="#00ff00" bgcolor="#ff0000">
            <font color="#ffffff">are you ok?</font>
          </td>
        </tr>
      </table>
    >]
}
~~~



[![HTML节点样式](https://ncona.com/images/posts/graphviz-html-style.png)](https://ncona.com/images/posts/graphviz-html-style.png)

### 图片

有时我们想为节点使用指定图标，这可以通过`image`属性来完成：

~~~
digraph MyGraph {
  ec2 [shape=none,label="",image="icons/ec2.png"]
  igw [shape=none,label="",image="icons/igw.png"]
  rds [shape=none,label="",image="icons/rds.png"]
  vpc [shape=none,label="",image="icons/vpc.png"]

  subgraph cluster_vpc {
    label="VPC"

    subgraph cluster_public_subnet {
      label="Public Subnet"
      ec2
    }

    subgraph cluster_private_subnet {
      label="Private Subnet"
      ec2 -> rds
    }

    vpc
    igw -> ec2
  }

  users -> igw
}
~~~



[![节点图片](https://ncona.com/images/posts/graphviz-images.png)](https://ncona.com/images/posts/graphviz-images.png)

### Rank

等级是最难理解的事情之一，因为它们会改变渲染引擎的工作方式。在这里，我将介绍一些我认为有用的基本知识。

图表通常会从上到下呈现：

~~~
digraph MyGraph {
  a -> b
  b -> c
  a -> d
  a -> c
}
~~~



[![上下图](https://ncona.com/images/posts/graphviz-top-bottom.png)](https://ncona.com/images/posts/graphviz-top-bottom.png)

使用`rankdir`属性，我们可以从左到右渲染它：

~~~
digraph MyGraph {
  rankdir=LR

  a -> b
  b -> c
  a -> d
  a -> c
}
~~~



[![左右图](https://ncona.com/images/posts/graphviz-left-right.png)](https://ncona.com/images/posts/graphviz-left-right.png)

排名还可以用于强制一个节点与另一个节点处于同一级别：

~~~
digraph MyGraph {
  rankdir=LR

  a -> b
  b -> c
  a -> d
  a -> c

  {rank=same;c;b}
}
~~~



[![等级=相同](https://ncona.com/images/posts/graphviz-rank-same.png)](https://ncona.com/images/posts/graphviz-rank-same.png)

在上面的示例中，我们用于`rank=same`将node `c`与node 对齐`b`。

该`rankdir`属性是全局属性，因此无法在集群内部更改，但是使用`rank`我们可以模拟`LR`集群内部的方向：

~~~
digraph MyGraph {
  subgraph cluster_A {
    a1 -> a2
    a2 -> a3

    {rank=same;a1;a2;a3}
  }

  subgraph cluster_B {
    a3 -> b1
    b1 -> b2
    b2 -> b3

    {rank=same;b1;b2;b3}
  }

  begin -> a1
}
~~~



[![等级=集群内部相同](https://ncona.com/images/posts/graphviz-rank-cluster.png)](https://ncona.com/images/posts/graphviz-rank-cluster.png)

我们可以结合`rank`使用`constraint=false`以创建更紧凑的图形：

```
digraph MyGraph {
  subgraph cluster_A {
    a1
    a2
    a3
    {rank=same;a1;a2;a3}
  }

  subgraph cluster_B {
    b1
    b2
    b3

    {rank=same;b1;b2;b3}
  }

  begin -> a1
  a1 -> a2 [constraint=false]
  a2 -> a3 [constraint=false]
  a3 -> b1
  b1 -> b2
  b2 -> b3
}

```



[![Graphviz约束](https://ncona.com/images/posts/graphviz-constraint.png)](https://ncona.com/images/posts/graphviz-constrained.png)

等级还可以用于指定每个节点之间的距离：

```
digraph MyGraph {
  rankdir=LR
  ranksep=1
  a -> b
  b -> c
  c -> d
}
```



[![朗塞普](https://ncona.com/images/posts/graphviz-ranksep.png)](https://ncona.com/images/posts/graphviz-ranksep.png)

其缺省值`ranksep`是`.5`。

## 总结

在这篇文章中，我们学习了如何使用 Graphviz 基于声明性语言生成图。这使我在将来更容易绘制架构图并对其进行修改。

我介绍了我认为对于日常使用最重要的功能，但是坦率地说，很多功能我仍还不了解。