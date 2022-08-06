#!/bin/bash

# 生成 EncryptionConfig 所需的加密 key
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# 最好使用当前未用的网段来定义服务网段和Pod网段

# 服务网段，部署前路由不可达，部署后集群内路由可达(kube-proxy 和 ipvs 保证)
export SERVICE_CIDR="10.254.0.0/16"

# Pod 网段，建议 /16 段地址，部署前路由不可达，部署后集群内路由可达(flanneld 保证)
export CLUSTER_CIDR="172.30.0.0/16"

# 服务端口范围 (NodePort Range)
export NODE_PORT_RANGE="0-65535"

# 集群各机器 ETCD_IP 数组
export ETCD_IPS=(192.168.61.11 192.168.61.12 192.168.61.13)  #把IP替换成自己所使用的主机IP即可，可加多个

# 集群各机器 MASTER_IP 数组
export MASTER_IPS=(192.168.61.11 192.168.61.12 192.168.61.13)  #把IP替换成自己所使用的主机IP即可，可加多个

# 集群各机器 NODE_IP 数组
export NODE_IPS=(192.168.61.11 192.168.61.12 192.168.61.13 192.168.61.14)  #把IP替换成自己所使用的主机IP即可，可加多个

# 集群各 IP 对应的 主机名数组
export NODE_NAMES=(kube-master1 kube-master2 kube-master3 kube-node4)    #如果主机有多个，可酌情添加

# kube-apiserver 的 VIP（HA 组件 keepalived 发布的 IP）
export MASTER_VIP=192.168.61.100  #集群的虚拟IP

# kube-apiserver VIP 地址（HA 组件 haproxy 监听 8443 端口）
export KUBE_APISERVER="https://${MASTER_VIP}:8443"

# HA 节点，配置 VIP 的网络接口名称
export VIP_IF="ens33"

# etcd 集群服务地址列表
export ETCD_ENDPOINTS="https://192.168.61.11:2379,https://192.168.61.12:2379,https://192.168.61.13:2379"  #把IP替换成自己所使用的主机IP即可，可加多个

# etcd 集群间通信的 IP 和端口
export ETCD_NODES="kube-master1=https://192.168.61.11:2380,kube-master2=https://192.168.61.12:2380,kube-master3=https://192.168.61.13:2380" #把IP替换成自己所使用的主机IP即可，可加多个

# flanneld 网络配置前缀
export FLANNEL_ETCD_PREFIX="/kubernetes/network"

# kubernetes 服务 IP (一般是 SERVICE_CIDR 中第一个IP)
export CLUSTER_KUBERNETES_SVC_IP="10.254.0.1"

# 集群 DNS 服务 IP (从 SERVICE_CIDR 中预分配)
export CLUSTER_DNS_SVC_IP="10.254.0.2"

# 集群 DNS 域名
export CLUSTER_DNS_DOMAIN="cluster.local."

# 将二进制目录 /opt/k8s/bin 加到 PATH 中
export PATH=/opt/k8s/bin:$PATH
