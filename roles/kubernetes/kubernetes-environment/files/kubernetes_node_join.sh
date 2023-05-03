#!/bin/bash
# ipvs 单master加入集群脚本
if ! grep "192.168.0.133 apiserver.cluster.local" /etc/hosts ; then
	echo "192.168.0.133 apiserver.cluster.local" >> /etc/hosts
fi

# 节点加入集群
cat > /tmp/otter/kubeadm-new-node <<EOF
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
caCertPath: "/etc/kubernetes/pki/ca.crt"
discovery:
  bootstrapToken: 
    apiServerEndpoint: apiserver.cluster.local:6443
    token: 9a08jv.c0izixklcxtmnze7
    caCertHashes:
    - sha256:8d6e212f0a4f03acfc14d42d492134b9441cb17e16ae70e328e940ef80c2c69c
EOF
kubeadm join --config /tmp/otter/kubeadm-new-node

# 生成bootstrap-kubelet.conf配置文件
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


