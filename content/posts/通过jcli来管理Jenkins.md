---
title: 通过 jcli 管理 Jenkins
slug: manage-jenkins-by-using-jcli
date: 2020-08-18T10:59:10+08:00
draft: true
tags:
- jenkins

---

![jenkins-logo](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/logo-jenkins.png)



> Jenkins 是强大的自动化工具。
>
> 本文介绍如果通过 jcli（Jenkins Client）来管理 Jenkins 站点

<!--more-->

## 环境

- Jenkins Service

## 安装

Linux 下的用户，可通过一下命令安装 `jcli`

```bash
curl -L https://github.com/jenkins-zh/jenkins-cli/releases/latest/download/jcli-linux-amd64.tar.gz|tar xzv

# 将 jcli 后添加进环境变量
echo export PATH=~:$PATH >> ~/.bashrc && source ~/.bashrc
```

##使用

`jcli -h` 

```bash
Jenkins CLI written by golang which could help you with your multiple Jenkins,

We'd love to hear your feedback at https://github.com/jenkins-zh/jenkins-cli/issues

Usage:
  jcli [command]

Available Commands:
  casc        Configuration as Code
  center      Manage your update center
  completion  Generate shell completion scripts
  computer    Manage the computers of your Jenkins
  config      Manage the config of jcli
  credential  Manage the credentials of your Jenkins
  crumb       Print crumbIssuer of Jenkins
  cwp         Custom Jenkins WAR packager for Jenkins
  doc         Generate document for all jcl commands
  help        Help about any command
  job         Manage the job of your Jenkins
  open        Open your Jenkins with a browser
  plugin      Manage the plugins of Jenkins
  queue       Manage the queue of your Jenkins
  restart     Restart your Jenkins
  runner      The wrapper of jenkinsfile runner
  shell       Create a sub shell so that changes to a specific Jenkins remain local to the shell.
  shutdown    Puts Jenkins into the quiet mode, wait for existing builds to be completed, and then shut down Jenkins
  user        Print the user of your Jenkins
  version     Print the version of Jenkins CLI

Flags:
      --config-load           If load a default config file (default true)
      --configFile string     An alternative config file
      --debug                 Print the output into debug.html
      --doctor                Run the diagnose for current command
  -h, --help                  help for jcli
      --insecureSkipVerify    If skip insecure skip verify (default true)
  -j, --jenkins string        Select a Jenkins server for this time
      --logger-level string   Logger level which could be: debug, info, warn, error (default "warn")
      --proxy string          The proxy of connection to Jenkins
      --proxy-auth string     The auth of proxy of connection to Jenkins
      --proxy-disable         Disable proxy setting
      --token string          The token of Jenkins
      --url string            The URL of Jenkins
      --username string       The username of Jenkins

Use "jcli [command] --help" for more information about a command.
```

可以看出 `jcli` 里面涵盖了许多子命令，为了方便查询，`jcli` 提供了生成命令文档的功能

`jcli doc [PATH]` 

在导出目录下：

![jcli-command-doc](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/jcli-command-doc.png)

里面的内容为：

![jcli-command-doc-content](https://blog-1252790741.cos.ap-shanghai.myqcloud.com/uPic/jcli-command-doc-content.png)

## 常用命令

由于命令繁多，这里列出一些比较常用的命令，更多的功能请参阅上面生成的文档。

### Center

* [jcli center download](/commands/jcli_center_download/)	 - Download jenkins.war
* [jcli center identity](/commands/jcli_center_identity/)	 - Print the identity of current Jenkins
* [jcli center mirror](/commands/jcli_center_mirror/)	 - Set the update center to a mirror address
* [jcli center start](/commands/jcli_center_start/)	 - Start Jenkins server from a cache directory
* [jcli center upgrade](/commands/jcli_center_upgrade/)	 - Upgrade your Jenkins
* [jcli center watch](/commands/jcli_center_watch/)	 - Watch your update center status

### Config

* [jcli config add](/commands/jcli_config_add/)	 - Add a Jenkins config item
* [jcli config clean](/commands/jcli_config_clean/)	 - Clean up some unavailable config items
* [jcli config edit](/commands/jcli_config_edit/)	 - Edit a Jenkins config
* [jcli config generate](/commands/jcli_config_generate/)	 - Generate a sample config file for you
* [jcli config list](/commands/jcli_config_list/)	 - List all Jenkins config items
* [jcli config plugin](/commands/jcli_config_plugin/)	 - Manage plugins for jcli
* [jcli config plugin](/commands/jcli_config_plugin/)	 - Manage plugins for jcli
* [jcli config remove](/commands/jcli_config_remove/)	 - Remove a Jenkins config
* [jcli config select](/commands/jcli_config_select/)	 - Select one config as current Jenkins

### Credential

* [jcli credential create](/commands/jcli_credential_create/)	 - Create a credential from Jenkins
* [jcli credential delete](/commands/jcli_credential_delete/)	 - Delete a credential from Jenkins
* [jcli credential list](/commands/jcli_credential_list/)	 - List all credentials of Jenkins

### Job

* [jcli job artifact](/commands/jcli_job_artifact/)	 - Print the artifact list of target job
* [jcli job build](/commands/jcli_job_build/)	 - Build the job of your Jenkins
* [jcli job create](/commands/jcli_job_create/)	 - Create a job in your Jenkins
* [jcli job delete](/commands/jcli_job_delete/)	 - Delete a job in your Jenkins
* [jcli job disable](/commands/jcli_job_disable/)	 - Disable a job in your Jenkins
* [jcli job edit](/commands/jcli_job_edit/)	 - Edit the job of your Jenkins
* [jcli job enable](/commands/jcli_job_enable/)	 - Enable a job in your Jenkins
* [jcli job history](/commands/jcli_job_history/)	 - Print the history of job in your Jenkins
* [jcli job input](/commands/jcli_job_input/)	 - Input a job in your Jenkins
* [jcli job log](/commands/jcli_job_log/)	 - Print the job's log of your Jenkins
* [jcli job param](/commands/jcli_job_param/)	 - Get parameters of the job of your Jenkins
* [jcli job search](/commands/jcli_job_search/)	 - Print the job of your Jenkins
* [jcli job stop](/commands/jcli_job_stop/)	 - Stop a job build in your Jenkins
* [jcli job type](/commands/jcli_job_type/)	 - Print the types of job which in your Jenkins

### Plugin

* [jcli plugin build](/commands/jcli_plugin_build/)	 - Build the Jenkins plugin project
* [jcli plugin check](/commands/jcli_plugin_check/)	 - Check update center server
* [jcli plugin create](/commands/jcli_plugin_create/)	 - Create a plugin project from the archetypes
* [jcli plugin download](/commands/jcli_plugin_download/)	 - Download the plugins
* [jcli plugin install](/commands/jcli_plugin_install/)	 - Install the plugins
* [jcli plugin list](/commands/jcli_plugin_list/)	 - Print all the plugins which are installed
* [jcli plugin open](/commands/jcli_plugin_open/)	 - Open update center server in browser
* [jcli plugin release](/commands/jcli_plugin_release/)	 - Release current plugin project
* [jcli plugin search](/commands/jcli_plugin_search/)	 - Print the plugins of your Jenkins
* [jcli plugin trend](/commands/jcli_plugin_trend/)	 - Show the trend of the plugin
* [jcli plugin uninstall](/commands/jcli_plugin_uninstall/)	 - Uninstall the plugins
* [jcli plugin upgrade](/commands/jcli_plugin_upgrade/)	 - Upgrade the specific plugin
* [jcli plugin upload](/commands/jcli_plugin_upload/)	 - Upload a plugin  to your Jenkins

### User

* [jcli user create](/commands/jcli_user_create/)	 - Create a user for your Jenkins
* [jcli user delete](/commands/jcli_user_delete/)	 - Delete a user for your Jenkins
* [jcli user edit](/commands/jcli_user_edit/)	 - Edit the user of your Jenkins
* [jcli user token](/commands/jcli_user_token/)	 - Token the user of your Jenkins

### Jenkins

- `jcli restart`  - Restart your Jenkins
- `jcli shutdown` - Puts Jenkins into the quiet mode, wait for existing builds to be completed, and then shut down Jenkins
- `jcli runner`  - The wrapper of jenkinsfile runner
  Get more about jenkinsfile runner from https://github.com/jenkinsci/jenkinsfile-runner
- `jcli shell` - Create a sub shell so that changes to a specific Jenkins remain local to the shell.

## 参考

[Jenkins CLI](https://jenkins-zh.cn/tutorial/management/cli/jcli/)





## 

