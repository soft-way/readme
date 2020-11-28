# Setup k8s cluster on bare metal or VM

**Precondition**

1. Add CA certificate   
Because k8s cluster will use image in organization internal. so you must download
CA certificate into system. 

    Run below command on your active pilot. It will auto sync to all blades.

```
    save ca certificate file into /etc/pki/ca-trust/source/anchors/
    update-ca-trust
```

2. Make sure ansible, docker and k8s related rpms are installed
```
    # rpm -qa |grep kubernetes
    kubernetes-1.19.0-1.el7.x86_64
    kubernetes-client-1.19.0-1.el7.x86_64
    kubernetes-master-1.19.0-1.el7.x86_64
    kubernetes-kubeadm-1.19.0-1.el7.x86_64
    kubernetes-node-1.19.0-1.el7.x86_64
```

3. Route has been added into all nodes and all can reach docker image repo
```
```
4. ksh is installed
```
    yum install ksh
```

**Install k8s cluster**

1. Logon pilot as root user
```
   git clone https://github.com/soft-way/readme.git
   cd readme/kubernetes/ansible
   
   # edit below file, select cluster nodes
   inventory/3nodes.inv

   # edit below file, change cluster parameters, pod_subnet, ...
   # in most case, the default values are ok
   # control_plane_endpoint: VIP or static IP on first master
   group_vars/all

   ansible-playbook -i inventory/3nodes.inv k8s_setup.yml
```

**Clear k8s cluster**
```
   ansible-playbook -i inventory/3nodes.inv k8s_clear.yml
```
