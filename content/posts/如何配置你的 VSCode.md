---
title: 如何配置你的 VSCode
slug: how-to-configure-your-vscode
tags:
- vscode
date: 2020-06-13 16:46:23
---
# 如何配置你的 VSCode

这篇主要分享下 VSCode 的用法，以及如何使用其强大的插件来提升效率，我列出了一些自己用到的比较使用的插件。

在拓展里面都能看到插件的相关文档，使用与配置。

欢迎大家补充 :)

## 本地化

**Chinese (Simplified) Language Pack for Visual Studio Code**

> 适用于 VS Code 的中文（简体）语言包

## 开发

**Remote Development**

> An extension pack that lets you open any folder in a container, on a remote machine, or in WSL and take advantage of VS Code's full feature set.
>
> 可在远程主机上开发或者在容器内开发

![demo](https://microsoft.github.io/vscode-remote-release/images/ssh-readme.gif)



**Code Runner**

> Run C, C++, Java, JS, PHP, Python, Perl, Ruby, Go, Lua, Groovy, PowerShell, CMD, BASH, F#, C#, VBScript, TypeScript, CoffeeScript, Scala, Swift, Julia, Crystal, OCaml, R, AppleScript, Elixir, VB.NET, Clojure, Haxe, Obj-C, Rust, Racket, Scheme, AutoHotkey, AutoIt, Kotlin, Dart, Pascal, Haskell, Nim,
>
> 支持各种语言运行，动态语言需要配置下 interpreter，静态语言配置 compiler 

## 编程语言

**Python**

> Python extension pack
>
> 集成了针对 Python 智能提示，语法检查，格式化等功能

- [IntelliSense](https://code.visualstudio.com/docs/python/editing#_autocomplete-and-intellisense): Edit your code with auto-completion, code navigation, syntax checking and more
- [Linting](https://code.visualstudio.com/docs/python/linting): Get additional code analysis with Pylint, Flake8 and more
- [Code formatting](https://code.visualstudio.com/docs/python/editing#_formatting): Format your code with black, autopep or yapf
- [Debugging](https://code.visualstudio.com/docs/python/debugging): Debug your Python scripts, web apps, remote or multi-threaded processes
- [Testing](https://code.visualstudio.com/docs/python/unit-testing): Run and debug tests through the Test Explorer with unittest, pytest or nose
- [Jupyter Notebooks](https://code.visualstudio.com/docs/python/jupyter-support): Create and edit Jupyter Notebooks, add and run code cells, render plots, visualize variables through the variable explorer, visualize dataframes with the data viewer, and more
- [Environments](https://code.visualstudio.com/docs/python/environments): Automatically activate and switch between virtualenv, venv, pipenv, conda and pyenv environments
- [Refactoring](https://code.visualstudio.com/docs/python/editing#_refactoring): Restructure your Python code with variable extraction, method extraction and import sorting

**XML**

> XML Language Support by Red Hat
>
> Redhat 出品，必属精品。

![demo](https://user-images.githubusercontent.com/148698/45977901-df208a80-c018-11e8-85ec-71c70ba8a5ca.gif)

- Syntax error reporting
- General code completion
- Auto-close tags
- Automatic node indentation
- Symbol highlighting
- Document folding
- Document links
- Document symbols and outline
- Renaming support
- Document Formatting
- DTD validation
- DTD completion
- DTD formatting
- XSD validation
- XSD based hover
- XSD based code completion
- XSL support
- XML catalogs
- File associations
- Code actions
- Schema Caching

**YAML**

> YAML Language Support by Red Hat, with built-in Kubernetes and Kedge syntax support
>
> Redhat 出品，必属精品。

![demo](https://raw.githubusercontent.com/redhat-developer/vscode-yaml/master/images/demo.gif)

1. YAML validation:
   - Detects whether the entire file is valid yaml
   - Detects errors such as:
     - Node is not found
     - Node has an invalid key node type
     - Node has an invalid type
     - Node is not a valid child node
2. Document Outlining (Ctrl + Shift + O):
   - Provides the document outlining of all completed nodes in the file
3. Auto completion (Ctrl + Space):
   - Auto completes on all commands
   - Scalar nodes autocomplete to schema's defaults if they exist
4. Hover support:
   - Hovering over a node shows description *if provided by schema*
5. Formatter:
   - Allows for formatting the current file



**Markdown All in One**

> All you need to write Markdown (keyboard shortcuts, table of contents, auto preview and more)
>
> 提供了语法提示，支持 Latex，格式化支持，预览等一条龙服务。

## 格式

**Auto Rename Tag**

> Auto rename paired HTML/XML tag

![demo](https://github.com/formulahendry/vscode-auto-rename-tag/raw/master/images/usage.gif)



**Auto Complete Tag**

> Extension Packs to add close tag and rename paired tag automatically for HTML/XML



**Auto Close Tag**

> Automatically add HTML/XML close tag, same as Visual Studio IDE or Sublime Text

![usage](https://github.com/formulahendry/vscode-auto-close-tag/raw/master/images/usage.gif)



**Bracket Pair Colorizer**

> A customizable extension for colorizing matching brackets

![demo](https://github.com/CoenraadS/Bracket-Pair-Colorizer-2/raw/master/images/example.png)



**Better Comments**

> Improve your code commenting by annotating with alert, informational, TODOs, and more!

![demo](https://github.com/aaron-bond/better-comments/raw/master/images/better-comments.PNG)

## 可视化

**Excel Viewer**

> View Excel spreadsheets and CSV files within Visual Studio Code workspaces.

![demo](https://juback.blob.core.windows.net/img/csv-preview-2.gif)



**Draw.io Integration**

> This extension integrates Draw.io into VS Code.

![demo](https://github.com/hediet/vscode-drawio/raw/master/docs/demo.gif)



## CI/CD

**JenkinsFile Support**

> Extension provides basic jenkinsfile support (highlighting, snippets and completion)

![demo](https://github.com/sgwozdz/jenkinsfile-support/raw/master/images/functionality.png)



**Jenkins Jack**

> Jack into your remote Jenkins to execute Pipeline scripts, provide Pipeline step auto-completions, pull Shared Library step documenation, run console groovy scripts across multiple nodes, and more! Honestly, not that much more.

![demo](https://github.com/tabeyti/jenkins-jack/blob/master/images/doc/demo.gif)

