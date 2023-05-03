## otter

`otter`致力于提供快速部署高可用K8S集群的工具，基于Kubeadm提供自定义K8S部署参数和Ansible实现自动化交付；

1. 集群特性：Master高可用、离线部署、多架构支持(arm64/amd64)、多架构支持(arm64/amd64)、多操作系统、多操作系统/多架构混部
2. 集群版本：Kubernetes v1.22.x，v1.22.x，v1.25.x
3. 操作系统：CentOS/RedHat/7/8/Rocky9
4. CRI：containerd、Docker
5. CNI：flannel
6. 配置文件支持高度自定义

## 当前启动测试命令
ansible-playbook playbooks/01.init.yaml -e "@./config/otter.yaml"

## 当前任务



## otter版本列表



## 沟通交流





## 贡献&致谢

