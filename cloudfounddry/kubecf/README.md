

# 概述
## 前言
本文档是对CloudFoundry在k8s集群运行的调研文档，编写文档的目的是让开发者能够很容易在自己的k8s环境里部署CloudFoundry系统。

## 简介
Kubernetes原生CloudFoundry发行版kubecf是CF应用运行时（CFAR）的k8s发行版。它为开发人员提供生产力，并允许平台操作员使用Kubernetes工具和API管理基础架构抽象。
kubecf是CloudFoundry是在k8s平台部署的发行版之一。另外有CF for K8S，本文主要探讨kubecf部署。

## 系统需求

### 虚拟机需求

?	磁盘1：80G，操作系统，k8s系统
?	磁盘2：100G，NFS
?	内存：16G
?	CPU ：4
?	操作系统：CentOS 7.9 升级到最新更新， 内核升级到5.9.11
### 域名服务
?	可修改配置的域名服务器：Arcylic(Windows) 参考附件 1 或者dnsmasq(Linux)


## 附件
### 1. Arcylic 在Windows下的配置

## 参考文献
## 术语和缩略语

+ CFAR（Cloud Foundry Application Runtime）

  CloudFoundry应用运行时接口，是CloudFoundry定义的符合CloudFoundry平台的一组应用规范。

