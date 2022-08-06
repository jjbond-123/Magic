#!/bin/bash
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    ssh root@${node_ip}   "/opt/k8s/bin/kubectl delete clusterrolebindings kube-apiserver:kubelet-apis"
    ssh root@${node_ip}   "/opt/k8s/bin/kubectl delete clusterrolebindings kubelet-bootstrap"
    ssh root@${node_ip}   "systemctl stop etcd"
    ssh root@${node_ip}   "systemctl stop kube-apiserver"
    ssh root@${node_ip}   "systemctl stop kube-controller-manager"
    ssh root@${node_ip}   "systemctl stop kube-scheduler"
    ssh root@${node_ip}   "systemctl stop haproxy"
    ssh root@${node_ip}   "systemctl stop flanneld"
    ssh root@${node_ip}   "systemctl stop keeplived"
    ssh root@${node_ip}   "systemctl stop docker"
    ssh root@${node_ip}   "systemctl stop kubelet"
    ssh root@${node_ip}   "systemctl stop kube-proxy"
done

