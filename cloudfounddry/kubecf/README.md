

# 1 概述
## 1.1 前言
本文档是对CloudFoundry在k8s集群运行的调研文档，编写文档的目的是让开发者能够很快速地在自己的环境里部署CloudFoundry系统。

## 1.2 简介
Kubernetes原生CloudFoundry发行版kubecf是CF应用运行时（CFAR）的k8s发行版。它为开发人员提供生产力，并允许平台操作员使用Kubernetes工具和API管理基础架构抽象。
kubecf是CloudFoundry是在k8s平台部署的发行版之一。另外有CF for K8S，本文主要探讨kubecf部署。

## 1.3 系统需求

### 1.3.1 虚拟机需求

- 磁盘1：80G，操作系统，k8s系统
- 磁盘2：100G，NFS
- 内存：16G
- CPU ：4
- 操作系统：CentOS 7.9 升级到最新更新， 内核升级到5.9.11
- 说明：虚拟机可以是VirtualBox，KVM，VMware等

### 1.3.2 域名服务
- 可修改配置的域名服务器：Arcylic(Windows) 参考附件 1 或者dnsmasq(Linux)

# 2 安装
# 3 测试使用
# 4 附件
## 4.1 域名服务 Arcylic 在Windows下的配置
### 4.1.1 服务器端配置
本文以Windows下域名服务器Arcylic为例，Linux下可以推荐使用dnsmasq。下载地址https://sourceforge.net/projects/acrylic/
安装之后，打开Acylic UI进行配置，需要的配置如下：
File + Open Arcylic Configuration，添加如下，然后保存
```
[AllowedAddressesSection]
IP1=192.168.*
```
File + Open Arcylic Hosts，添加如下，然后保存
```
192.168.1.27 *.cf1.xyz.com     # 这里192.168.1.27是安装kubecf虚拟机的IP
192.168.1.62 registry.xyz.com  # docker 镜像服务器
192.168.1.71 xmchen.xyz.com    # 资源共享服务器
192.168.1.27 k8s-softway4.xyz.com # k8s 集群dashboard
```
添加防火墙规则，管理员运行如下命令：
```
netsh advfirewall firewall add rule name="Allow DNS UDP" dir=in action=allow protocol=UDP localport=53
```
Linux下使用dnsmasq，参考相应文档。

### 4.1.2 客户端配置
目的是使用新的DNS服务器来解析域名，Windows下：打开网络和Internet设置，进入网络和共享中心，选择网卡，点击属性，进入Internet协议版本 4 （TCP/ipv4）,  常规，使用自己的DNS，添加 DNS服务器地址，这里是2.1.1 服务器的地址。
![Windows 域名服务配置](images/1-1-runtime-architecture.png)

## 4.2 Docker镜像服务设置
## 4.3 自签名证书生成
步骤：
- 1. 产生CA key
```
openssl genrsa -out root_ca.key 4096
```
- 2. 产生CA 证书
```
openssl req -new -x509 -sha256 -days 3650 -key root_ca.key -out root_ca.crt -config <(cat rootca.csr.cnf) -extensions v3_req
```
其中rootca.csr.cnf内容：
```
[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn

[v3_req]
basicConstraints = CA:TRUE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, cRLSign, keyCertSign

[dn]
C=CN
ST=Beijing
L=SD
O=XYZ
OU=DX
emailAddress=cloudteam@xyz.com
CN = XYZ CloudAdmin
```
- 3. 产生服务key
```
openssl genrsa -out server.key 2048
```
- 4. 产生服务证书csr
```
openssl req -new -key server.key -out server.csr -config <( cat server.csr.cnf )
```
其中server.csr.cnf内容：
```
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=CN
ST=Beijing
L=SD
O=XYZ
OU=DX
emailAddress=xuming.chen@xyz.com
CN = XYZ
```
- 5. 签名服务证书
```
openssl x509 -req -days 3650 -in server.csr -CA root_ca.crt -extfile server_v3.ext -CAkey root_ca.key -set_serial 0101 -out server.crt -sha256
```
其中server_v3.ext内容：
```
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = *.xyz.com
IP.1 = 192.168.1.27
```
- 6. 查看服务证书
```
openssl x509 -noout -text -in server.crt
```
- 7. 验证服务证书
```
openssl verify -CAfile root_ca.crt server.crt
```

# 5 参考文献
# 6 术语和缩略语

+ CFAR（Cloud Foundry Application Runtime）

  CloudFoundry应用运行时接口，是CloudFoundry定义的符合CloudFoundry平台的一组应用规范。

