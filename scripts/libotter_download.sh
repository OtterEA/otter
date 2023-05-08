#!/bin/bash

# include libotter lib
source ./scripts/libotter_lib.sh

# include docker lib
source ./scripts/libotter_docker.sh

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

# todo: need to do it
function download_etcd_binary_file(){
    echo "1"
}

############################
# Pull image
# Argument:
#   $1 - image_location
#   $2 - image arch
#   $3 - image save to dest
# Return:
#   None
function docker_pull_save_delete_image(){
    local image_location=${1:?image_location missing}
    local image_arch=${2:?image_arch missing}
    local image_save_to_dest=${3:?image_save_to_dest missing}

    # check image exist and check arch
    logger info "$image_location $image_arch start pull"
    if docker image ls | awk -v OFS=: 'NR>1{print $1,$2}' | grep $otter_image_location &>/dev/null ; then
        if [[ $image_arch = "linux/arm64" ]]; then
            if ! docker inspect $otter_image_location | grep "arm64" &>/dev/null ; then
                # image arch not correct, so delete it avoid image none situation
                docker rmi $image_location &>/dev/null

                # pull image
                docker pull $image_location --platform $image_arch &>/dev/null \
                && logger info "$image_location $image_arch pull success" \
                || { logger error "$image_location $image_arch pull failed"; exit 1; } 
            fi
        fi
        if [[ $image_arch = "linux/amd64" ]]; then
            if ! docker inspect $otter_image_location | grep "amd64" &>/dev/null ; then
                # image arch not correct, so delete it avoid image none situation
                docker rmi $image_location &>/dev/null
                
                # pull image
                docker pull $image_location --platform $image_arch &>/dev/null \
                && logger info "$image_location $image_arch pull success" \
                || { logger error "$image_location $image_arch pull failed"; exit 1; } 
            fi
        fi
    else
        docker pull $image_location --platform $image_arch &>/dev/null \
        && logger info "$image_location $image_arch pull success" \
        || { logger error "$image_location $image_arch pull failed"; exit 1; }      
    fi

    # save image
    logger info "$image_location $image_arch start save to $image_save_to_dest"
    docker save $image_location > $image_save_to_dest &>/dev/null \
    && logger info "$image_location $image_arch save to $image_save_to_dest success" \
    || { logger error "$image_location $image_arch save to $image_save_to_dest failed"; exit 1; }

    # rmi image
    logger info "$image_location $image_arch image start delete"
    docker rmi -f $image_location &>/dev/null \
    && logger info "$image_location $image_arch image delete success" \
    || { logger error "$image_location $image_arch delete failed"; exit 1 ; }
}

function download_otter_image(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?otter_config_file missing}

    local otter_mixed_enable=$(get_config OTTER_MIXED_ENABLE $otter_config_file)
    local otter_image_location=$(get_config OTTER_IMAGE $otter_config_file)
    local os_architecture=$(arch)

    [[ $otter_mixed_enable = true ]] \
    && docker_pull_save_delete_image $otter_image_location "linux/amd64" $otter_base_dir/files/images/otter/x86_64/otter.tar \
    && docker_pull_save_delete_image $otter_image_location "linux/arm64" $otter_base_dir/files/images/otter/aarch64/otter.tar

    [[ $otter_mixed_enable == false && $os_architecture == "x86_64" ]] \
    && docker_pull_save_delete_image $otter_image_location "linux/amd64" $otter_base_dir/files/images/otter/x86_64/otter.tar 

    [[ $otter_mixed_enable == false && $os_architecture == "aarch64" ]] \
    && docker_pull_save_delete_image $otter_image_location "linux/arm64" $otter_base_dir/files/images/otter/aarch64/otter.tar
}

function download_kubernetes_image(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?otter_config_file missing}

    local k8s_version=$(get_config KUBERNETES_VERSION $otter_config_file)
    local k8s_image_repo=$(get_config KUBERNETES_IMAGE_REPO $otter_config_file)
    local os_architecture=$(arch)

    # check kubeadm command exist
    if command_exist kubeadm ; then
        # check kubeadm version,but version is not correct
        if ! kubeadm --version | grep $k8s_version &>/dev/null ; then
            logger warn "kubeadm version is $k8s_version,but os system version is not $k8s_version"
            [[ ! -f $otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz ]] \
            && { logger error "$otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz is not exist,please download resource"; exit 1; }

            [[ ! -f /tmp/otter/kubernetes ]] && { logger info "/tmp/otter/kubernetes not exist,will create it for kubeadm command"; mkdir -p /tmp/otter/kubernetes; }

            tar -zxf $otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz -C /tmp/otter/ &>/dev/null \
            && logger info "decompress $otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz to /tmp/otter/kubernetes success" \
            || { logger error "decompress $otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz to /tmp/otter/kubernetes failed"; exit 1; }

            local k8s_image_list=($(/tmp/otter/kubernetes/node/bin/kubeadm config images list 2>/dev/null | sed -r "s#(.*)/(.*)#${k8s_image_repo}/\2#g")) 
        else
            # kubeadm command exist and version correct
            local k8s_image_list=($(kubeadm config images list 2>/dev/null | sed -r "s#(.*)/(.*)#${k8s_image_repo}/\2#g"))
        fi
    else
        # kubeadm command not exist
        logger warn "kubeadm command not find, will create tmp kubeadm command"
        [[ ! -f $otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz ]] \
        && { logger error "$otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz is not exist,please download resource"; exit 1; }

        [[ ! -f /tmp/otter/kubernetes ]] && { logger info "/tmp/otter/kubernetes not exist,will create it for kubeadm command"; mkdir -p /tmp/otter/kubernetes; }

        tar -zxf $otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz -C /tmp/otter/ &>/dev/null \
        && logger info "decompress $otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz to /tmp/otter/kubernetes success" \
        || { logger error "decompress $otter_base_dir/files/bin/k8s/$os_architecture/kubernetes-v${k8s_version}.tgz to /tmp/otter/kubernetes failed"; exit 1; }

        local k8s_image_list=($(/tmp/otter/kubernetes/node/bin/kubeadm config images list 2>/dev/null | sed -r "s#(.*)/(.*)#${k8s_image_repo}/\2#g")) 
    fi
    echo ${k8s_image_list[@]}
}

#download_docker_binary_file /root/otter /root/otter/config/otter.yaml
#download_kubernetes_node_binary_file /root/otter /root/otter/config/otter.yaml
#download_cni_plugin_binary_file /root/otter /root/otter/config/otter.yaml
#download_helm_binary_file /root/otter /root/otter/config/otter.yaml
#download_k9s_binary_file /root/otter /root/otter/config/otter.yaml