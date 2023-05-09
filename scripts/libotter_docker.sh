#!/bin/bash
################################################################
# author: qujiayu98@163.com
################################################################

# include otter lib
source ./scripts/libotter_lib.sh

#############################
# Generate Docker Configuration
# Argument:
#   $1 - otter.yaml
#   $2 - harbor.yaml
# Return:
#   None
function generate_docker_configuration(){
    # get docker config
    local otter_config_file=${1:?otter config file missing}
    local otter_harbor_config_file=${2:?harbor config file missing}

    local docker_driver=$(get_config DOCKER_DRIVER $otter_config_file)
    local docker_bip=$(get_config DOCKER_BIP $otter_config_file)
    local docker_data_dir=$(get_config DOCKER_ROOT_DATA $otter_config_file)
    local docker_remote_api_enable=$(get_config DOCKER_REMOTE_API_ENABLE $otter_config_file)

    local harbor_ip=$(get_config HARBOR_DOMAIN $otter_harbor_config_file)
    local harbor_domain=$(get_config HARBOR_IP $otter_harbor_config_file)
    local harbor_enable=$(get_config HARBOR_ENABLE $otter_harbor_config_file)

    mkdir -p /etc/docker
cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP \$MAINPID
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
# Uncomment TasksMax if your systemd version supports it.
# Only systemd 226 and above support this version.
#TasksMax=infinity
TimeoutStartSec=0
# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes
# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/docker/daemon.json << EOF
{
  "data-root": "${docker_data_dir}",
  "exec-opts": ["native.cgroupdriver=${docker_driver}"],
  "registry-mirrors": ["https://bxsfpjcb.mirror.aliyuncs.com"],
  "max-concurrent-downloads": 10,
  "max-concurrent-downloads": 3,
  "max-concurrent-uploads": 5,
  "max-download-attempts": 5,
  "experimental": true,
  "bip": "${docker_bip}",
  "hosts": ["tcp://0.0.0.0:2376", "unix:///var/run/docker.sock"],
  "insecure-registries": ["${harbor_ip}:443","${harbor_domain}"],
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
  }
}
EOF
    [[ $docker_remote_api_enable = false || $docker_remote_api_enable = "" ]] && sed -Ei "#tcp://0.0.0.0:2376#d" /etc/docker/daemon.json
    [[ $harbor_enable = true && $harbor_ip != "" && $harbor_domain == "" ]] && sed -Ei "s#.*insecure-registries.*#  "insecure-registries": [\"${harbor_ip}:443\"],#g" /etc/docker/daemon.json
    [[ $harbor_enable = true && $harbor_ip = "" && $harbor_domain != "" ]] && sed -Ei "s#.*insecure-registries.*#  "insecure-registries": [\"${harbor_domain}\"],#g" /etc/docker/daemon.json
    [[ $harbor_enable = false ]] && sed -Ei "#insecure-registries.*#d" /etc/docker/daemon.json
    logger info "docker configuration generate sucess"
}

#########################################
# decompress docker binary_file
# Argument:
#   None
# Return:
#   None
function decompress_docker_binary_file(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?otter config file missing}

    local docker_version=$(get_config DOCKER_VERSION $otter_config_file)
    local os_architecture=$(arch)

    [[ ! -f "$otter_base_dir/files/bin/docker/$os_architecture/docker-${docker_version}.tgz" ]] && { logger error "$docker_binary_file doesn't exist"; exit 1; }

    tar -zxf $otter_base_dir/files/bin/docker/$os_architecture/docker-${docker_version}.tgz --strip-components=1 -C /usr/bin/ &>/dev/null \
    && logger info "$otter_base_dir/files/bin/docker/$os_architecture/docker-${docker_version}.tgz decompress success" \
    || { logger error "$$otter_base_dir/files/bin/docker/$os_architecture/docker-${docker_version}.tgz decompress failed"; exit 1; }
}

function is_runing_docker(){
    echo 1
}

#################################
# delete container
# Argument:
#   $1 - container name
# Return:
#   None
function delete_container_docker(){
    local container_name=${1:?container name missing}
    docker ps -a | grep $container_name | awk '{print $1}' | xargs docker rm -f &>/dev/null
    #logger info "$container_name delete success"
}

#############################
# start docker service
# Argument:
#   None
# Return:
#   None
function install_with_start_docker(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?otter config file missing}
    local otter_harbor_config_file=${3:?otter harbor config file missing}
    local docker_version=$(get_config DOCKER_VERSION $otter_config_file)

    function start_docker(){
        local force=${1:?force missing}
        if [[ $force = true ]]; then
            { systemctl daemon-reload && systemctl start docker --now; } && logger info "docker start success" || { logger error "docker start failed"; exit 1; }
        else
            if ! systemctl is-active docker &>/dev/null ; then
                { systemctl daemon-reload && systemctl start docker --now; } && logger info "docker start success" || { logger error "docker start failed"; exit 1; }
            else
                logger info "docker has already started"
            fi
        fi
    }

    # check docker version if has already exist,if version not right install it
    if command_exist docker ; then
        if ! docker version | grep -q $docker_version ; then
            decompress_docker_binary_file $otter_base_dir $otter_config_file
            generate_docker_configuration $otter_config_file $otter_harbor_config_file
            start_docker true
            return
        fi
    else
            decompress_docker_binary_file $otter_base_dir $otter_config_file
            generate_docker_configuration $otter_config_file $otter_harbor_config_file
            start_docker true
            return
    fi
    start_docker false
}


###############################
# start otter container
# Argument:
#   $1 - otter_base_dir
#   $2 - otter_config_file
# Return:
#   None
function start_otter_container(){
    local otter_base_dir=${1:?otter_base_dir missing}
    local otter_config_file=${2:?otter_config_file missing}
    local otter_harbor_config_file=${3:?otter harbor config file missing}

    local otter_image_location=$(get_config OTTER_IMAGE $otter_config_file)
    local os_architecture=$(arch)

    # install or start docker
    install_with_start_docker $otter_base_dir $otter_config_file $otter_harbor_config_file

    # rm otter running container
    #docker ps -a | grep otter | awk '{ print $1}' | xargs docker rm &>/dev/null && logger info "otter running container delete success"

    # check image and load it
    if docker image ls | awk -v OFS=: 'NR>1{print $1,$2}' | grep $otter_image_location &>/dev/null ; then
        if [[ $os_architecture = "aarch64" ]]; then
            if docker inspect $otter_image_location | grep "arm64" &>/dev/null ; then
                logger info "$otter_image_location $os_architecture has already exist"
            else
                docker rmi $otter_image_location &>/dev/null
                [[ ! -f $otter_base_dir/files/images/otter/$os_architecture/otter.tar ]] \
                && { logger error "$otter_base_dir/files/images/otter/$os_architecture/otter.tar not exist,please run otter_download"; exit 1 ; }

                docker load -i $otter_base_dir/files/images/otter/$os_architecture/otter.tar &>/dev/null \
                || { logger error "$otter_base_dir/files/images/otter/$os_architecture/otter.tar load failed"; exit 1; }
            fi
        fi
        if [[ $os_architecture = "x86_64" ]]; then
            if docker inspect $otter_image_location | grep "amd64" &>/dev/null ; then
                logger info "$otter_image_location $os_architecture has already exist"
            else
                docker rmi $otter_image_location &>/dev/null
                [[ ! -f $otter_base_dir/files/images/otter/$os_architecture/otter.tar ]] \
                && { logger error "$otter_base_dir/files/images/otter/$os_architecture/otter.tar not exist,please run otter_download"; exit 1 ; }

                docker load -i $otter_base_dir/files/images/otter/$os_architecture/otter.tar &>/dev/null \
                || { logger error "$otter_base_dir/files/images/otter/$os_architecture/otter.tar load failed"; exit 1; }
            fi
        fi
    else
        [[ ! -f $otter_base_dir/files/images/otter/$os_architecture/otter.tar ]] \
        && { logger error "$otter_base_dir/files/images/otter/$os_architecture/otter.tar not exist,please run otter_download"; exit 1 ; }

        docker load -i $otter_base_dir/files/images/otter/$os_architecture/otter.tar &>/dev/null \
        || { logger error "$otter_base_dir/files/images/otter/$os_architecture/otter.tar load failed"; exit 1; }
    fi

    # run otter container
    docker ps -a | grep otter | grep -i Exited | awk '{ print $1}' | xargs docker rm &>/dev/null
    if ! docker ps | grep otter &>/dev/null ; then
        if docker run --name otter --network=host \
            -v $otter_base_dir:$otter_base_dir \
            -v /root/.ssh:/root/.ssh \
            -v /etc/docker:/etc/docker \
            $otter_image_location & >/dev/null ; 
        then
            logger info "$otter_image_location start success"
        else
            logger error "$otter_image_location start failed"
        fi
    fi
}

#start_otter_container /root/otter /root/otter/config/otter.yaml