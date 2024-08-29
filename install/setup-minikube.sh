#!/bin/bash
# SEtup help: https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# Get kubectrl
curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl.sha256
#curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

#Install kubectrl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

sleep 10

minikube start
minikube kubectl -- get po -A
alias kubectl="minikube kubectl --"


