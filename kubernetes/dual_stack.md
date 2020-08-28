# Install dual stack Kubernetes cluster

0. Modify kubelet service
```
add --feature-gates=IPv6DualStack=true into kubelet service, for example
vi /etc/systemd/system/kubelet.service.d/kubeadm.conf
Environment="KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --feature-gates=IPv6DualStack=true"
```

1. Init master node
```
kubeadm init --feature-gates "IPv6DualStack=true" \
             --apiserver-advertise-address 192.168.40.51 \
             --apiserver-bind-port 443 \
             --service-cidr 10.96.0.0/12,2001:10:96::/112 \
             --pod-network-cidr "172.18.18.0/24,2001:172:18:18::/112"

#
# Enable IPVS, run below command and modify mode to "ipvs"
# then delete kube-proxy pod, let system recreate it, you can see output like: 
# I0828 07:05:09.986451       1 server_others.go:259] Using ipvs Proxier.
# I0828 07:05:09.986502       1 server_others.go:261] creating dualStackProxier for ipvs.
#
kubectl edit configmap kube-proxy -n kube-system
kube_proxy_pod=`kubectl get pods -o wide -n kube-system | grep kube-proxy | awk ' { print $1 } '`
kubectl delete pods $kube_proxy_pod -n kube-system
kubectl logs $kube_proxy_pod -n kube-system | grep ipvs
```

2. Apply calico
```
kubectl apply -f calico-3.15.2.yaml
```

3. Add dashboard
```
kubectl create namespace kubernetes-dashboard
# put dashboard.crt and dashboard.key into /home/pki
kubectl create secret generic kubernetes-dashboard-certs --from-file=/home/pki -n kubernetes-dashboard
kubectl apply -f kubernetes-dashboard-v2.0.0.yaml
```
