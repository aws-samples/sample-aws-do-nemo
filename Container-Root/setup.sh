#!/bin/bash
set -e

# Version variables
DOCKER_CE_CLI_VERSION="5:27.5.1-1~ubuntu.22.04~jammy"
DOCKER_BUILDX_VERSION="0.19.2-1~ubuntu.22.04~jammy"
DOCKER_COMPOSE_VERSION="2.33.0-1~ubuntu.22.04~jammy"
AWS_CLI_VERSION="2.22.7"  # Check latest at: https://github.com/aws/aws-cli/releases
KUBECTL_VERSION="v1.30.3"  # Check latest at: https://kubernetes.io/releases/
SKYPILOT_VERSION="0.8.0"

echo "Installing with versions"
echo "Docker CLI: $DOCKER_CE_CLI_VERSION"
echo "Buildx: $DOCKER_BUILDX_VERSION" 
echo "Compose: $DOCKER_COMPOSE_VERSION"
echo "AWS CLI: $AWS_CLI_VERSION"
echo "kubectl: $KUBECTL_VERSION"
echo "SkyPilot: $SKYPILOT_VERSION"

# Install prerequisites
apt-get update && apt-get install -y \
    curl \
    unzip \
    ca-certificates \
    apt-transport-https \
    gnupg \
    lsb-release \
    wget \
    socat \
    netcat

# Update OS
apt update && apt upgrade -y

# Install official Docker with version locks
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists and install specific versions
apt-get update && apt-get install -y \
    docker-ce-cli=$DOCKER_CE_CLI_VERSION \
    docker-buildx-plugin=$DOCKER_BUILDX_VERSION \
    docker-compose-plugin=$DOCKER_COMPOSE_VERSION

# Hold packages to prevent accidental upgrades
apt-mark hold docker-ce-cli docker-buildx-plugin docker-compose-plugin

# Verify installation
docker --version
docker buildx version

# Install AWS CLI v2 (version locked)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install \
 && rm -rf awscliv2.zip aws

# Install kubectl (version locked)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
 && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
 && rm kubectl

# Install kubectx
git clone https://github.com/ahmetb/kubectx
mv kubectx /opt
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Install kubetail
curl -o /tmp/kubetail https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
chmod +x /tmp/kubetail
mv /tmp/kubetail /usr/local/bin/kubetail

# Install kube node shell
curl -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
chmod +x ./kubectl-node_shell
mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell

# Configure .bashrc 
cat << EOF >> ~/.bashrc

alias ll='ls -alh --color=auto'
alias k='kubectl'
alias kc='kubectx'
alias kn='kubens'
alias kt='kubetail'
alias ks='kubectl node-shell'
alias kgn='kubectl get nodes -L node.kubernetes.io/instance-type -L skypilot.co/accelerator'
alias wp='watch kubectl get pods -o wide'

export TERM=xterm-256color

EOF

# Enable banner
echo "/welcome.sh" >> /root/.bashrc

# Install skypilot (version locked)
pip install skypilot[kubernetes]==$SKYPILOT_VERSION

# Install NeMo-Run
pip install --force-reinstall git+https://github.com/NVIDIA/NeMo-Run.git@4d056535b5cce475b0536243e2cefcfa3897eee8

# Get kubernetes folder from https://github.com/aws-samples/awsome-distributed-training/tree/main/3.test_cases/megatron/nemo/kubernetes
# This is done in build.sh in order to provide a copy of the code in the container project tree.
#cd /tmp
#git clone https://github.com/aws-samples/awsome-distributed-training/tree/main/3.test_cases/megatron/nemo/kubernetes 
#cp -rf /tmp/awsome-distributed-training/tree/main/3.test_cases/megatron/nemo/kubernetes /nemo
#echo "Cloned from https://github.com/aws-samples/aws-distributed-training/tree/main/3.test_cases/megatron/nemo/kubernetes  on $(date)" > /nemo/kubernetes/info.txt
#rm -rf /tmp/awsome-distributed-training

# Generate SBOM and store it in the root of the container image
/sbom.sh

