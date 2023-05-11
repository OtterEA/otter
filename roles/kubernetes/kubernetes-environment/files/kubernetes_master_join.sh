#!/bin/bash
# ipvs模式,删除回环信息
if grep "127.0.0.1 apiserver.cluster.local" /etc/hosts ; then
    sed -i '/127.0.0.1 apiserver.cluster.local/d' /etc/hosts
fi

if ! grep "192.168.0.21 apiserver.cluster.local" /etc/hosts ; then
    echo "192.168.0.21 apiserver.cluster.local" >> /etc/hosts
fi

# 节点加入集群
cat > /tmp/otter/kubeadm-new-node << EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
discovery:
  bootstrapToken:
    apiServerEndpoint: apiserver.cluster.local:6443
    token: 9a08jv.c0izixklcxtmnze7
    caCertHashes:
    - sha256:8f6417ef7486917412edc8570f112f3ad9e48e799968282f9a970d862ff715b0
controlPlane:
  localAPIEndpoint:
    #advertiseAddress: 192.168.0.21 
    #advertiseAddress: apiserver.cluster.local # will be change to 127 after join cluster
    advertiseAddress: 0.0.0.0
    bindPort: 6443
  certificateKey: 5333dd1e432c9a3563870608bea3e412d664040d891492aa6fb1c47d95cefe6c
EOF

# --ignore-preflight-errors=all fix kubeadm init image pull check
kubeadm join --config /tmp/otter/kubeadm-new-node --ignore-preflight-errors=all

# token.csv in kubernetes-environment role

# 生成bootstrap-kubelet.conf文件
cat > /etc/kubernetes/bootstrap-kubelet.conf << EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://apiserver.cluster.local:6443
  name: bootstrap
contexts:
- context:
    cluster: bootstrap
    user: kubelet-bootstrap
  name: bootstrap
current-context: bootstrap
preferences: {}
users:
- name: kubelet-bootstrap
  user:
    token: 9a08jv.c0izixklcxtmnze7
EOF

# 拷贝admin.conf
cp -apf /etc/kubernetes/admin.conf ~/.kube/config

sleep 30

# delete control-nodes taints
kubectl taint nodes --all node-role.kubernetes.io/master- | cat

sed -i "s@192.168.0.21 apiserver.cluster.local@127.0.0.1 apiserver.cluster.local@g"  /etc/hosts

