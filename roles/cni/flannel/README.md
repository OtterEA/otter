For Kubernetes v1.16
    kube-flannel.yaml uses ClusterRole & ClusterRoleBinding of rbac.authorization.k8s.io/v1. When you use Kubernetes v1.16, you should replace rbac.authorization.k8s.io/v1 to rbac.authorization.k8s.io/v1beta1 because rbac.authorization.k8s.io/v1 had become GA from Kubernetes v1.17.

For Kubernetes <= v1.24
    As of Kubernetes v1.21, the PodSecurityPolicy API was deprecated and it will be removed in v1.25. Thus, the flannel manifest does not use PodSecurityPolicy anymore.

If you still wish to use it, you can use kube-flannel-psp.yaml instead of kube-flannel.yaml. Please note that if you use a Kubernetes version >= 1.21, you will see a deprecation warning for the PodSecurityPolicy API.