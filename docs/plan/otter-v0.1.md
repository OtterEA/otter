## Otter-v0.1版本任务

- 当前暂时不支持离线部署，离线混部

### 操作系统适配(在线)

| Linux发行版本 | 系统架构    | 默认内核版本 | 是否完成 |
| ------------- | ----------- | ------------ | -------- |
| Centos7       | Arm64/Amd64 | N/A          | ✅        |
| Centos8       | Arm64/Amd64 | N/A          | ✅        |
| Rocky9        | Arm64/Amd64 | N/A          | ✅        |
| Rocky8        | Arm64/Amd64 | N/A          | ❌        |
| Ubuntu22.04   | Arm64/Amd64 | N/A          | ✅        |
| Ubuntu20.04   | Arm64/Amd64 | N/A          | ✅        |
| Ubuntu18.04   | Arm64/Amd64 | N/A          | ✅        |

### K8S版本适配

- 下述kubernetes版本为测试版本，`理论上<1.24.0均可以在线安装`，用户可根据实际需求更改版本
- 下述runtime版本为测试版本，用户可根据实际需求更改版本

| K8S版本   | 系统架构    | RUNTIME 类型    | RUNTIME架构 | 是否完成 |
| --------- | ----------- | --------------- | ----------- | -------- |
| v1.20.15  | Arm64/Amd64 | Docker/20.10.24 | Arm64/Amd64 | ✅        |
| v1.21.14  | Arm64/Amd64 | Docker/20.10.24 | Arm64/Amd64 | ✅        |
| v1.22.17  | Arm64/Amd64 | Docker/20.10.24 | Arm64/Amd64 | ✅        |
| v.1.23.17 | Arm64/Amd64 | Docker/20.10.24 | Arm64/Amd64 | ✅        |

### k8s架构适配

| 部署架构        | 网络模式      | 是否完成 |
| --------------- | ------------- | -------- |
| 单master/多node | iptables/ipvs | ✅        |
| 多master/多node | iptables      | ❌        |
| 多master/多node | ipvs          | ✅        |

### CNI类型适配

| CNI-PLUGIN版本 | CNI类型 | 是否完成 |
| -------------- | ------- | -------- |
| v1.1.1         | Flannel | ✅        |

### Kubernetes增强组件

| 组件名称 | 系统架构    | 是否完成 |
| -------- | ----------- | -------- |
| helm3    | Arm64/Amd64 | ✅        |
| k9s      | Arm64/Amd64 | ✅        |

### otter容器适配

| otter容器                           | 系统架构    | 是否完成 |
| ----------------------------------- | ----------- | -------- |
| jiayu98/otter:v0.1(ansible相关环境) | Arm64/Amd64 | ✅        |

### otter脚本