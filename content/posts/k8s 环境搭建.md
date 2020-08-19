---
title: k8s 环境搭建
slug: k8s-environment-construction
date: 2020-08-14 11:09:16
---
# k8s 环境搭建

## Intro

关于组织主题，活动相关介绍

## 前期准备

硬件要求

- master节点 内存2核3G(最小2G)
- node节点 内存2核2G

其中可以

## 搭建过程

配置 `etc/host`

~~~bash
172.19.0.21 debian-21
172.19.0.22 debian-22
172.19.0.23 debian-23
~~~

配置 `ssh`

`apt install openssh-server`
`vim /etc/ssh/sshd_config`
`PermitRootLogin yes`

开启 ipv4 的 forward机制

```bash
vim /etc/sysctl.conf
net.ipv4.ip_forward=1
sysctl --system
```

关闭 swap

`swapoff -a`

安装 runtime （每个节点都需要安装）

~~~bash
apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common


curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -


add-apt-repository \
   "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian \
   $(lsb_release -cs) \
   stable"

apt update

apt install docker-ce docker-ce-cli containerd.io
~~~

配置 docker

修改docker配置

```bash
vim /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://dockerhub.azk8s.cn",
    "https://reg-mirror.qiniu.com"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "insecure-registries": ["0.0.0.0/0"],
  "storage-driver": "overlay2"
}
```



[Kubernates 组件](https://kubernetes.io/zh/docs/concepts/overview/components/)

Master 组件

| Protocol | Direction | Port Range | Purpose                 | Used By              |
| :------- | :-------- | :--------- | :---------------------- | :------------------- |
| TCP      | InBound   | 6443*      | Kubernetes API server   | All                  |
| TCP      | InBound   | 2379-2380  | etcd server client API  | kube-apiserver, etcd |
| TCP      | InBound   | 10250      | Kubelet API             | Self, Control plane  |
| TCP      | InBound   | 10251      | kube-scheduler          | Self                 |
| TCP      | InBound   | 10252      | kube-controller-manager | Self                 |

Nodes 组件

| Protocol | Direction | Port Range  | Purpose           | Used By             |
| :------- | :-------- | :---------- | :---------------- | :------------------ |
| TCP      | InBound   | 10250       | Kubelet API       | Self, Control plane |
| TCP      | InBound   | 30000-32767 | NodePort Services | All                 |

安装 kebulet kubeadm kubectl （**master、node节点都需要安装**）

~~~bash
apt-get update && apt-get install -y apt-transport-https
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - 

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
~~~

在 master 节点

~~~bash
kubeadm init --apiserver-advertise-address 172.19.0.21 --pod-network-cidr 10.10.0.0/16 --service-cidr 10.11.0.0/16  --kubernetes-version=v1.15.3 --dry-run
~~~

k8s中要注意一下几个网络:

- 机器的网络
- pod的网络
- 集群的网络

