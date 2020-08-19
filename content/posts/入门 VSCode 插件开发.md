---
title: VSCode 插件开发入门
tags:
  - vscode
toc: true
comments: true
slug: getting-started-with-vscode-plugin-development
date: 2019-04-02 13:49:04
---

# 入门 VSCode 插件开发

[toc]

## 核心组件

- Electron
- Monaco Editor
- Language Server Protocol
- Debug Adapter Protocol

### Electorn (formerly Atom Shell)

- 基于 Node.js（作为后端）和 Chromium（作为前端)

- 使用 HTML, CSS 和 JavaScript 开发跨平台桌面GUI应用程序

-   使用者：Atom, Skype, GitHub Desktop, Slack, Microsoft Teams …

[Github传送门](https://github.com/electron/electron)

### Monaca Editor

- 基于浏览器的代码编辑器：IntelliSense，代码验证，语法高亮，文件比较 …

- 支持主流浏览器：IE 11, Edge, Chrome, Firefox, Safari 和 Opera

- 使用者：Gitee Web IDE, Cloud Studio, Eclipse Che, Eclipse Theia,  Azure DevOps (原为 Visual Studio Team Services), OneDrive, Edge Dev Tools

[GitHub传送门](https://github.com/Microsoft/monaco-editor )

### Language Server Protocol (LSP)

- 它是 Editor/IDE 与语言服务器之间的一种协议，可以让不同的 Editor/IDE 方便嵌入各种程序语言，允许开发人员在最喜爱的工具中使用各种语言来撰写程序。

- 支持 LSP 的开发工具: Eclipse IDE, Eclipse Theia, Atom, Sublime Text, Emacs

[GitHub传送门](https://github.com/Microsoft/language-server-protocol)

### Debug Adapter Protocol (DAP)

- DAP 与 LSP 的目的类似，DAP 把 Editor/IDE 与 不同语言的 debugger 解耦，极大地方便了 Editor/IDE 与其他 Debugger 的集成。

- 支持 DAP 的开发工具: Eclipse IDE, Eclipse Theia, Emacs, Vim 

[GitHub传送门](https://github.com/Microsoft/debug-adapter-protocol)

## 插件开发流程

### 开发环境

- Visual Studio Code

- Node.js

  `npm -v` 查看是否安装成功

- Yeoman and VS Code Extension generator:

  `npm install -g yo generator-code`

### 插件类型

- Themes

- Snippets

- Formatters

- Linters

- Debuggers

- Programming Languages

- Keymaps

- SCM Provides

- Extensions Packs

- Others

### 如何搭建工程

1. `yo code`
2. 选择你搭建项目的类型
3. 是否导入相关资源
4. 选择名字



### e.g. Color Thems

### e.g. Code Snippet

## VSCode 界面功能拓展

- Workbench
- Editor area

### Workbench

![image-20190331110014505](https://ws1.sinaimg.cn/large/006tKfTcgy1g1lsn7x262j30uy0lk7bn.jpg)

### Editor Area

- Codelens
- Decoration
- Gutter
- Hover
- Context Menu

### e.g. Translator Extension



