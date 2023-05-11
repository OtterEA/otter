#!/bin/bash
# ipvs 多master节点node节点加入集群脚本
# 集群必须以第一个master节点IP加入集群
if grep "192.168.0.25 apiserver.cluster.local" /etc/hosts; then
    sed -i "/192.168.0.25 apiserver.cluster.local/d" /etc/hosts
fi

if ! grep "192.168.0.21 apiserver.cluster.local" /etc/hosts; then
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
EOF

# --ignore-preflight-errors=all fix kubeadm init image pull check
kubeadm join --config /tmp/otter/kubeadm-new-node --ignore-preflight-errors=all

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

# 生成lvscare
cat > /etc/kubernetes/manifests/kube-sealyun-lvscare.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: kube-sealyun-lvscare
    tier: control-plane
  name: kube-sealyun-lvscare
  namespace: kube-system
spec:
  containers:
  - args:
    - care
    - --vs
    - 192.168.0.25:6443
    - --health-path
    - /healthz
    - --health-schem
    - https
    - --rs
    - 192.168.0.21:6443
    - --rs
    - 192.168.0.22:6443
    - --rs
    - 192.168.0.23:6443
    command:
    - /usr/bin/lvscare
    image: registry.otter.local/k8s/docker.io/fanux/lvscare:v1.1.1
    imagePullPolicy: IfNotPresent
    name: kube-sealyun-lvscare
    securityContext:
      privileged: true
    volumeMounts:
    - mountPath: /lib/modules
      name: lib-modules
      readOnly: true
  hostNetwork: true
  priorityClassName: system-cluster-critical
  volumes:
  - hostPath:
      path: /lib/modules
      type: ""
    name: lib-modules
EOF

# 将域名调整为vip
sed -i "s@192.168.0.21 apiserver.cluster.local@192.168.0.25 apiserver.cluster.local@g"  /etc/hosts

