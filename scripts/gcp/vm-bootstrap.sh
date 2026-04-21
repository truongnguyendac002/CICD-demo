#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -eq 0 ]]; then
  echo "Run as a normal user (not root)."
  exit 1
fi

sudo apt-get update
sudo apt-get install -y docker.io curl
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker "$USER"

if ! id deploy >/dev/null 2>&1; then
  sudo adduser --disabled-password --gecos "" deploy
fi
sudo usermod -aG docker deploy
sudo mkdir -p /home/deploy/.ssh
sudo chown -R deploy:deploy /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh

echo "VM bootstrap done. Re-login to apply docker group for current user."
