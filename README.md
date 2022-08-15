Installation


Run beneath command on control node

```
$ sudo hostnamectl set-hostname "myserver"
$ exec bash
```

```
[andres@myserver ~]$ hostname
myserver
```

set hostname 

```
[andres@myserver ~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.10.100 myserver
```

Step 2) Disable Swap and Set SELinux in permissive mode
Disable swap, so that kubelet can work properly. Run below commands on all the nodes to disable it,

```
$ sudo swapoff -a
$ sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

Run beneath sed command on all the nodes to set SELinux in permissive mode

```
$ sudo setenforce 0
$ sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

Step 3) Configure Firewall Rules on Master and Worker Nodes
On control plane, following ports must be allowed in firewall.

To allow above ports in control plane, run

```
$ sudo firewall-cmd --permanent --add-port=6443/tcp
$ sudo firewall-cmd --permanent --add-port=2379-2380/tcp
$ sudo firewall-cmd --permanent --add-port=10250/tcp
$ sudo firewall-cmd --permanent --add-port=10251/tcp
$ sudo firewall-cmd --permanent --add-port=10252/tcp
$ sudo firewall-cmd --reload
$ sudo modprobe br_netfilter
$ sudo sh -c "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables"
$ sudo sh -c "echo '1' > /proc/sys/net/ipv4/ip_forward"
```

Step 4) Install Docker on Master and Worker Nodes
Install Docker on master and worker nodes. Here docker will provide container run time (CRI). To install latest docker, first we need to enable its repository by running following commands.

```
$ sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
```

Now, run below dnf command on all the nodes to install docker-ce (docker community edition)

```
$ sudo dnf install docker-ce -y
```

Step 5) Install kubelet, Kubeadm and kubectl
Kubeadm is the utility through which we will install Kubernetes cluster. Kubectl is the command line utility used to interact with Kubernetes cluster. Kubelet is the component which will run all the nodes and will preform task like starting and stopping pods or containers.

To Install kubelet, Kubeadm and kubectl on all the nodes, first we need to enable Kubernetes repository.

Perform beneath commands on master 

```
$ cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

$ sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

After installing above packages, enable kubelet service

```
$ sudo systemctl enable --now kubelet
```

Step 6) Install Kubernetes Cluster with Kubeadm
While installing Kubernetes cluster we should make sure that cgroup of container run time (CRI) matches with cgroup of kubelet. Typically, in Docker, cgroup is cgroupfs, so we must instruct Kubeadm to use cgroupfs as cgoup of kubelet. This can be done by passing a yaml in Kubeadm command,

Create kubeadm-config.yaml file on control plane with following content

```
$ vi kubeadm-config.yaml
# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v1.23.4
--
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: cgroupfs
Note: Replace the Kubernetes version as per your setup.
```

Now, we are all set to install (or initialize the cluster), run below Kubeadm command from control node,

```
$ sudo kubeadm init --config kubeadm-config.yaml
```


Make the following directory and configuration files.

```
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

7. Enable pod to run on Master. This is only for demonstration purposes and is not recommended for production use.

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```
or 
```
kubectl taint node myserver node-role.kubernetes.io/master:NoSchedule-
```

8. Check that Master node has been enabled and is running.

```
kubectl get nodes
NAME  STATUS     ROLES  AGE  VERSION
master  NotReady  master   91s     v1.18.0
```














Sources

https://upcloud.com/resources/tutorials/install-kubernetes-cluster-centos-8

https://www.linuxtechi.com/install-kubernetes-cluster-on-rocky-linux/