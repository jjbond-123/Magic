#!/bin/bash
base_dir=$(pwd)
set -e
mkdir -p /opt/k8s/bin/ && cp $base_dir/config/environment.sh /opt/k8s/bin/

-----------------
#!/bin/bash
################################################################################
## Copyright:   HUAWEI Tech. Co., Ltd.
## Filename:    preSetInstall.sh
## Description: 
## Version:     FusionInsight V100R002C60
## Created:     Friday, 11 18, 2015
################################################################################ 

################################################################################
# Function: logDef
# Description: 记录到日志文件
# Parameter:
#   input:
#   N/A
#   output:
#   N/A
# Return: 0 -- success; not 0 -- failure
# Others: 该函数是最低层日志函数，不会被外部函数直接调用
################################################################################
logDef()
{
    # 调用日志打印函数的函数名称
    local funcName="$1"
    shift

    # 打印的日志级别
    local logLevel="$1"
    shift

    # 外部调用日志打印函数时所在的行号
    local lineNO="$1"
    shift
    
    if [ -d "${g_logPath}" ] ; then
        # 打印时间、日志级别、日志内容、脚本名称、调用日志打印函数的函数、打印时的行号及脚本的进程号
        local logTime="$(date -d today +'%Y-%m-%d %H:%M:%S')"
        printf "[${logTime}] ${logLevel} $* [${g_scriptName}(${funcName}):${lineNO}]($$)\n" \
            >> "${g_logPath}/${g_logFile}" 2>&1
    fi

    return 0
}

################################################################################
# Function: log_error
# Description: 对外部提供的日志打印函数：记录EEROR级别日志到日志文件
# Parameter:
#   input:
#   N/A
#   output:
#   N/A
# Return: 0 -- success; not 0 -- failure
# Others: N/A
################################################################################
log_error()
{
    # FUNCNAME是shell的内置环境变量，是一个数组变量，其中包含了整个调用链上所有
    # 的函数名字，通过该变量取出调用该函数的函数名
    logDef "${FUNCNAME[1]}" "ERROR" "$@"
}

################################################################################
# Function: log_info
# Description: 对外部提供的日志打印函数：记录INFO级别日志到日志文件
# Parameter:
#   input:
#   N/A
#   output:
#   N/A
# Return: 0 -- success; not 0 -- failure
# Others: N/A
################################################################################
log_info()
{
    # FUNCNAME是shell的内置环境变量，是一个数组变量，其中包含了整个调用链上所有
    # 的函数名字，通过该变量取出调用该函数的函数名
    logDef "${FUNCNAME[1]}" "INFO" "$@"
}

################################################################################
# Function: showLog
# Description: 记录日志到文件并显示到屏幕
# Parameter:
#   input:
#   N/A
#   output:
#   N/A
# Return: 0 -- success; not 0 -- failure
# Others: 该函数是低层日志函数，不会被外部函数直接调用
################################################################################
showLog()
{
    # 把日志打印到日志文件。FUNCNAME是shell的内置环境变量，是一个数组变量，其中
    # 包含了整个调用链上所有的函数名字，通过该变量取出调用该函数的函数名
    logDef "${FUNCNAME[2]}" "$@"

    # 如果是EEROR日志级别，则显示在屏幕上要带前缀：ERROR
    if [ "$1" = "ERROR" ]; then
        echo -e "ERROR:$3"
    elif [ "$1" = "WARN" ];then
        echo -e "WARN: $3"
    else
        echo -e "$3"
    fi
}

################################################################################
# Function: showLog_error
# Description: 对外部提供的日志打印函数：记录ERROR级别日志到文件并显示到屏幕
# Parameter:
#   input:
#   N/A
#   output:
#   N/A
# Return: 0 -- success; not 0 -- failure
# Others: N/A
################################################################################
showLog_error()
{
    showLog ERROR "$@"
}

################################################################################
# Function: showLog_info
# Description: 对外部提供的日志打印函数：记录INFO级别日志到文件并显示到屏幕
# Parameter:
#   input:
#   N/A
#   output:
#   N/A
# Return: 0 -- success; not 0 -- failure
# Others: N/A
################################################################################
showLog_info()
{
    showLog INFO "$@"
}

################################################################################
# Function: syslog
# Description: Important operation must record to syslog
# Parameters  : $1 is component name ; $2 is filename ; $3 is status ; $4 is message
# Return: 0 -- success; not 0 -- failure
# Others: N/A
################################################################################
function syslog()
{
    local component=$1
    local filename=$2
    local status=$3
    local message=$4

    if [ "$3" -eq "0" ]; then
        status="success"
    else
        status="failed"
    fi

    which logger >/dev/null 2>&1
    [ "$?" -ne "0" ] && return 0;

    login_user_ip="$(who -m | sed 's/.*(//g;s/)*$//g')"
    execute_user_name="$(whoami)"
    logger -p local0.notice -i "FusionInsight;${component};[${filename}];${status};${login_user_ip};${execute_user_name};${message}"
    return 0
}
-----------------


-----------------
#!/bin/bash
################################################################################
## Copyright:   DGHW Tech. Co., Ltd.
## Filename:    "${service}".sh
## Description:
## Version:     MRS820
## Created:     Friday, 11 04, 2022
################################################################################
declare g_curPath=""                      # 当前脚本所在的目录
declare g_logPath="/var/log/services/" # 日志路径
declare g_logFile="${service}".log            # 日志文件
declare install_path="${location}"


read -t 60 -p "请输入需要安装的服务名{例如:mysql。如果不输入直接回车,默认安装服务名为test}:" service
read -t 60 -p "请输入需要安装的服务目录位置{例如：/usr/local/。如果不输入直接回车,默认安装在/usr/local/}:" location

################################################################################
# Function: get_cur_path
# Description: 获取脚本所在的目录及脚本名
# Parameter:
#   input:
#   N/A
#   output:
#   N/A
# Return: 0 -- success; not 0 -- failure
# Others: N/A
################################################################################
init_path()
{
    cd "$(dirname "${BASH_SOURCE-$0}")"
    g_curPath="${PWD}"
    g_scriptName="$(basename "${BASH_SOURCE-$0}")"
    g_setup_tool_package_home="$(dirname "${g_curPath}")"
    cd - >/dev/null
}

################################################################################
 # Function: init_log
 # Description: 初始化服务日志文件
 # Parameter:
 #   input:
 #   N/A
 #   output:
 #   N/A
 # Return: 0 -- success; not 0 -- failure
 # Others: N/A
 ################################################################################
main()
{

init_log()
{
#创建服务文件夹日志目录
if [ -d "${g_logPath}" ];then
    log_info $INFO  "The log directory exists." >> "${g_logPath}"/all.log
else
    mkdir "${g_logPath}"
    log_info $INFO  "The log directory is created successfully." >> "${g_logPath}"/all.log
fi

#判断输入的值是否为空 
if [ ! -n "$service" ];then
  service=test
  if [  -f "${service}".log ];then
      log_info $INFO "The log file exists." >> "${g_logPath}"/all.log
  else 
      touch "${g_logPath}"/"${service}".log
      log_info $INFO "The log directory is created successfully." >> "${g_logPath}"/all.log
  fi
else  
  touch   "${g_logPath}"/"${service}".log
fi

#判断输入的值是否为空 
if [ ! -n "$location" ];then
  location="/usr/local"
  log_info $INFO "The installation position is not entered." >> "${g_logPath}"/all.log
else  
  log_info $INFO "Installation position input" >> "${g_logPath}"/all.log
fi
}

################################################################################
 # Function: package
 # Description: 文件进行解压
 # Parameter:
 #   input:
 #   N/A
 #   output:
 #   N/A
 # Return: 0 -- success; not 0 -- failure
 # Others: N/A
 ################################################################################
#mysql下载位置：https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.28-linux-glibc2.12-x86_64.tar.gz
#这里的实例是5.7.28版本
SERVICE_GZ=`ls /root/ | grep $service`
if [ $? -eq 0 ];then
   log_info $INFO "The installation package exists."
   mv /root/"${SERVICE_GZ}"  "${g_curPath}"/Packages
else 
   log_error $INFO "The installation package does not exist. Check whether the package is stored in the /root directory."
   exit 0
fi

tar -xvzf "${g_curPath}"/Packages/"${SERVICE_GZ}" -C "${location}"
if [ -f "${location}"/mysql* ];then
   log_info $INFO "The MySQL package is decompressed successfully."
   mv "${location}"/mysql*  "${location}"/mysql
else 
   log_error $INFO "Failed to decompress the MySQL package. Manually check the package."
   exit 0
fi

################################################################################
 # Function: package
 # Description: mysql安装
 # Parameter:
 #   input:
 #   N/A
 #   output:
 #   N/A
 # Return: 0 -- success; not 0 -- failure
 # Others: N/A
 ################################################################################
#创建mysql用户
groupadd mysql
useradd -r -g mysql mysql
#创建mysql存储目录
mkdir "${location}"/mysql/data/
#创建mysql的日志目录
mkdir "${location}"/mysql/log/
chown -R mysql:mysql "${location}"/mysql/
#删除原先的mysql的配置文件
rm -rf /etc/my.cnf
cat > /etc/my.cnf <<EOF
[mysqld]
bind-address=0.0.0.0
port=3306
user=mysql
basedir="${location}"/mysql
datadir="${location}"/mysql/data/
socket=/tmp/mysql.sock
log-error="${location}"/mysql/log/mysql.err
pid-file="${location}"/mysql/mysql.pid
#character config
character_set_server=utf8mb4
symbolic-links=0
explicit_defaults_for_timestamp=true
EOF
chmod  644 /etc/my.cnf

#初始化mysql
"${location}"/mysql/bin/mysqld --defaults-file=/etc/my.cnf --basedir="${location}"/mysql/ --datadir="${location}"/mysql/data/ --user=mysql --initialize

}



# ---------------------------------------------------------------------------- #
#                        获取当前路径,初始化日志文件                           #
# ---------------------------------------------------------------------------- #
cd "${g_curPath}"
init_log
get_cur_path
# ---------------------------------------------------------------------------- #
#                                   导入头文件                                 #
# ---------------------------------------------------------------------------- #
. "${g_curPath}/log/log.sh" || { echo "[${g_scriptName}:${LINENO}] ERROR: Failed to load ${g_curPath}/log/log.sh."; exit 1;}


# ---------------------------------------------------------------------------- #
#                                 脚本开始运行                                 #
# ---------------------------------------------------------------------------- #
main "$@"
ret=$?





-----------------
################################################################################
# Function: get_cur_path
# Description: 获取脚本所在的目录及脚本名
# Parameter:
#   input:
#   N/A
#   output:
#   N/A
# Return: 0 -- success; not 0 -- failure
# Others: N/A
################################################################################
function get_cur_path()
{
    cd "$(dirname "${BASH_SOURCE-$0}")"
    g_curPath="${PWD}"
    g_scriptName="$(basename "${BASH_SOURCE-$0}")"
    cd - >/dev/null
}

################################################################################
# Print the log to the log ${g_logFile}
################################################################################
logDef()
{
    local funcName="$1"; shift
    local logLevel="$1"; shift
    local lineNO="$1"; shift

    #打印时间、日志级别、日志内容、脚本名称、调用日志打印函数的函数、打印时的行号及脚本的进程号
    local logTime="$(date -d today +'%Y-%m-%d %H:%M:%S')"
    printf "[${logTime}] ${logLevel} $* [${g_scriptName}(${funcName}):${lineNO}]($$)\n" \
        >> "${g_logFile}" 2>&1
}

log_error()
{
    logDef "${FUNCNAME[1]}" "ERROR" "$@"
}

log_info()
{
    logDef "${FUNCNAME[1]}" "INFO" "$@"
}

echo "################  批量分发公钥-免交互方式  ####################"
yum install -y sshpass
# create key pair
base_dir=$(pwd)
#这里取出来的是所有机器IP地址列表，如果所命名不一样的话，需要自己重新取
IP=`cat $base_dir/config/Kcsh/hosts | grep kube | awk  -F  " " '{print $1}'`
export SSHPASS=123456      #设置为机器密码，这里建议所有机器密码保持一致
rm -f /root/.ssh/id_rsa
ssh-keygen -f /root/.ssh/id_rsa -P ''
for HOST in $IP;
do
     sshpass -e ssh-copy-id -o StrictHostKeyChecking=no $HOST
done



source /opt/k8s/bin/environment.sh 
#
##set color##
echoRed() { echo $'\e[0;31m'"$1"$'\e[0m'; }
echoGreen() { echo $'\e[0;32m'"$1"$'\e[0m'; }
echoYellow() { echo $'\e[0;33m'"$1"$'\e[0m'; }
##set color##
#

Kcsh(){

source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}"
    ssh root@${node_ip} "yum install -y epel-release conntrack ipvsadm ipset sysstat curl iptables libseccomp keepalived haproxy"
    ssh root@${node_ip} "systemctl stop firewalld && systemctl disable firewalld"
    ssh root@${node_ip} "iptables -F && sudo iptables -X && sudo iptables -F -t nat && sudo iptables -X -t nat && iptables -P FORWARD ACCEPT"
    ssh root@${node_ip} "swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab"
    scp $base_dir/config/Kcsh/hosts root@${node_ip}:/etc/hosts
    scp $base_dir/config/Kcsh/kubernetes.conf root@${node_ip}:/etc/sysctl.d/kubernetes.conf
    ssh root@${node_ip} "modprobe br_netfilter && modprobe ip_vs"
    ssh root@${node_ip} "sysctl -p /etc/sysctl.d/kubernetes.conf"
   # ssh root@${node_ip} 'yum -y install wget ntpdate lrzsz curl rsync && ntpdate -u cn.pool.ntp.org && echo "* * * * * /usr/sbin/ntpdate -u cn.pool.ntp.org &> /dev/null" > /var/spool/cron/root'
    ssh root@${node_ip} 'mkdir -p /opt/k8s/bin && mkdir -p /etc/kubernetes/cert'
    ssh root@${node_ip} 'mkdir -p /etc/etcd/cert && mkdir -p /var/lib/etcd'
    scp $base_dir/config/environment.sh  root@${node_ip}:/opt/k8s/bin/
    ssh root@${node_ip} "chmod +x /opt/k8s/bin/*"
done
}

Kzs(){

cp $base_dir/pack/cfssljson_linux-amd64 /opt/k8s/bin/cfssljson
cp $base_dir/pack/cfssl_linux-amd64 /opt/k8s/bin/cfssl
cp $base_dir/pack/cfssl-certinfo_linux-amd64 /opt/k8s/bin/cfssl-certinfo
chmod +x /opt/k8s/bin/*
source /opt/k8s/bin/environment.sh

for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}"
    ssh root@${node_ip} "echo  "export PATH=/opt/k8s/bin:$PATH"  >> /etc/profile"
    ssh root@${node_ip} "source /etc/profile"
done



cd $base_dir/config/Kzs/ && cfssl gencert -initca ca-csr.json | cfssljson -bare ca

for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}"
    scp $base_dir/config/Kzs/{ca*.pem,ca-config.json} root@${node_ip}:/etc/kubernetes/cert
done
}


Kctl(){

rm -rf $base_dir/config/Kctl/server
rm -rf $base_dir/config/Kctl/client
mkdir $base_dir/config/Kctl/server
mkdir $base_dir/config/Kctl/client
tar xf $base_dir/pack/kubernetes-client-linux-amd64.tar.gz -C $base_dir/config/Kctl/client
tar xf $base_dir/pack/kubernetes-server-linux-amd64.tar.gz -C $base_dir/config/Kctl/server
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}"
    scp $base_dir/config/Kctl/client/kubernetes/client/bin/kubectl root@${node_ip}:/opt/k8s/bin/
    scp $base_dir/config/Kctl/server/kubernetes/server/bin/* root@${node_ip}:/opt/k8s/bin/
    ssh root@${node_ip} "chmod +x /opt/k8s/bin/*"
done



source /opt/k8s/bin/environment.sh
cd $base_dir/config/Kctl/
cfssl gencert -ca=/etc/kubernetes/cert/ca.pem \
  -ca-key=/etc/kubernetes/cert/ca-key.pem \
  -config=/etc/kubernetes/cert/ca-config.json \
  -profile=kubernetes admin-csr.json | cfssljson -bare admin

# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/cert/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kubectl.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem \
  --embed-certs=true \
  --kubeconfig=kubectl.kubeconfig

# 设置上下文参数
kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=kubectl.kubeconfig

# 设置默认上下文
kubectl config use-context kubernetes --kubeconfig=kubectl.kubeconfig

source /opt/k8s/bin/environment.sh
for node_ip in ${MASTER_IPS[@]}
do
    echoGreen ">>> ${node_ip}"
    ssh root@${node_ip} "mkdir -p ~/.kube"
    scp $base_dir/config/Kctl/kubectl.kubeconfig root@${node_ip}:~/.kube/config
done
}

Ketcd(){

tar xf $base_dir/pack/etcd*-linux-amd64.tar.gz -C $base_dir/config/Ketcd
cd $base_dir/config/Ketcd
cfssl gencert -ca=/etc/kubernetes/cert/ca.pem \
    -ca-key=/etc/kubernetes/cert/ca-key.pem \
    -config=/etc/kubernetes/cert/ca-config.json \
    -profile=kubernetes etcd-csr.json | cfssljson -bare etcd

source /opt/k8s/bin/environment.sh
for node_ip in ${ETCD_IPS[@]}
do
    echoGreen ">>> ${node_ip}"
    scp $base_dir/config/Ketcd/etcd*-linux-amd64/etcd* root@${node_ip}:/opt/k8s/bin
    ssh root@${node_ip} "chmod +x /opt/k8s/bin/*"
    ssh root@${node_ip} "mkdir -p /etc/etcd/cert"
    scp $base_dir/config/Ketcd/etcd*.pem root@${node_ip}:/etc/etcd/cert/
done

cat > $base_dir/config/Ketcd/etcd.service <<EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
User=root
Type=notify
WorkingDirectory=/var/lib/etcd/
ExecStart=/opt/k8s/bin/etcd \\
  --data-dir=/var/lib/etcd \\
  --name=##NODE_NAME## \\
  --cert-file=/etc/etcd/cert/etcd.pem \\
  --key-file=/etc/etcd/cert/etcd-key.pem \\
  --trusted-ca-file=/etc/kubernetes/cert/ca.pem \\
  --peer-cert-file=/etc/etcd/cert/etcd.pem \\
  --peer-key-file=/etc/etcd/cert/etcd-key.pem \\
  --peer-trusted-ca-file=/etc/kubernetes/cert/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --listen-peer-urls=https://##ETCD_IP##:2380 \\
  --initial-advertise-peer-urls=https://##ETCD_IP##:2380 \\
  --listen-client-urls=https://##ETCD_IP##:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls=https://##ETCD_IP##:2379 \\
  --initial-cluster-token=etcd-cluster-0 \\
  --initial-cluster=${ETCD_NODES} \\
  --initial-cluster-state=new
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

source /opt/k8s/bin/environment.sh
for (( i=0; i < 3; i++ ))
do
    cd $base_dir/config/Ketcd/
    sed -e "s/##NODE_NAME##/${NODE_NAMES[i]}/" -e "s/##ETCD_IP##/${NODE_IPS[i]}/" etcd.service  > etcd-${NODE_IPS[i]}.service 
done

for node_ip in ${ETCD_IPS[@]}
do
    echoGreen ">>> ${node_ip}"
    cd $base_dir/config/Ketcd/
    ssh root@${node_ip} "mkdir -p /var/lib/etcd" 
    scp $base_dir/config/Ketcd/etcd-${node_ip}.service root@${node_ip}:/etc/systemd/system/etcd.service
done

source /opt/k8s/bin/environment.sh
for node_ip in ${ETCD_IPS[@]}
do
    echo ">>> ${node_ip}" 
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable etcd && systemctl start etcd" &
    sleep 3
    ssh root@${node_ip} "systemctl status etcd|grep Active"
done

echoYellow "检测etcd服务是否正常"
    ETCDCTL_API=3 /opt/k8s/bin/etcdctl \
    --endpoints=https://${node_ip}:2379 \
    --cacert=/etc/kubernetes/cert/ca.pem \
    --cert=/etc/etcd/cert/etcd.pem \
    --key=/etc/etcd/cert/etcd-key.pem endpoint health
}

Knet (){

rm -rf $base_dir/config/Knet/flannel
mkdir $base_dir/config/Knet/flannel
tar xf $base_dir/pack/flannel*-linux-amd64.tar.gz -C $base_dir/config/Knet/flannel
source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    scp $base_dir/config/Knet/flannel/{flanneld,mk-docker-opts.sh} root@${node_ip}:/opt/k8s/bin/
    ssh root@${node_ip} "chmod +x /opt/k8s/bin/*"
done

cd $base_dir/config/Knet
cfssl gencert -ca=/etc/kubernetes/cert/ca.pem \
  -ca-key=/etc/kubernetes/cert/ca-key.pem \
  -config=/etc/kubernetes/cert/ca-config.json \
  -profile=kubernetes flanneld-csr.json | cfssljson -bare flanneld

source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    ssh root@${node_ip} "mkdir -p /etc/flanneld/cert"
    scp $base_dir/config/Knet/flanneld*.pem root@${node_ip}:/etc/flanneld/cert
done

etcdctl \
  --endpoints=${ETCD_ENDPOINTS} \
  --ca-file=/etc/kubernetes/cert/ca.pem \
  --cert-file=/etc/flanneld/cert/flanneld.pem \
  --key-file=/etc/flanneld/cert/flanneld-key.pem \
  set ${FLANNEL_ETCD_PREFIX}/config '{"Network":"'${CLUSTER_CIDR}'", "SubnetLen": 24, "Backend": {"Type": "vxlan"}}'

source /opt/k8s/bin/environment.sh
cat > flanneld.service << EOF
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
ExecStart=/opt/k8s/bin/flanneld \\
  -etcd-cafile=/etc/kubernetes/cert/ca.pem \\
  -etcd-certfile=/etc/flanneld/cert/flanneld.pem \\
  -etcd-keyfile=/etc/flanneld/cert/flanneld-key.pem \\
  -etcd-endpoints=${ETCD_ENDPOINTS} \\
  -etcd-prefix=${FLANNEL_ETCD_PREFIX} \\
  -iface=${VIP_IF}
ExecStartPost=/opt/k8s/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
EOF

source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    scp $base_dir/config/Knet/flanneld.service root@${node_ip}:/etc/systemd/system/
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable flanneld && systemctl start flanneld"
    ssh root@${node_ip} "systemctl status flanneld|grep Active"
done
}

Kmaster (){

Kha(){

source /opt/k8s/bin/environment.sh
cat  > $base_dir/config/Kmaster/Kha/keepalived-master.conf <<EOF
global_defs {
    router_id lb-master-105
}

vrrp_script check-haproxy {
    script "killall -0 haproxy"
    interval 5
    weight -30
}

vrrp_instance VI-kube-master {
    state MASTER
    priority 120
    dont_track_primary
    interface ${VIP_IF}
    virtual_router_id 68
    advert_int 3
    track_script {
        check-haproxy
    }
    virtual_ipaddress {
        ${MASTER_VIP}
    }
}
EOF

cat  > $base_dir/config/Kmaster/Kha/keepalived-backup.conf <<EOF
global_defs {
    router_id lb-backup-105
}

vrrp_script check-haproxy {
    script "killall -0 haproxy"
    interval 5
    weight -30
}

vrrp_instance VI-kube-master {
    state BACKUP
    priority 110
    dont_track_primary
    interface ${VIP_IF}
    virtual_router_id 68
    advert_int 3
    track_script {
        check-haproxy
    }
    virtual_ipaddress {
        ${MASTER_VIP}
    }
}
EOF

scp $base_dir/config/Kmaster/Kha/keepalived-master.conf root@kube-master1:/etc/keepalived/keepalived.conf
scp $base_dir/config/Kmaster/Kha/keepalived-backup.conf root@kube-master2:/etc/keepalived/keepalived.conf
scp $base_dir/config/Kmaster/Kha/keepalived-backup.conf root@kube-master3:/etc/keepalived/keepalived.conf
scp $base_dir/config/Kmaster/Kha/keepalived-backup.conf root@kube-node4:/etc/keepalived/keepalived.conf

source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    scp $base_dir/config/Kmaster/Kha/haproxy.cfg root@${node_ip}:/etc/haproxy
    ssh root@${node_ip} "setsebool -P haproxy_connect_any=1"
    ssh root@${node_ip} "systemctl start haproxy"
    ssh root@${node_ip} "systemctl enable haproxy"
    ssh root@${node_ip} "systemctl status haproxy|grep Active"
    ssh root@${node_ip} "netstat -lnpt|grep haproxy"
    ssh root@${node_ip} "systemctl start keepalived"
    ssh root@${node_ip} "systemctl enable keepalived"
    ssh root@${node_ip} "systemctl status keepalived|grep Active"
done
}

Kapi(){

source /opt/k8s/bin/environment.sh
cd $base_dir/config/Kmaster/Kapi/
cfssl gencert -ca=/etc/kubernetes/cert/ca.pem \
  -ca-key=/etc/kubernetes/cert/ca-key.pem \
  -config=/etc/kubernetes/cert/ca-config.json \
  -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

cd $base_dir/config/Kmaster/Kapi/
openssl genrsa -out ./service.key 2048
openssl rsa -in ./service.key -pubout -out ./service.pub


cat > $base_dir/config/Kmaster/Kapi/kube-apiserver.service << EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target
 
 
[Service]
ExecStart=/opt/k8s/bin/kube-apiserver \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --anonymous-auth=false \\
  --advertise-address=##NODE_IP## \\
  --bind-address=##NODE_IP## \\
  --secure-port=6443 \\
  --authorization-mode=Node,RBAC \\
  --enable-bootstrap-token-auth \\
  --token-auth-file=/etc/kubernetes/token.csv \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --service-node-port-range=${NODE_PORT_RANGE} \\
  --tls-cert-file=/etc/kubernetes/cert/kubernetes.pem \\
  --tls-private-key-file=/etc/kubernetes/cert/kubernetes-key.pem \\
  --client-ca-file=/etc/kubernetes/cert/ca.pem \\
  --kubelet-client-certificate=/etc/kubernetes/cert/kubernetes.pem \\
  --kubelet-client-key=/etc/kubernetes/cert/kubernetes-key.pem \\
  --service-account-key-file=/etc/kubernetes/cert/service.pub \\
  --service-account-issuer=https://kubernetes.default.svc.cluster.local \\
  --service-account-signing-key-file=/etc/kubernetes/cert/service.key \\
  --etcd-cafile=/etc/kubernetes/cert/ca.pem \\
  --etcd-certfile=/etc/kubernetes/cert/kubernetes.pem \\
  --etcd-keyfile=/etc/kubernetes/cert/kubernetes-key.pem \\
  --etcd-servers=${ETCD_ENDPOINTS} \\
  --requestheader-client-ca-file=/etc/kubernetes/cert/ca.pem \\
  --proxy-client-cert-file=/etc/kubernetes/cert/kubernetes.pem \\
  --proxy-client-key-file=/etc/kubernetes/cert/kubernetes-key.pem \\
  --requestheader-allowed-names=kubernetes \\
  --requestheader-extra-headers-prefix=X-Remote-Extra- \\
  --requestheader-group-headers=X-Remote-Group \\
  --requestheader-username-headers=X-Remote-User \\
  --enable-aggregator-routing=true \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/kube-apiserver-audit.log \\
  --event-ttl=1h \\
  --alsologtostderr=true \\
  --logtostderr=false \\
  --log-dir=/var/log/kubernetes \\
  --v=2
Restart=on-failure
RestartSec=5
Type=notify
User=root
LimitNOFILE=65536
 
[Install]
WantedBy=multi-user.target

EOF

for (( i=0; i < 3; i++ ))
do
    cd $base_dir/config/Kmaster/Kapi/
    sed -e "s/##NODE_NAME##/${NODE_NAMES[i]}/" -e "s/##NODE_IP##/${MASTER_IPS[i]}/" kube-apiserver.service > kube-apiserver-${NODE_IPS[i]}.service 
done

TOKEN=`head -c 32 /dev/urandom | base64`
cat > $base_dir/config/Kmaster/Kapi/token.csv <<EOF
$TOKEN,kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF


for node_ip in ${MASTER_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    ssh ${node_ip} "mkdir -p /etc/kubernetes/cert/"
    scp $base_dir/config/Kmaster/Kapi/kubernetes*.pem ${node_ip}:/etc/kubernetes/cert/
    scp $base_dir/config/Kmaster/Kapi/service*  ${node_ip}:/etc/kubernetes/cert/
    scp $base_dir/config/Kmaster/Kapi/token.csv  ${node_ip}:/etc/kubernetes/
    ssh ${node_ip} "mkdir -p /var/log/kubernetes"
    scp $base_dir/config/Kmaster/Kapi/kube-apiserver-${node_ip}.service ${node_ip}:/etc/systemd/system/kube-apiserver.service
    ssh ${node_ip} "systemctl daemon-reload && systemctl enable kube-apiserver && systemctl start kube-apiserver" &
    sleep 10
    ssh root@${node_ip} "systemctl status kube-apiserver |grep 'Active:'"
done

sleep 10
kubectl create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user kubernetes
}

Kmanage(){

source /opt/k8s/bin/environment.sh

cd $base_dir/config/Kmaster/Kmanage/
cfssl gencert -ca=/etc/kubernetes/cert/ca.pem \
  -ca-key=/etc/kubernetes/cert/ca-key.pem \
  -config=/etc/kubernetes/cert/ca-config.json \
  -profile=kubernetes kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/cert/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=kube-controller-manager.pem \
  --client-key=kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context system:kube-controller-manager \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context system:kube-controller-manager --kubeconfig=kube-controller-manager.kubeconfig

cat > $base_dir/config/Kmaster/Kmanage/kube-controller-manager.service << EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/opt/k8s/bin/kube-controller-manager \\
  --bind-address=127.0.0.1 \\
  --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \\
  --service-cluster-ip-range=${SERVICE_CIDR} \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/etc/kubernetes/cert/ca.pem \\
  --cluster-signing-key-file=/etc/kubernetes/cert/ca-key.pem \\
  --cluster-signing-duration=87600h0m0s \\
  --root-ca-file=/etc/kubernetes/cert/ca.pem \\
  --service-account-private-key-file=/etc/kubernetes/cert/ca-key.pem \\
  --leader-elect=true \\
  --feature-gates=RotateKubeletServerCertificate=true \\
  --controllers=*,bootstrapsigner,tokencleaner \\
  --tls-cert-file=/etc/kubernetes/cert/kube-controller-manager.pem \\
  --tls-private-key-file=/etc/kubernetes/cert/kube-controller-manager-key.pem \\
  --use-service-account-credentials=true \\
  --alsologtostderr=true \\
  --logtostderr=false \\
  --log-dir=/var/log/kubernetes \\
  --v=2
Restart=on
Restart=on-failure
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF

source /opt/k8s/bin/environment.sh
for node_ip in ${MASTER_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    scp $base_dir/config/Kmaster/Kmanage/kube-controller-manager*.pem root@${node_ip}:/etc/kubernetes/cert/
    scp $base_dir/config/Kmaster/Kmanage/kube-controller-manager.kubeconfig root@${node_ip}:/etc/kubernetes/
    scp $base_dir/config/Kmaster/Kmanage/kube-controller-manager.service root@${node_ip}:/etc/systemd/system/
    ssh root@${node_ip} "mkdir -p /var/log/kubernetes"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable kube-controller-manager && systemctl start kube-controller-manager"
    ssh root@${node_ip} "systemctl status kube-controller-manager|grep Active"
done
}

Kscheduler(){

source /opt/k8s/bin/environment.sh
cd $base_dir/config/Kmaster/Kscheduler/
cfssl gencert -ca=/etc/kubernetes/cert/ca.pem \
  -ca-key=/etc/kubernetes/cert/ca-key.pem \
  -config=/etc/kubernetes/cert/ca-config.json \
  -profile=kubernetes kube-scheduler-csr.json | cfssljson -bare kube-scheduler

kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/cert/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=kube-scheduler.pem \
  --client-key=kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context system:kube-scheduler \
  --cluster=kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context system:kube-scheduler --kubeconfig=kube-scheduler.kubeconfig

cat > $base_dir/config/Kmaster/Kscheduler/kube-scheduler.service << EOF

[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/opt/k8s/bin/kube-scheduler \\
  --bind-address=127.0.0.1 \\
  --kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \\
  --leader-elect=true \\
  --alsologtostderr=true \\
  --logtostderr=false \\
  --log-dir=/var/log/kubernetes \\
  --v=2
Restart=on-failure
RestartSec=5
User=root

[Install]
WantedBy=multi-user.target
EOF



source /opt/k8s/bin/environment.sh
for node_ip in ${MASTER_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    scp $base_dir/config/Kmaster/Kscheduler/kube-scheduler.kubeconfig root@${node_ip}:/etc/kubernetes/
    scp $base_dir/config/Kmaster/Kscheduler/kube-scheduler.service root@${node_ip}:/etc/systemd/system/
    ssh root@${node_ip} "mkdir -p /var/log/kubernetes"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable kube-scheduler && systemctl start kube-scheduler"
    ssh root@${node_ip} "systemctl status kube-scheduler|grep Active"
done
}

echoYellow "现在开始部署高可用组件haproxy & keepalived！"
Kha
sleep 3
echoYellow "现在开始部署kube-apiserver！"
Kapi
sleep 3
echoYellow "现在开始部署kube-controller-manager！"
Kmanage
sleep 3
echoYellow "现在开始部署kube-scheduler！"
Kscheduler
}

Kwork(){

Kdocker(){
source /opt/k8s/bin/environment.sh
tar xf $base_dir/pack/docker*.tar.gz  -C $base_dir/config/Kwork/Kdocker/

cat > $base_dir/config/Kwork/Kdocker/docker.service << "EOF"
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
Environment="PATH=/opt/k8s/bin:/bin:/sbin:/usr/bin:/usr/sbin"
EnvironmentFile=-/run/flannel/docker
ExecStart=/opt/k8s/bin/dockerd --log-level=error $DOCKER_NETWORK_OPTIONS
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

cat > $base_dir/config/Kwork/Kdocker/docker-daemon.json << "EOF"
{
    "registry-mirrors": ["https://hub-mirror.c.163.com", "https://docker.mirrors.ustc.edu.cn"],
    "graph":"/home/docker"
}
EOF



source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    scp $base_dir/config/Kwork/Kdocker/docker/*  root@${node_ip}:/opt/k8s/bin/
    ssh root@${node_ip} "chmod +x /opt/k8s/bin/*"
    scp $base_dir/config/Kwork/Kdocker/docker.service root@${node_ip}:/etc/systemd/system/
    ssh root@${node_ip} "mkdir -p /etc/docker/"
    scp $base_dir/config/Kwork/Kdocker/docker-daemon.json root@${node_ip}:/etc/docker/daemon.json
    ssh root@${node_ip} "/usr/sbin/iptables -F && /usr/sbin/iptables -X && /usr/sbin/iptables -F -t nat && /usr/sbin/iptables -X -t nat"
    ssh root@${node_ip} "/usr/sbin/iptables -P FORWARD ACCEPT"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable docker && systemctl start docker"
    #ssh root@${node_ip} 'for intf in /sys/devices/virtual/net/docker0/brif/*; do echo 1 > $intf/hairpin_mode; done'
    #ssh root@${node_ip} "sysctl -p /etc/sysctl.d/kubernetes.conf"
    ssh root@${node_ip} "systemctl status docker|grep Active" && sleep 10
    scp $base_dir/pack/pod.tar  root@${node_ip}:/etc/kubernetes/
    ssh root@${node_ip} "/opt/k8s/bin/docker load <  /etc/kubernetes/pod.tar"
    ssh root@${node_ip} "/usr/sbin/ip addr show flannel.1 && /usr/sbin/ip addr show docker0"
done
}

Kkubelet(){

source /opt/k8s/bin/environment.sh
for node_name in ${NODE_NAMES[@]}
do
    echo ">>> ${node_name}" 
    cd $base_dir/config/Kwork/Kkubelet/
    # 创建 token
    export BOOTSTRAP_TOKEN=$(awk -F "," '{print $1}' /etc/kubernetes/token.csv)

    # 设置集群参数
    kubectl config set-cluster kubernetes \
      --certificate-authority=/etc/kubernetes/cert/ca.pem \
      --embed-certs=true \
      --server=${KUBE_APISERVER} \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置客户端认证参数
    kubectl config set-credentials kubelet-bootstrap \
      --token=${BOOTSTRAP_TOKEN} \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置上下文参数
    kubectl config set-context default \
      --cluster=kubernetes \
      --user=kubelet-bootstrap \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置默认上下文
    kubectl config use-context default --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig
done

cat > $base_dir/config/Kwork/Kkubelet/kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubelet
ExecStart=/opt/k8s/bin/kubelet \
  --bootstrap-kubeconfig=/etc/kubernetes/kubelet-bootstrap.kubeconfig \
  --cert-dir=/etc/kubernetes/cert \
  --kubeconfig=/etc/kubernetes/kubelet.kubeconfig \
  --config=/etc/kubernetes/kubelet.config.json \
  --hostname-override=##NODE_NAME## \
  --pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest \
  --logtostderr=false \
  --log-dir=/var/log/kubernetes \
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF



source /opt/k8s/bin/environment.sh
for node_name in ${NODE_NAMES[@]}
do 
    echoGreen ">>> ${node_name}"
    cd $base_dir/config/Kwork/Kkubelet/
    sed -e "s/##NODE_NAME##/${node_name}/" kubelet.service > kubelet-${node_name}.service
    scp $base_dir/config/Kwork/Kkubelet/kubelet-${node_name}.service root@${node_name}:/etc/systemd/system/kubelet.service
    scp $base_dir/config/Kwork/Kkubelet/kubelet-bootstrap-${node_name}.kubeconfig root@${node_name}:/etc/kubernetes/kubelet-bootstrap.kubeconfig
done

kubectl create clusterrolebinding kubelet-bootstrap --clusterrole=system:node-bootstrapper --user=kubelet-bootstrap --group=system:bootstrappers

source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}"
    cd $base_dir/config/Kwork/Kkubelet/
    sed -e "s/##NODE_IP##/${node_ip}/" kubelet.config.json.template > kubelet.config-${node_ip}.json
    scp $base_dir/config/Kwork/Kkubelet/kubelet.config-${node_ip}.json root@${node_ip}:/etc/kubernetes/kubelet.config.json
    ssh root@${node_ip} "mkdir -p /var/lib/kubelet"
    ssh root@${node_ip} "/usr/sbin/swapoff -a"
    ssh root@${node_ip} "mkdir -p /var/log/kubernetes"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable kubelet && systemctl restart kubelet"
    ssh root@${node_ip} "systemctl status kubelet | grep Active"
done

/opt/k8s/bin/kubectl apply -f $base_dir/config/Kwork/Kkubelet/csr-crb.yaml
/opt/k8s/bin/kubectl get csr | grep Pending | awk '{print $1}' | xargs kubectl certificate approve

}

Kproxy(){

source /opt/k8s/bin/environment.sh
cd $base_dir/config/Kwork/Kproxy/
cfssl gencert -ca=/etc/kubernetes/cert/ca.pem \
  -ca-key=/etc/kubernetes/cert/ca-key.pem \
  -config=/etc/kubernetes/cert/ca-config.json \
  -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy

kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/cert/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

cat > $base_dir/config/Kwork/Kproxy/kube-proxy.config.yaml.template <<EOF
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: ##NODE_IP##
clientConnection:
  kubeconfig: /etc/kubernetes/kube-proxy.kubeconfig
clusterCIDR: ${CLUSTER_CIDR}
healthzBindAddress: ##NODE_IP##:10256
hostnameOverride: ##NODE_NAME##
kind: KubeProxyConfiguration
metricsBindAddress: ##NODE_IP##:10249
mode: "ipvs"
EOF


source /opt/k8s/bin/environment.sh
for (( i=0; i < 3; i++ ))
do 
    echoGreen ">>> ${NODE_NAMES[i]}"
    cd $base_dir/config/Kwork/Kproxy/
    sed -e "s/##NODE_NAME##/${NODE_NAMES[i]}/" -e "s/##NODE_IP##/${NODE_IPS[i]}/" kube-proxy.config.yaml.template > kube-proxy-${NODE_NAMES[i]}.config.yaml
    scp $base_dir/config/Kwork/Kproxy/kube-proxy-${NODE_NAMES[i]}.config.yaml root@${NODE_NAMES[i]}:/etc/kubernetes/kube-proxy.config.yaml
done

source /opt/k8s/bin/environment.sh
cat > $base_dir/config/Kwork/Kproxy/kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
WorkingDirectory=/var/lib/kube-proxy
ExecStart=/opt/k8s/bin/kube-proxy \
  --config=/etc/kubernetes/kube-proxy.config.yaml \
  --alsologtostderr=true \
  --logtostderr=false \
  --log-dir=/var/log/kubernetes \
  --v=2
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF


source /opt/k8s/bin/environment.sh
for node_name in ${NODE_NAMES[@]}
do 
    echoGreen ">>> ${node_name}"
    scp $base_dir/config/Kwork/Kproxy/kube-proxy.kubeconfig root@${node_name}:/etc/kubernetes/
    scp $base_dir/config/Kwork/Kproxy/kube-proxy.service root@${node_name}:/etc/systemd/system/kube-proxy.service
done

source /opt/k8s/bin/environment.sh
for node_ip in ${NODE_IPS[@]}
do
    echoGreen ">>> ${node_ip}" 
    ssh root@${node_ip} "mkdir -p /var/lib/kube-proxy"
    ssh root@${node_ip} "mkdir -p /var/log/kubernetes"
    ssh root@${node_ip} "systemctl daemon-reload && systemctl enable kube-proxy && systemctl start kube-proxy"
    ssh root@${node_ip} "systemctl status kube-proxy|grep Active"
    ssh root@${node_ip} "/usr/sbin/ipvsadm -ln"
done
}


#将node节点加入集群
/opt/k8s/bin/kubectl certificate approve `kubectl get csr | grep Pending| awk '{print $1}'`


echoYellow "现在开始部署docker服务！"
Kdocker
sleep 3
echoYellow "现在开始部署kubelet服务！"
Kkubelet
sleep 3
echoYellow "现在开始部署kube-proxy服务！"
Kproxy
}

echoYellow "现在开始执行环境初始化工作！"
Kcsh
sleep 2
echoYellow "现在开始配置证书！"
Kzs
sleep 2
echoYellow "现在开始部署kubectl服务！"
Kctl
sleep 2
echoYellow "现在开始部署etcd服务！"
Ketcd
sleep 2
echoYellow "现在开始部署flannel网络服务！"
Knet
sleep 2
echoYellow "现在开始部署master组件！"
Kmaster
sleep 2
echoYellow "现在开始部署work组件！"
Kwork

echoRed "部署完成，现在可以享用k8s高可用集群各个功能了！"
