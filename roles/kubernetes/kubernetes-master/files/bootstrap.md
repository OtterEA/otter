现在启动引导节点被 身份认证 为 system:bootstrapping 组的成员， 它需要被 授权 创建证书签名请求（CSR）并在证书被签名之后将其取回。 幸运的是，Kubernetes 提供了一个 ClusterRole，其中精确地封装了这些许可， system:node-bootstrapper。

为了实现这一点，你只需要创建 ClusterRoleBinding，将 system:bootstrappers 组绑定到集群角色 system:node-bootstrapper。
```yaml
# 允许启动引导节点创建 CSR
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: create-csrs-for-bootstrapping
subjects:
- kind: Group
  name: system:bootstrappers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: system:node-bootstrapper
  apiGroup: rbac.authorization.k8s.io
```

为了对 CSR 进行批复，你需要告诉控制器管理器批复这些 CSR 是可接受的。 这是通过将 RBAC 访问权限授予正确的组来实现的。许可权限有两组：
1. nodeclient：如果节点在为节点创建新的证书，则该节点还没有证书。 该节点使用前文所列的令牌之一来执行身份认证，因此是组 system:bootstrappers 组的成员。
2. selfnodeclient：如果节点在对证书执行续期操作，则该节点已经拥有一个证书。 节点持续使用现有的证书将自己认证为 system:nodes 组的成员。

要允许 kubelet 请求并接收新的证书，可以创建一个 ClusterRoleBinding 将启动引导节点所处的组 system:bootstrappers 绑定到为其赋予访问权限的 ClusterRole system:certificates.k8s.io:certificatesigningrequests:nodeclient：
```yaml
# 批复 "system:bootstrappers" 组的所有 CSR
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: auto-approve-csrs-for-group
subjects:
- kind: Group
  name: system:bootstrappers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: system:certificates.k8s.io:certificatesigningrequests:nodeclient
  apiGroup: rbac.authorization.k8s.io
```


要允许 kubelet 对其客户端证书执行续期操作，可以创建一个 ClusterRoleBinding 将正常工作的节点所处的组 system:nodes 绑定到为其授予访问许可的 ClusterRole system:certificates.k8s.io:certificatesigningrequests:selfnodeclient：
```yaml
# 批复 "system:nodes" 组的 CSR 续约请求
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: auto-approve-renewals-for-nodes
subjects:
- kind: Group
  name: system:nodes
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: system:certificates.k8s.io:certificatesigningrequests:selfnodeclient
  apiGroup: rbac.authorization.k8s.io
```