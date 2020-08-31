# Kubernetes install procedure
## Cluster setup
```markdown

# Make sure all required software installed before doing following commands
# Generate default config
kubeadm config print init-defaults --component-configs KubeletConfiguration > ~/kubeadm-init-config.yaml

# Change some fields, main purpose is to enable podpreset
sed -i 's/imageRepository.*/imageRepository: hub.your.docker.com/g; s/bindPort.*/bindPort: 443/g' ~/kubeadm-init-config.yaml
sed -i 's/kubernetesVersion.*/kubernetesVersion: v1.14.1/g; s/serviceSubnet.*/serviceSubnet: 10.96.0.0\/24/g' ~/kubeadm-init-config.yaml
sed -i 's/podSubnet.*/podSubnet: 172.19.0.0\/24/g; s/advertise-address.*/advertise-address: 192.168.0.100/g' ~/kubeadm-init-config.yaml

# Install master node
kubeadm init --config ~/kubeadm-init-config.yaml

# Join cluster
kubeadm join 192.168.0.100:443 --token btazyg.b3w70lu1akbd53jp \
    --discovery-token-ca-cert-hash sha256:8f81dbca87e8c4bde1c21116645cfc11a1dca1efa5ae5ff105a2f6e543a3e78a 

# Setup kubectl env
mkdir -p $HOME/.kube
\cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# Set RBAC and network plugin
kubectl apply -f ./rbac-kdd.yaml
kubectl apply -f ./calico.yaml

# Dashboard
mkdir $HOME/pki
# create your certificate and key file for dashboard under $HOME/pki
# dashboard.crt  dashboard.key
kubectl -n kube-system create secret generic kubernetes-dashboard-certs --from-file=$HOME/pki
kubectl apply -f kubernetes-dashboard.yaml
# Then you can access dashboard via https://192.168.0.100:30443/

# Podpreset ptional for gitlab integration
kubectl create ns gitlab-managed-apps
kubectl create -f podpreset.yaml --namespace=gitlab-managed-apps
```

## PersistentVolume
```markdown
# Generate two key file from ceph node
ceph auth get client.admin 2>&1 |grep "key = " |awk '{print  $3'} |xargs echo -n > $HOME/ceph/client.admin.key
ceph auth add client.kube mon 'allow r' osd 'allow rwx pool=kube'
ceph auth get-key client.kube > $HOME/ceph/client.kube.key

# Create kube pool on ceph
ceph osd pool create kube 8 8

# Create two user secret 
kubectl create secret generic ceph-admin-secret --from-file=$HOME/client.admin.key --namespace=kube-system --type=kubernetes.io/rbd
kubectl create secret generic ceph-secret --from-file=$HOME/client.kube.key --namespace=kube-system --type=kubernetes.io/rbd

# Boot external provisioner
kubectl apply -f rbd-provisioner.yaml

# Create StorageClass
kubectl apply -f storage-class.yaml
```
