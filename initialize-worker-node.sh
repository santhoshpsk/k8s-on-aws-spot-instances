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

# Fetch Instance ID
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
MY_INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

# Variables
MASTER_INSTANCE_ID=$(aws ssm get-parameter --name="/k8s-on-spot/master-node-id" --query 'Parameter.Value' --output text)
COMMAND="sudo kubeadm token create --ttl=10m --print-join-command"

# Send the command
COMMAND_ID=$(aws ssm send-command \
    --instance-ids "$MASTER_INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --parameters commands="$COMMAND" \
    --query "Command.CommandId" \
    --output text)

echo "Starting to get Kubernetes Cluster Join command..."

# Loop to check the status of the command indefinitely
while true; do
    STATUS=$(aws ssm list-command-invocations \
        --command-id "$COMMAND_ID" \
        --details \
        --query "CommandInvocations[0].Status" \
        --output text)
    
    echo "Current status: $STATUS"
    
    # Only break the loop if the command succeeded
    if [[ "$STATUS" == "Success" ]]; then
      # Fetch and display the command output each time the status is checked
      JOIN_COMMAND=$(aws ssm get-command-invocation \
      --command-id "$COMMAND_ID" \
      --instance-id "$MASTER_INSTANCE_ID" \
      --query "StandardOutputContent" \
      --output text)
      
      echo "Join Command: $JOIN_COMMAND ends here"
      
      sudo $JOIN_COMMAND --node-name $MY_INSTANCE_ID
      
      break
    fi

    if [[ "$STATUS" == "Failed" ]]; then
      COMMAND_ID=$(aws ssm send-command \
      --instance-ids "$MASTER_INSTANCE_ID" \
      --document-name "AWS-RunShellScript" \
      --parameters commands="$COMMAND" \
      --query "Command.CommandId" \
      --output text)
    fi

    echo "Sleeping for 10 seconds..."
    
    sleep 10
done