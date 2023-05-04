#!/bin/bash

# include libotter lib
source ./libotter_lib.sh

# 文件名：/otter/otter/files/bin/docker/x86_64/docker-20.10.24.tgz
# https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/aarch64/docker-20.10.24.tgz
# https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/x86_64/docker-20.10.24.tgz
function download_docker_binary_file(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?config file missing}

    local otter_mixed_enable=$(get_config OTTER_MIXED_ENABLE $otter_config_file)
    local os_architecture=$(arch)

    local docker_version=$(get_config DOCKER_VERSION $otter_config_file)
    if [[ $otter_mixed_enable = true ]]; then
        download_resource \
            https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/aarch64/docker-${docker_version}.tgz \
            $otter_base_dir/files/bin/docker/aarch64/docker-${docker_version}.tgz || exit 1

        download_resource \
            https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/x86_64/docker-${docker_version}.tgz \
            $otter_base_dir/files/bin/docker/x86_64/docker-${docker_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "aarch64" ]]; then
        download_resource \
            https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/aarch64/docker-${docker_version}.tgz \
            $otter_base_dir/files/bin/docker/aarch64/docker-${docker_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "x86_64" ]]; then
        download_resource \
            https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/x86_64/docker-${docker_version}.tgz \
            $otter_base_dir/files/bin/docker/x86_64/docker-${docker_version}.tgz || exit 1
    else
        logger error "docker os architecture check failed" 
        exit 1
    fi
}
#download_docker

# 文件名称：/otter/otter/files/bin/k8s/x86_64/kubernetes-v1.20.15.tgz
# https://dl.k8s.io/v1.20.15/kubernetes-node-linux-amd64.tar.gz
# https://dl.k8s.io/v1.20.15/kubernetes-node-linux-arm64.tar.gz
function download_kubernetes_node_binary_file(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?config file missing}

    local otter_mixed_enable=$(get_config OTTER_MIXED_ENABLE $otter_config_file)
    local os_architecture=$(arch)
    local kubernetes_version=$(get_config KUBERNETES_VERSION $otter_config_file)    
    if [[ $otter_mixed_enable = true ]]; then
        download_resource \
            https://dl.k8s.io/v${kubernetes_version}/kubernetes-node-linux-arm64.tar.gz \
            $otter_base_dir/files/bin/k8s/aarch64/kubernetes-v${kubernetes_version}.tgz || exit 1

        download_resource \
            https://dl.k8s.io/v${kubernetes_version}/kubernetes-node-linux-amd64.tar.gz \
            $otter_base_dir/files/bin/k8s/x86_64/kubernetes-v${kubernetes_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "aarch64" ]]; then
        download_resource \
            https://dl.k8s.io/v${kubernetes_version}/kubernetes-node-linux-arm64.tar.gz \
            $otter_base_dir/files/bin/k8s/aarch64/kubernetes-v${kubernetes_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "x86_64" ]]; then
        download_resource \
            https://dl.k8s.io/v${kubernetes_version}/kubernetes-node-linux-amd64.tar.gz \
            $otter_base_dir/files/bin/k8s/x86_64/kubernetes-v${kubernetes_version}.tgz || exit 1
    else
        logger error "kubernetes os architecture check failed"
        exit 1
    fi
}

# cni 二进制命令下载地址(1.1.1|1.2.0)
# 项目地址：https://github.com/containernetworking/plugins/releases
# 文件名称：/otter/otter/files/bin/cni-plugin/x86_64/cni-plugin-v1.1.1.tgz
# https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz 
# https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-arm64-v1.1.1.tgz
function download_cni_plugin_binary_file(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?config file missing}

    local otter_mixed_enable=$(get_config OTTER_MIXED_ENABLE $otter_config_file)
    local os_architecture=$(arch)
    local cni_plugin_version=$(get_config CNI_PLUGIN_VERSION $otter_config_file)
    if [[ $otter_mixed_enable = true ]]; then
        download_resource \
            https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/v${cni_plugin_version}/cni-plugins-linux-arm64-v${cni_plugin_version}.tgz \
            $otter_base_dir/files/bin/cni-plugin/aarch64/cni-plugin-v${cni_plugin_version}.tgz || exit 1

        download_resource \
            https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/v${cni_plugin_version}/cni-plugins-linux-amd64-v${cni_plugin_version}.tgz \
            $otter_base_dir/files/bin/cni-plugin/x86_64/cni-plugin-v${cni_plugin_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "aarch64" ]]; then
        download_resource \
            https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/v${cni_plugin_version}/cni-plugins-linux-arm64-v${cni_plugin_version}.tgz \
            $otter_base_dir/files/bin/cni-plugin/aarch64/cni-plugin-v${cni_plugin_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "x86_64" ]]; then
        download_resource \
            https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/v${cni_plugin_version}/cni-plugins-linux-amd64-v${cni_plugin_version}.tgz \
            $otter_base_dir/files/bin/cni-plugin/x86_64/cni-plugin-v${cni_plugin_version}.tgz || exit 1
    else
        logger error "cni plugin os architecture check failed"
        exit 1
    fi
}

# k9s 下载链接：https://github.com/derailed/k9s/releases
# 文件名称：/otter/otter/files/bin/k9s/x86_64/k9s-v0.27.3.tgz
# https://ghproxy.com/https://github.com/derailed/k9s/releases/download/v0.27.3/k9s_Linux_amd64.tar.gz 
# https://ghproxy.com/https://github.com/derailed/k9s/releases/download/v0.27.3/k9s_Linux_arm64.tar.gz
function download_k9s_binary_file(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?config file missing}

    local otter_mixed_enable=$(get_config OTTER_MIXED_ENABLE $otter_config_file)
    local os_architecture=$(arch)
    local k9s_version=$(get_config K9S_VERSION $otter_config_file)
    if [[ $otter_mixed_enable = true ]]; then
        download_resource \
            https://ghproxy.com/https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_Linux_arm64.tar.gz \
            $otter_base_dir/files/bin/k9s/aarch64/k9s-v${k9s_version}.tgz || exit 1

        download_resource \
            https://ghproxy.com/https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_Linux_amd64.tar.gz \
            $otter_base_dir/files/bin/k9s/x86_64/k9s-v${k9s_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "aarch64" ]]; then
        download_resource \
            https://ghproxy.com/https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_Linux_arm64.tar.gz \
            $otter_base_dir/files/bin/k9s/aarch64/k9s-v${k9s_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "x86_64" ]]; then
        download_resource \
            https://ghproxy.com/https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_Linux_amd64.tar.gz \
            $otter_base_dir/files/bin/k9s/x86_64/k9s-v${k9s_version}.tgz || exit 1
    else
        logger error "helm os architecture check failed"
        exit 1
    fi
}

# helm3 下载链接: https://github.com/helm/helm/releases
# 文件名称: /otter/otter/files/bin/helm/x86_64/helm-v3.11.3.tgz
# https://mirrors.huaweicloud.com/helm/v3.11.3/helm-v3.11.3-linux-amd64.tar.gz
# https://mirrors.huaweicloud.com/helm/v3.11.3/helm-v3.11.3-linux-arm64.tar.gz
function download_helm_binary_file(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?config file missing}

    local otter_mixed_enable=$(get_config OTTER_MIXED_ENABLE $otter_config_file)
    local os_architecture=$(arch)
    local helm_version=$(get_config HELM_VERSION $otter_config_file)
    if [[ $otter_mixed_enable = true ]]; then
        download_resource \
            https://mirrors.huaweicloud.com/helm/v${helm_version}/helm-v${helm_version}-linux-arm64.tar.gz \
            $otter_base_dir/files/bin/helm/aarch64/helm-v${helm_version}.tgz || exit 1

        download_resource \
            https://mirrors.huaweicloud.com/helm/v${helm_version}/helm-v${helm_version}-linux-amd64.tar.gz \
            $otter_base_dir/files/bin/helm/x86_64/helm-v${helm_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "aarch64" ]]; then
        download_resource \
            https://mirrors.huaweicloud.com/helm/v${helm_version}/helm-v${helm_version}-linux-arm64.tar.gz \
            $otter_base_dir/files/bin/helm/aarch64/helm-v${helm_version}.tgz || exit 1
    elif [[ $otter_mixed_enable = false && $os_architecture = "x86_64" ]]; then
        download_resource \
            https://mirrors.huaweicloud.com/helm/v${helm_version}/helm-v${helm_version}-linux-amd64.tar.gz \
            $otter_base_dir/files/bin/helm/x86_64/helm-v${helm_version}.tgz || exit 1
    else
        logger error "helm os architecture check failed"
        exit 1
    fi
}

download_docker_binary_file /root/otter /root/otter/config/otter.yaml
#download_kubernetes_node_binary_file /root/otter /root/otter/config/otter.yaml
#download_cni_plugin_binary_file /root/otter /root/otter/config/otter.yaml
#download_helm_binary_file /root/otter /root/otter/config/otter.yaml
#download_k9s_binary_file /root/otter /root/otter/config/otter.yaml