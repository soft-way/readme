# Setup k8s cluster on bare metal or VM

**Precondition**

1. Add CA certificate   
If user use private docker registy, please update CA certificates on machine.

Run below command on your machine.

```
save ca certificate file into /etc/pki/ca-trust/source/anchors/
update-ca-trust
```

2. Make sure ansible, docker and k8s related rpms are installed
```
# rpm -qa | egrep '(kube|ansible)'
kubectl-1.19.6-0.x86_64
kubernetes-cni-0.8.7-0.x86_64
kubelet-1.19.6-0.x86_64
kubeadm-1.19.6-0.x86_64
ansible-2.9.15-1.el7.noarch
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

# for private docker registry, update ca certificate in below file
./roles/env_prepare/files/root_ca.crt

# for dashboard update below files
./roles/dashboard_setup/files/pki/dashboard.crt
./roles/dashboard_setup/files/pki/dashboard.key
   
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
