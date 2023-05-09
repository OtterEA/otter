#!/bin/bash
########################################################
# author: qujiayu98@163.com
########################################################

# include otter lib
source ./scripts/libotter_lib.sh

######################################
# generate ssh key if not exist
# Argument:
#   None
# Return:
#   None
function generateSSHKey(){
    if [[ ! -f /root/.ssh/id_rsa || ! -f /root/.ssh/id_rsa.pub ]]; then
    	logger warn "ssh key not exist, generate it"
		#ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa  <<< $'\ny' >/dev/null 2>&1 && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
		ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1 && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
        if [ $? -ne 0 ]; then
            logger error "ssh key generate failed"
            exit 1
        else
            logger info "ssh key generate success"
        fi
    # already ssh key exist
    elif [[ -f /root/.ssh/id_rsa && -f /root/.ssh/id_rsa.pub && ! -f /root/.ssh/authorized_keys ]]; then
        logger info "generate /root/.ssh/authorized_keys"
        cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
    else
        logger info "ssh key has already generate,skip it"
    fi
}

# todo: need to check whether correct
#####################################
# copy node ssh key to node, all node must use same ssh port, same node password
# Argument:
#   None
# Return:
#   None
function scpSSHKeyToNode(){
    local node_ip=${1:?node ip missing}
    local node_ssh_port=${2:?node ssh port missing}
    local node_ssh_password=${3:?node ssh password missing}

    # validate ipv4
    if ! validate_ipv4 $node_ip ; then
        logger error "$node_ip not correct"
        exit 1
    fi

    docker exec otter sshpass -p $node_ssh_password ssh -p $node_ssh_port \
        -o ConnectTimeout=1 -o ConnectionAttempts=3 -o StrictHostKeyChecking=no -o 'UserKnownHostsFile /dev/null' root@$node_ip "mkdir -p /root/.ssh" &>/dev/null && \
    docker exec otter sshpass -p $node_ssh_password scp -P $node_ssh_port \
        -o ConnectTimeout=1 -o ConnectionAttempts=3 -o StrictHostKeyChecking=no -o 'UserKnownHostsFile /dev/null' /root/.ssh/authorized_keys root@$node_ip:/root/.ssh/authorized_keys &>/dev/null && \
    logger info "$node_ip ssh key scp success" || { logger error "$node_ip ssh key scp failed"; exit 1; }
}