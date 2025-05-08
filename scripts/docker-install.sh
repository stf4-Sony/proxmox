#!/bin/bash

set -e

echo "🔧 Mise à jour du système..."
apt update && apt upgrade -y

echo "📦 Installation des dépendances..."
apt install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common

echo "🔐 Ajout de la clé GPG Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "📝 Ajout du dépôt Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "📥 Installation de Docker..."
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "👤 Ajout de l’utilisateur courant au groupe 'docker'..."
usermod -aG docker $SUDO_USER || true

echo "⚙️ Configuration optimale de Docker..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "journald",
  "storage-driver": "overlay2",
  "max-concurrent-downloads": 5,
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

systemctl daemon-reexec
systemctl restart docker
systemctl enable docker

echo "✅ Docker est installé et optimisé ! Redémarre ta session pour appliquer les changements de groupe."
