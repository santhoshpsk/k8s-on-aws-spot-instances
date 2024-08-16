#!/bin/bash

sudo apt update -y
sudo apt install wget curl vim git unzip -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo apt update -y
sudo apt install containerd kubelet kubeadm kubectl -y

sudo apt-mark hold kubelet kubeadm kubectl

sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

sudo sysctl --system


sudo mkdir /etc/containerd/
sudo sh -c 'containerd config default > /etc/containerd/config.toml'

sudo modprobe overlay
sudo modprobe br_netfilter

sudo systemctl restart containerd
sudo systemctl enable containerd

sudo systemctl restart kubelet
sudo systemctl enable kubelet


sudo kubeadm config images pull

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all

sudo mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

sudo -H -u ubuntu bash -c 'kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml'