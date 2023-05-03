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
    - sha256:6a51a9b1ca91a023cf8080c300dce0b5899a3f71f1f55dba36d7a005a10710f2
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


