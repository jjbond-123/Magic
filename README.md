# 二进制安装-k8s集群 一键部署脚本

### 1、环境说明

这里简单说明一下我使用的服务器情况：

服务器均采用 CentOS 7.9 版本，未在其他系统版本中进行测试。



### 2、部署脚本包

部署的脚本位置：https://github.com/jjbond-123/k8s 

```
脚本包包含如下：
config  
pack 
magic.sh
next.sh
```

##### 将下载好的文件放在主控制节点上，我这里是放在kube-master1上面。



  **下载组件包：** 

```php
cfssl_linux-amd64
cfssl-certinfo_linux-amd64
cfssljson_linux-amd64
etcd-v3.3.10-linux-amd64.tar.gz     
kubernetes-client-linux-amd64.tar.gz
docker-19.03.15.tgz  
flannel-v0.10.0-linux-amd64.tar.gz  
kubernetes-server-linux-amd64.tar.gz  
pod.tar
    
 pod.tar这是一个镜像。找台部署了docker的机器拉取这个镜像：
 docker pull registry.access.redhat.com/rhel7/pod-infrastructure:latest。将这个镜像打包上传
 #注释：以上的所有版本必须匹配，各组件版本不匹配，会发生问题，
 推荐：我这里安装包，docker是19版本，etcd是3.3版本，flannel版本是0.10版本，k8s版本是1.19版本。
 docker版本：https://download.docker.com/linux/static/stable/x86_64/
 etcd版本：https://github.com/etcd-io/etcd/releases/tag/v3.3.10
 flannel版本：https://github.com/flannel-io/flannel/releases/tag/v0.10.0
 k8s版本：https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.19.md
```

将上述所有的组件包放在下载脚本包的pack中



### 3、准备工作

1、根据自身情况修改文件

```
config/environment.sh                                     #修改ip为自己将要部署的机器ip
config/Kcsh/hosts                                         #修改ip为自己将要部署的机器ip
config/Ketcd/etcd-csr.json                                #修改ip为自己将要部署的机器ip
config/Kmaster/Kha/haproxy.cfg                            #修改ip为自己将要部署的机器ip
config/Kmaster/Kapi/kubernetes-csr.json                   #修改ip为自己将要部署的机器ip
config/Kmaster/Kmanage/kube-controller-manager-csr.json   #修改ip为自己将要部署的机器ip
config/Kmaster/Kscheduler/kube-scheduler-csr.json         #修改ip为自己将要部署的机器ip
```

2、挂载yum源：略

3、修改主机名字,主机名称建议全是小写

```
ssh -o StrictHostKeyChecking=no root@xx.xx.xx.xx "hostname  kube-master1"
ssh -o StrictHostKeyChecking=no root@xx.xx.xx.xx "hostname  kube-master2"
ssh -o StrictHostKeyChecking=no root@xx.xx.xx.xx "hostname  kube-master3"
ssh -o StrictHostKeyChecking=no root@xx.xx.xx.xx "hostname  kube-node4"
```



 4、在magic.sh脚本里，修改root名字，并添加节点

```shell
[root@localhost magic]# sed -n '351,354p' magic.sh
scp $base_dir/config/Kmaster/Kha/keepalived-master.conf root@kube-master1:/etc/keepalived/keepalived.conf
scp $base_dir/config/Kmaster/Kha/keepalived-backup.conf root@kube-master2:/etc/keepalived/keepalived.conf
scp $base_dir/config/Kmaster/Kha/keepalived-backup.conf root@kube-master3:/etc/keepalived/keepalived.conf
scp $base_dir/config/Kmaster/Kha/keepalived-backup.conf root@kube-node4:/etc/keepalived/keepalived.conf
```





### 4、开始部署

```shell
[root@localhost magic]# sh -x magic.sh
```



如果上述配置有问题报错：

```shell
[root@localhost magic]# sh -x next.sh
[root@localhost magic]# sh -x magic.sh
```







==如果脚本一开始执行就失败。是脚本的编码问题。==

> ```
> 解决办法
> vim xxx.sh打开sh脚本文件
> 执行 :set ff 命令查看当前编码格式,此时可以看到类似如下的信息:
> fileformat=dos
> 执行 :set ff=unix 命令将sh脚本文件格式改为linux的格式
> 执行 :wq! 命令强制保存退出,再次执行该脚本即可正常运行
> ```





注：这里版本我使用的是19版本的，几个高版本的也试了，就在改变一下各组件的service启动文件。脚本没问题，需要多加修改。









