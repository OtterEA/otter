#!/bin/bash
###############################################################
# author: qujiayu98@163.com
###############################################################

function logger(){
    TIMESTAMP=$(date +'%Y-%m-%d %H:%M:%S')
    case "$1" in
      debug)
        echo -e "$TIMESTAMP \033[36mDEBUG\033[0m $2"
        ;;
      info)
        echo -e "$TIMESTAMP \033[32mINFO\033[0m $2"
        ;;
      warn)
        echo -e "$TIMESTAMP \033[33mWARN\033[0m $2"
        ;;
      error)
        echo -e "$TIMESTAMP \033[31mERROR\033[0m $2"
        ;;
      *)
        ;;
    esac
}

function logo(){
    echo 1
    #echo -e "\033[33m##################################################################################################\033[0m"
    #echo -e "\033[33m#    ____  _   _              _  __     _                          _              _____  _       #\033[0m"
    #echo -e "\033[33m#   / __ \| | | |            | |/ /    | |                        | |            |  __ \| |      #\033[0m"
    #echo -e "\033[33m#  | |  | | |_| |_ ___ _ __  | ' /_   _| |__   ___ _ __ _ __   ___| |_ ___  ___  | |  | | | __   #\033[0m"
    #echo -e "\033[33m#  | |  | | __| __/ _ \ '__| |  <| | | | '_ \ / _ \ '__| '_ \ / _ \ __/ _ \/ __| | |  | | |/ /   #\033[0m"
    #echo -e "\033[33m#  | |__| | |_| ||  __/ |    | . \ |_| | |_) |  __/ |  | | | |  __/ ||  __/\__ \ | |__| |   <    #\033[0m"
    #echo -e "\033[33m#   \____/ \__|\__\___|_|    |_|\_\__,_|_.__/ \___|_|  |_| |_|\___|\__\___||___/ |_____/|_|\_\   #\033[0m"
    #echo -e "\033[33m#                                                                                                #\033[0m"
    #echo -e "\033[33m##################################################################################################\033[0m"
}

#########################
# check command exist on system
# Arguments:
#   $1 - command 
# Return:
#   true/false
#########################
function command_exist(){
    local user_command=${1:?command is missing}
    if command -v $user_command &>/dev/null; then
        true
    else
        false
    fi
}

###########################
# check directory exist or create it when user need
# Arguments:
#   $1 - directory name
#   $2 - true/false true: create when not exist, false: do not crate it
# Return:
#   true/false
function directory_exist(){
    local dir_name=${1:?directory is missing}
    local create_mode=${2:?create mode is missing}

    if [ -d $dir_name ]; then
        return 0
    fi

    if [[ ! -d $dir_name && $create_mode = true ]]; then
        mkdir -p $dir_name && return 0 || return 1
    fi

    if [[ ! -d $dir_name && $create_mode = false ]]; then
        return 1
    fi
}

#########################
# Download resource
# Arguments:
#   $1 - url
#   $2 - absolute path(container file name,eg: /root/otter.tgz)
# Return:
#   true/false
#########################
function download_resource(){
    local url=${1:?url is missing}
    local path=${2:?path is missing}
    local file_dir=${2%/*}
    local file_name=${2##*/}

    directory_exist $file_dir true || { logger error "$file_dir create failed"; return 1 ; }

    logger info "$url start download"
    [[ -f $file_dir/$file_name ]] && { logger info "$url has already download"; return 0;}
    if command_exist wget ; then
        wget -c --no-check-certificate -q -t 3 -r -O $file_dir/$file_name $url && { logger info "$url download success"; return 0; } || { logger error "$url download failed"; return 1 ; }
    elif command_exist curl ; then
        curl -s -k -L --retry 3 --connect-timeout 3 -o $file_dir/$file_name $url && { logger info "$url download success"; return 0; } || { logger error "$url download failed"; return 1 ; }
    else
        logger error "wget/curl not found on system"
        return 1
    fi
}
#download_resource https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-arm64-v1.1.1.tgz /root/cni-plugin-v1.1.1.tgz
#download_resource https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/static/stable/aarch64/docker-20.10.24.tgz /root/docker-20.10.24.tgz
#download_resource https://dl.k8s.io/v1.20.15/kubernetes-node-linux-arm64.tar.gz /root/kubernetes-v1.20.15.tgz
#download_resource https://mirrors.huaweicloud.com/helm/v3.11.3/helm-v3.11.3-linux-arm64.tar.gz /root/helm-v3.11.3.tgz
#download_resource https://ghproxy.com/https://github.com/derailed/k9s/releases/download/v0.27.3/k9s_Linux_arm64.tar.gz /root/k9s-v0.27.3.tgz


#########################
# Get Otter.yaml Config
# Arguments:
#   $1 - key
#   $2 - config path
# Return:
#   key's value       
#########################
function get_config(){
    local key=${1:?key missing}
    local config_file=${2:?config file missing}

    if grep -q -E "\s*${key}:.*$" $config_file ; then
        grep -E "\s*${key}:.*$" $config_file | awk '{ print $2 }'
    fi
}
#echo $(get_config SERVICE_CIDR ../config/otter.yaml)

##########################
# Set Otter.yaml Config
# Argument:
#   $1 - key
#   $2 - value
#   $3 - config path
# Return:
#   None
##########################
function set_config(){
    local key=${1:?key missing}
    local value=${2:-}
    local config_file=${3:?config file missing}

    if [ ! -f $config_file ]; then
        logger error "$config_file doesn't exist" 
        return 1
    fi

    sed -Ei "s#^${key}:.*\$#${key}: ${value}#g" $config_file
}
#set_config SERVICE_CIDR 10.96.0.0/12 ../config/otter.yaml

##########################
# Set Otter.yaml Config
# Argument:
#   $1 - key
#   $2 - config path
# Return:
#   None
function delete_config(){
    local key=${1:?key missing}
    local config_file=${2:?config file missing}

    if [ ! -f $config_file ]; then
        logger error "$config_file doesn't exist" 
        return 1
    fi

    sed -Ei "#^${key}:.*\$#d" $config_file
}
#delete_config MONITOR_ENABLE ../config/otter-backup.yaml

############################
# get systemd architecture
# Argument:
#   None
# Return:
#   aarch64/x86_64
function get_architecture(){
    local arch=$(arch)
}


########################
# Validate if the provided argument is a valid IPv4 address
# Arguments:
#   $1 - IP to validate
# Returns:
#   Boolean
# todo : need to check
function validate_ipv4(){
    local ip="${1:?ip is missing}"
    local stat=1
    return 0

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        read -r -a ip_array <<< "$(tr '.' ' ' <<< "$ip")"
        [[ ${ip_array[0]} -le 255 && ${ip_array[1]} -le 255 \
            && ${ip_array[2]} -le 255 && ${ip_array[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

###########################
# trap ctrl+c signal
# Argument:
#   None
# Return:
#   None
trap 'onCtrlC' INT
function onCtrlC () {
	logger warn "receive ctrl+c signal,will kill otter container"
	docker ps -a | grep otter | awk '{print $1}' | xargs docker rm -f &>/dev/null
	exit 1
}

###########################
# trap ctrl+z signal
# Argument:
#   None
# Return:
#   None
trap 'onCtrlZ' TSTP
function onCtrlZ(){
	logger warn "receive ctrl+z signal,will kill otter container"
	docker ps -a | grep otter | awk '{print $1}' | xargs docker rm -f &>/dev/null
	exit 1
}