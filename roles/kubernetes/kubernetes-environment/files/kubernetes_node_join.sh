#!/bin/bash
# ipvs 单master加入集群脚本
if ! grep "192.168.0.21 apiserver.cluster.local" /etc/hosts ; then
	echo "192.168.0.21 apiserver.cluster.local" >> /etc/hosts
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
    - sha256:4f211d1097ed183e1503ba8c0e4e88154e7c00e554efacfa82d75df8a1005ecb
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


