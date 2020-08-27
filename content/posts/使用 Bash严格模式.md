---
title: 使用 Bash 严格模式
slug: use-bash-strict-mode
tags:
- bash
date: 2020-08-12 16:58:57
---
# 使用 Bash严格模式

> 原文链接：[Use Bash Strict Mode (Unless You Love Debugging)](http://redsymbol.net/articles/unofficial-bash-strict-mode/) 
>
> 翻译：YueChuan 
>
> 在 Unix/Linux 环境很难避免与 Bash 脚本打交道，一份高质量，可靠且可维护的 Bash 脚本应该怎么写？
>
> 本文将提供一些技巧帮助你解决这些问题...

让我们开门见山，直接上 **PUNCHLINE**。

如果你的 Bash 脚本以这段代码开始，它们将变得更加健壮，可靠和可维护：

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
```

<!-- more -->

<!--toc-->

[toc]

我将此称为非官方的 **bash严格模式** 。

这导致 bash 的执行过程中，许多种类的细微错误无法出现。您将花费更少的时间进行调试，并避免在生产环境中出现意想不到的复杂情况。

这里有一个短期的弊端：这些设置使某些常见的 bash 习惯用法更难使用。大多数情况都有简单的解决方法，详细说明如下：跳至 [Issues＆Solutions](http://redsymbol.net/articles/unofficial-bash-strict-mode/#issues-and-solutions)。

但首先，让我们看一下这些晦涩难懂的行的实际上做了什么。

## set 语句

这些行故意导致脚本失败。等等，发生了什么？相信我，这是一件好事。使用这些设置，某些常见错误将导致脚本 **立即** 明确且显然地失败。否则，您将收获在生产环境中爆炸后才发现的隐藏错误。

`set -euo pipefail` 的缩写：

```bash
set -e
set -u
set -o pipefail
```

让我们分别看一下。

### set -e

`set -e` 如果任何命令[[1\]](http://redsymbol.net/articles/unofficial-bash-strict-mode/#footnote-1) 的退出状态为非零，则该选项指示 bash 立即退出。

您不想为命令行shell设置它，但是在脚本中它很有帮助。在所有广泛使用的通用编程语言中，未处理的运行时错误（无论是Java中引发的异常，还是C中的分段错误，还是Python中的语法错误）都立即停止程序的执行；随后的行不执行。

默认情况下，bash所做的**没有**做到这一点。如果您在命令行上使用bash，则此默认行为正是您想要的-您不希望输入错误将您注销！但是在脚本中，您真的想要相反。如果脚本中的一行失败，但最后一行成功，则整个脚本具有成功的退出代码。这样很容易错过该错误。

同样，在将bash用作命令行shell并将其在脚本中使用时，您想要的与这里不一致。在脚本中容忍错误要好得多，这就是`set -e`给您带来的好处。

### set -u

`set -u ` 影响变量。

设置后，对您之前未定义的任何变量的引用( `$*`  和 `$@` 除外) 都会发生错误，并导致程序立即退出。出于各种缘由，Python，C，Java等语言都具有相同的行为方式。其中之一就是错别字没有意识到就不会创建新变量。例如：

```bash
#!/bin/bash
firstName="Aaron"
fullName="$firstname Maxwell"
echo "$fullName"
```

花一点时间看看。看到错误了吗？

第三行的右侧显示“ firstname”（全部小写），而不用驼峰式的“ firstName”。如果没有-u选项，这将是一个无提示错误。但是，使用-u选项，脚本将以退出代码1退出该行，并将消息“ firstname：unbound variable”输出到stderr。

这就是您想要的：让它明确且立即失败，而不是创建可能为时已晚的细微错误。

### set -o pipefail

此设置可防止掩盖管道中的错误。如果管道中的任何命令失败，则该返回码将用作整个管道的返回码。默认情况下，管道的返回码是最后一个命令的返回码-即使成功。想象一下在文件中找到匹配行的排序列表：

```bash
% grep some-string /non/existent/file | sort
grep: /non/existent/file: No such file or directory
echo $?
0
```

>  `%`是bash提示

在这里，grep的退出代码为2，将错误消息写入stderr，将空字符串写入stdout。然后，此空字符串通过sort传递，该字符串愉快地接受它作为有效输入，并返回状态代码0。这对于命令行很好，但对shell脚本则不利：您几乎肯定希望脚本立即退出具有非零的退出代码...就像这样：

```bash
1. % set -o pipefail
2. % grep some-string /non/existent/file | sort
3. grep: /non/existent/file: No such file or directory
4. % echo $?
5. 2
```

## 设置IFS

IFS(Internal Field Separator) 设置 Bash 的*分隔符*。

当设置为字符串时，Bash会考虑字符串中的每个字符以分隔单词。这决定了bash如何遍历序列。例如，此脚本：

```bash
1. #!/bin/bash
2. IFS=$' '
3. items="a b c"
4. for x in $items; do
5.     echo "$x"
6. done
7. 
8. IFS=$'\n'
9. for y in $items; do
10.     echo "$y"
11. done
```

...将打印出以下内容：

```bash
a
b
c
a b c
```

在第一个for循环中，IFS设置为`$' '`。（ `$'...'`语法创建一个字符串，用反斜杠转义的字符替换为特殊字符-例如，“ \ t”代表制表符，“ \ n”代表换行符。）

在for循环中，x和y设置为bash认为是“单词”的任何值”以原始顺序显示。对于第一个循环，IFS是一个空格，这意味着单词由空格字符分隔。对于第二个循环，“单词”由 *换行符分隔*，这意味着bash将“ items”的整个值视为一个单词。如果IFS超过一个字符，则将对这些字符中的*任何*一个进行拆分。

知道了吗？下一个问题是，为什么我们将IFS设置为由制表符和换行符组成的字符串？因为在循环中迭代时，它为我们提供了更好的行为。“更好”的意思是“引起意外和令人困惑的错误的可能性要小得多”。这在使用bash数组时很明显：

```bash
1. #!/bin/bash
2. names=(
3.   "Aaron Maxwell"
4.   "Wayne Gretzky"
5.   "David Beckham"
6.   "Anderson da Silva"
7. )
8. 
9. echo "With default IFS value..."
10. for name in ${names[@]}; do
11.   echo "$name"
12. done
13. 
14. echo ""
15. echo "With strict-mode IFS value..."
16. IFS=$'\n\t'
17. for name in ${names[@]}; do
18.   echo "$name"
19. done
```

（是的，我把我的名字列在了不起的运动员名单上。放飞自我~）

这是输出：

```bash
With default IFS value...
Aaron
Maxwell
Wayne
Gretzky
David
Beckham
Anderson
da
Silva

With strict-mode IFS value...
Aaron Maxwell
Wayne Gretzky
David Beckham
Anderson da Silva
```

或者考虑一个以文件名作为命令行参数的脚本：

```bash
1. for arg in $@; do
2.     echo "doing something with file: $arg"
3. done
```

如果您将其调用为`myscript.sh notes todo-list 'My Resume.doc'`，则使用默认的IFS值，第三个参数将被误解析为两个单独的文件-名为“ My”和“ Resume.doc”。实际上，它是一个包含空格的文件，名为“ My Resume.doc”。

哪种行为更普遍有用？当然，第二个-我们有能力不分割空格。如果我们有一个通常包含空格的字符串数组，通常我们希望逐项迭代它们，而不是将单个项拆分为多个。

将IFS设置为`$'\n\t'`意味着仅在换行符和制表符上会发生单词拆分。这通常会产生有用的拆分行为。默认情况下，bash将此设置为`$' \n\t'`-空格，换行符，制表符-这太急了。[[2\]](http://redsymbol.net/articles/unofficial-bash-strict-mode/#footnote-2)

## 问题与解决方案

多年来，我一直在使用非官方的bash严格模式。在这一点上，它总是立即为我节省时间和调试麻烦。但是起初这是具有挑战性的，因为在这些情况下，我的许多惯常习惯和成语都不起作用。本文的其余部分列出了您可能遇到的一些问题，以及如何快速解决这些问题。

（如果遇到问题，在这里看不到，请[给我发电子邮件](http://redsymbol.net/articles/unofficial-bash-strict-mode/#contact-for-help)，我会尽力提供帮助。）

- [采购不合格的文件](http://redsymbol.net/articles/unofficial-bash-strict-mode/#sourcing-nonconforming-document)
- [位置参数](http://redsymbol.net/articles/unofficial-bash-strict-mode/#solution-positional-parameters)
- [故意未定义的变量](http://redsymbol.net/articles/unofficial-bash-strict-mode/#intentionally-undefined-variables)
- [您期望具有非零退出状态的命令](http://redsymbol.net/articles/unofficial-bash-strict-mode/#expect-nonzero-exit-status)
- [基本清理](http://redsymbol.net/articles/unofficial-bash-strict-mode/#essential-cleanup)
- [短路注意事项](http://redsymbol.net/articles/unofficial-bash-strict-mode/#short-circuiting)
- [反馈/如果卡住](http://redsymbol.net/articles/unofficial-bash-strict-mode/#contact-for-help)

### 采购不合格的文件

有时，您的脚本需要获取无法在严格模式下使用的文件。然后怎样呢？

```bash
source some/bad/file.env
＃您的严格模式脚本会立即退出此处，
＃出现致命错误。
```

解决方案是（a）暂时禁用严格模式的该方面；（b）出示文件；然后（c）在下一行重新启用。

您最需要的时间是文档引用未定义的变量。暂时允许以下行为`set +u`：

```bash
1. set +u
2. source some/bad/file.env
3. set -u
```

> 请记住，`set +u` *禁用*此变量严格性并将其`set -u` *启用*。这有点违反直觉，因此在这里要小心。

您过去在Python虚拟环境中需要这样做。如果您不熟悉Python：您可以设置一个自定义的隔离环境-称为virtualenv-存储在一个名为“ venv”的目录中。您通过在以下位置获取名为“ bin / activate”的文件来选择使用此文件：

```bash
＃这将更新PATH并将PYTHONPATH设置为
＃使用预配置的虚拟环境。
source /path/to/venv/bin/activate

＃现在所需的Python版本就在您的路径中，
＃与您需要的一组特定库。
python my_program.py
```

在现代版本的Python中，这在bash严格模式下非常有效。但是，较旧的虚拟环境（还很年轻，您可能仍然会遇到它们）*无法*与-u选项一起正常使用：

```bash
1. set -u
2. source /path/to/venv/bin/activate
3. _OLD_VIRTUAL_PYTHONHOME: unbound variable
_OLD_VIRTUAL_PYTHONHOME：未绑定变量

＃这会使您的严格模式脚本退出并出现错误。
```

没问题，您只需使用上面的模式：

```bash
1. set +u
2. source /path/to/venv/bin/activate
3. set -u
```

以我的经验，原始文档很少需要 `-e`或被`-o pipefail`禁用。但是，如果遇到这种情况，您将以相同的方式处理它。

### 位置参数

`-u`如果进行任何未定义的变量引用（`$*`或除外），则此设置将导致脚本立即退出 `$@`。但是，如果您的脚本采用位置参数- `$1`，`$2`等等-并且您想要验证是否提供了该怎么办？考虑以下脚本 `sayhello.sh`：

如果您自己运行“ sayhello.sh”，则会发生以下情况：

```
％./sayhello.sh 
./sayhello.sh：第3行：$ 1：未绑定变量
```

最无用的错误消息。解决方案是使用[参数默认值](http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion)。这个想法是，如果*在运行时*引用了一个未定义的变量，则bash具有使用“：-”运算符声明默认值的语法：

```bash
＃尚未设置变量 $foo，在严格模式下
＃下一行触发错误。
bar=$foo

# 如果未定义VARNAME，则＃$ {VARNAME：-DEFAULT_VALUE}等于DEFAULT_VALUE。
＃ 因此，在这里，$ bar设置为“ alpha”：
bar=${foo:-alpha}

＃现在我们显式设置foo：
foo =“beta”

＃...，默认值将被忽略。这里$ bar设置为“ beta”：
bar=${foo:-alpha}

＃要将默认值设置为空字符串，请使用$ {VARNAME：-}
empty_string=${some_undefined_var:-}
```

在严格模式下，需要将其用于所有位置参数引用：

```bash
1. #!/bin/bash
2. set -u
3. name=${1:-}
4. if [[ -z "$name" ]]; then
5.     echo "usage: $0 NAME"
6.     exit 1
7. fi
8. echo "Hello, $name"
```

### 故意未定义的变量

在默认模式下，对未定义变量的引用将得出一个空字符串-有时会依赖此行为。在严格模式下，这不是一个选择，并且有两种方法可以解决它。我认为最好的方法是在脚本的任何位置对其进行引用之前，将变量明确设置为空字符串：

```bash
someVar = “”
＃...
＃可能设置或未设置someVar的代码行
＃...
if [[ -z "$someVar" ]]; then
＃...
```

一种替代方法是使用`${someVar:-}`语法作为默认值，如[Positional Parameters](http://redsymbol.net/articles/unofficial-bash-strict-mode/#solution-positional-parameters)下所述。那里的问题是，有可能忘记而只是说 `$someVar`，而且输入更多。只需在脚本顶部显式设置默认值即可。那就没有办法咬你了。

### 您期望具有非零退出状态的命令

当您*想*运行将失败的命令，或者您知道将拥有非零退出代码时，会发生什么？您不希望它停止脚本，因为这实际上是正确的行为。

这里有两个选择。通常，您最想使用的最简单的方法是`|| true`在命令后附加“ ”：

```bash
＃“ grep -c”报告匹配的行数。如果数字是0，
＃然后grep的退出状态为1，但我们不在乎-我们只想
＃知道匹配数目，即使该数目为零。

＃在严格模式下，下一行因错误而中止：
count=$(grep -c some-string some-file)



＃但是这一行为表现得更好：
1. count=$(grep -c some-string some-file || true)
2. 
3. echo "count: $count"
```

布尔运算符的这种短路使内部表达式 `$( ... )`始终可以成功求值。

您可能会发现这种技巧几乎总是可以解决您的问题。但是，如果您想知道命令的返回值，即使该返回值非零怎么办？然后，您可以暂时禁用立即退出选项：

```bash
＃我们以set -e开始此脚本。然后...
1. set +e
2. count=$(grep -c some-string some-file)
3. retval=$?
4. set -e

＃当一行或多行匹配时，grep的返回码为0；
＃1，如果没有行匹配；和2错误。这个图案
＃让我们区分它们。
1. echo "return value: $retval"
2. echo "count: $count"
```

### 基本清理

假设您的脚本结构如下：

1. 筹集一些昂贵的资源
2. 用它做点什么
3. 释放该资源，使其不会持续运行并产生巨额账单

对于“昂贵的资源”，这可能像EC2实例那样花费您的实际钱。或者，它可能是一些更小-就像一个临时目录-要创建脚本来使用，那么一定要删除一旦完成（所以它不会泄露存储等）的`set -e`选项，它错误可能会导致您的脚本在执行清理之前退出，这是不可接受的。

解决方案：使用[bash出口陷阱](http://redsymbol.net/articles/bash-exit-traps/)。链接的文章详细解释了这一重要模式，我强烈建议您精通此技术-在工具箱中使用它会显着提高脚本的健壮性和可靠性。简而言之，您将定义一个bash函数来执行清理或释放资源，然后注册要在退出时自动调用的函数。这是使用它来稳健清除暂存目录的方法：

```bash
1. scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
2. function finish {
3.   rm -rf "$scratch"
4. }
5. trap finish EXIT
6. 
7. # Now your script can write files in the directory "$scratch".
8. # It will automatically be deleted on exit, whether that's due
9. # to an error, or normal completion.
```

### 短路注意事项

严格模式的全部目的是将许多隐藏的，间歇的或微妙的错误转换为直接的，显而易见的错误。但是，严格模式会引起一些特殊的短路问题。“短路”是指用`&&`或`||`- 将多个命令链接在一起，例如：

```bash
1. # Prints a message only if $somefile exists.
2. [[ -f "$somefile" ]] && echo "Found file: $somefile"
```

当连续链接三个或更多命令时，可能会出现第一个短路问题：

```bash
1. first_task && second_task && third_task
2. # And more lines of code following:
3. next_task
```

潜在的问题：如果`second_task`失败， `third_task`将无法运行，并且`next_task`在本示例中，执行将继续到下一行代码- 。这可能正是您想要的行为。或者，您可能打算如果`second_task`失败，则脚本应立即以错误代码退出。在这种情况下，最好的选择是使用一个块-即花括号：

```bash
1. first_task && {
2.     second_task
3.     third_task
4. }
5. next_task
```

因为我们正在使用该`-e`选项，所以如果 `second_task`失败，脚本将立即退出。

第二个问题确实存在。使用以下常见用法时，它可能会潜行：

```bash
1. # COND && COMMAND
2. [[ -f "$somefile" ]] && echo "Found file: $somefile"
```

人们写作时`COND && COMMAND`，通常的意思是“如果COND成功（或布尔值为true），则执行COMMAND。无论如何，请继续执行脚本的下一行。” 对于完整的“ if / then / fi”子句来说，这是非常方便的简写。但是，当这样的构造是文件的*最后一行*时，严格模式可以为脚本提供令人惊讶的退出代码：

```
1. % cat short-circuit-last-line.sh
2. #!/bin/bash
3. set -euo pipefail
4. # omitting some lines of code...
5. 
6. # Prints a message only if $somefile exists.
7. # Note structure: COND && COMMAND
8. [[ -f "$somefile" ]] && echo "Found file: $somefile"
9. 
10. % ./short-circuit-last-line.sh
11. % echo $?
12. 1
```

当脚本到达最后一行时，`$somefile`实际上 *并不*存在。因此`COND`评估为假，并且`COMMAND`没有执行-这应该发生。但是该脚本以非零的退出代码退出，这是一个错误：该脚本实际上已正确执行，因此它实际上应该以0退出。实际上，如果最后一行代码是其他内容，那正是我们所得到的：

```
1. % cat short-circuit-before-last-line.sh
2. #!/bin/bash
3. set -euo pipefail
4. # omitting some lines of code...
5. 
6. # Prints a message only if $somefile exists.
7. # Structure: COND && COMMAND
8. # (When we run this, $somefile will again not exist,
9. # so COMMAND will not run.)
10. [[ -f "$somefile" ]] && echo "Found file: $somefile"
11. 
12. echo "Done."
13. 
14. % ./short-circuit-before-last-line.sh
15. Done.
16. % echo $?
17. 0
```

这是怎么回事？事实证明，该`-e`选项在这样的短路表达式中有一个特殊的例外：如果`COND` 计算结果为false，`COMMAND`将不会运行，并且执行流程将进行到下一行。但是，整行的结果-整个短路表达式-将为非零，因为`COND`是。作为脚本的最后一行，它成为程序的退出代码。

这是我们不希望遇到的错误，因为它可能是微妙的，不明显的并且难以复制。而且它主要很难处理，因为*仅*当它是文件的最后一个命令时*才会*显示。在任何其他行上，它的行为都很好，不会造成任何问题。在正常的日常开发中，很容易忘记这一点，并使其从裂缝中溜走。例如，如果您从头删除看起来无害的echo语句，使短路线现在最后，该怎么办？

在上面的特定示例中，我们可以在完整的“ if”子句中扩展表达式。这是完美的行为：

```bash
1. # Prints a message only if $somefile exists.
2. if [[ -f "$somefile" ]]; then
3.     echo "Found file: $somefile"
4. fi
5. 
6. # If COND is a command or program, it works the same. This:
7. first_task && second_task
8. 
9. # ... becomes this:
10. if first_task; then
11.      second_task
12. fi
```

最终的完整解决方案是什么？您可以决定信任自己和您的队友，以始终记住这一特殊情况。所有人都可以随意使用短路功能，但是对于实际部署的任何内容，都不允许短路表达式位于脚本的最后一行。对于您和您的团队来说，这可能100％可靠地起作用，但我认为对于我自己和许多其他开发人员而言并非如此。当然，某种类型的linter或commit钩子可能会有所帮助。

也许更安全的选择是决定根本不使用短路，而始终使用完整的if语句。但是，这可能并不吸引人：短路很方便，人们出于某种原因喜欢这样做。目前，我仍在寻找更令人满意的解决方案。如果您有任何建议，请与我联系。

## 反馈/如果卡住

如果您有任何反馈或改进建议，我很想听听。通过电子邮件与我（Aaron Maxwell）取得联系，网址为redsymbol dot net的最大值。

相反，如果您发现严格模式会导致上述问题（我没有告诉您如何解决），我也想知道。给您发送电子邮件时，请在电子邮件正文（而不是附件）中包含一个**最小的** bash脚本，以演示该问题。还要非常清楚地说明所需的输出或效果，以及您得到的错误或失败。如果您的脚本不是某个标识符很钝的巨型怪兽，那么我很有可能会得到响应，而我将不得不在整个下午进行解析。

## 脚注

- [1]具体来说，如果有管道；括号中的任何命令；或以大括号形式作为命令列表的一部分执行的命令以非零退出状态退出，脚本立即以相同状态退出。这还有其他一些细微之处。有关详细信息，请参见[内置bash“ set”的](http://www.gnu.org/software/bash/manual/bashref.html#The-Set-Builtin)文档。
- [2]另一种方法：不更改IFS，而是从循环开始`for arg in "$@"`-用双引号覆盖迭代变量。这将改变循环语义以产生更好的行为，甚至更好地处理一些边缘情况。最大的问题是可维护性。即使是经验丰富的开发人员，也很容易忘记加双引号。即使原始作者已经成功地根深蒂固了这个习惯，但期望所有未来的维护者都会愚蠢。简而言之，依靠引号很可能会引入细微的定时炸弹错误。设置IFS使其不可能。

 