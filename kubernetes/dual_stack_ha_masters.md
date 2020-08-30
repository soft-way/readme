# Install dual stack Kubernetes cluster (High-Availability Kubernetes Masters)

# Virtual machine
```
                         ----------
     192.168.40.51 eth0  |        |  master node
    ---------------------| k8s-01 |-----------------------
     192.168.40.50 (VIP) |        |  eth1 192.168.44.51
                         ----------       2001:192:168:44::1051

                         ----------
     192.168.40.52 eth0  |        |  master node
    ---------------------| k8s-02 |-----------------------
                         |        |  eth1 192.168.44.52
                         ----------       2001:192:168:44::1052

                         ----------
     192.168.40.53 eth0  |        |  master node
    ---------------------| k8s-03 |-----------------------
                         |        |  eth1 192.168.44.53
                         ----------       2001:192:168:44::1053
  

                         ----------
     192.168.40.54 eth0  |        |  worker node
    ---------------------| k8s-04 |-----------------------
                         |        |  eth1 192.168.44.54
                         ----------       2001:192:168:44::1054
  
                         ----------
     192.168.40.55 eth0  |        |  worker node
    ---------------------| k8s-05 |-----------------------
                         |        |  eth1 192.168.44.55
                         ----------       2001:192:168:44::1055

                         ----------
     192.168.40.56 eth0  |        |  worker node
    ---------------------| k8s-06 |-----------------------
                         |        |  eth1 192.168.44.56
                         ----------       2001:192:168:44::1056
```
                        
# Prepare
1. Modify kubelet service
```
# on all VMs
add --feature-gates=IPv6DualStack=true into kubelet service, for example
vi /etc/systemd/system/kubelet.service.d/kubeadm.conf
Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --feature-gates=IPv6DualStack=true"
```
2. Set VIP
```
# on three master nodes VMs
yum install keepalived
# refer to keepalived.conf 
systemctl start keepalived
systemctl enable keepalived

# let vip (192.168.40.50) on first node
[root@k8s-01 ~]# ip addr show dev eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:05:86:c3:a5:df brd ff:ff:ff:ff:ff:ff
    inet 192.168.40.51/24 brd 192.168.40.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.40.50/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::205:86ff:fec3:a5df/64 scope link 
       valid_lft forever preferred_lft forever

```

# Install
1. Init master node
```
# On VM k8s-01:
kubeadm init --control-plane-endpoint "192.168.40.50:443" \
             --apiserver-advertise-address 192.168.40.51 \
             --feature-gates "IPv6DualStack=true" \
             --apiserver-advertise-address 192.168.40.51 \
             --apiserver-bind-port 443 \
             --service-cidr 10.96.0.0/12,2001:10:96::/112 \
             --pod-network-cidr "172.18.18.0/24,2001:172:18:18::/112"

#
# Enable IPVS, run below command and modify 'mode' to "ipvs"
# then delete kube-proxy pod, let system recreate it, you can see output like: 
# I0828 07:05:09.986451       1 server_others.go:259] Using ipvs Proxier.
# I0828 07:05:09.986502       1 server_others.go:261] creating dualStackProxier for ipvs.
#
# delete existing kube-proxy pod
kubectl edit configmap kube-proxy -n kube-system
kube_proxy_pod=`kubectl get pods -o wide -n kube-system | grep kube-proxy | awk ' { print $1 } '`
kubectl delete pods $kube_proxy_pod -n kube-system

# check ipvs status
kube_proxy_pod=`kubectl get pods -o wide -n kube-system | grep kube-proxy | awk ' { print $1 } '`
kubectl logs $kube_proxy_pod -n kube-system | grep ipvs
```

2. Join as master node
```
# on VM kus-01, Copy certificates and configuration that are shared across all masters in cluster
tar zcvf ~/certs.tar.gz /etc/kubernetes/admin.conf \
         /etc/kubernetes/pki/ca.crt /etc/kubernetes/pki/ca.key \
         /etc/kubernetes/pki/sa.key /etc/kubernetes/pki/sa.pub \
         /etc/kubernetes/pki/front-proxy-ca.crt /etc/kubernetes/pki/front-proxy-ca.key \
         /etc/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/ca.key

for i in 2 3 ; do
    scp ~/certs.tar.gz k8s-0$i:~/
done

# On VM k8s-02:
tar xvf ~/certs.tar.gz -C /
kubeadm join 192.168.40.50:443 --token 931bey.mbst4uv346aazqhq \
    --discovery-token-ca-cert-hash sha256:70bb308476996414d4c9dbfc48b019ae80537e5f1b0bc410069999e621312289 \
    --control-plane --apiserver-bind-port 443

# On VM k8s-03:
tar xvf ~/certs.tar.gz -C /
kubeadm join 192.168.40.50:443 --token 931bey.mbst4uv346aazqhq \
    --discovery-token-ca-cert-hash sha256:70bb308476996414d4c9dbfc48b019ae80537e5f1b0bc410069999e621312289 \
    --control-plane --apiserver-bind-port 443
```

3. Join as work node
```
kubeadm join 192.168.40.50:443 --token 931bey.mbst4uv346aazqhq \
    --discovery-token-ca-cert-hash sha256:70bb308476996414d4c9dbfc48b019ae80537e5f1b0bc410069999e621312289
```

4. Apply calico
```
# On VM k8s-01:
kubectl apply -f calico-3.15.2.yml
```

5. Add dashboard
```
kubectl create namespace kubernetes-dashboard
# put dashboard.crt and dashboard.key into /home/pki
kubectl create secret generic kubernetes-dashboard-certs --from-file=/home/pki -n kubernetes-dashboard
kubectl apply -f kubernetes-dashboard-v2.0.0.yml
```

6. Test pod
```
kubectl apply -f statefulset-centos-systemd.yml
```
