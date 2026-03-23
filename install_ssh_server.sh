#!/bin/bash
#
# Setup SSH with password authentication
# Password will be passed as argument $1
PASSWORD=${1:-"kaggle"}  # Default password is "kaggle" if not provided

echo "Setting up SSH with password: $PASSWORD"

# Set root password
echo "root:$PASSWORD" | chpasswd

# Download ngrok (only if not already installed)
if ! command -v ngrok &> /dev/null;
then
    echo "ngrok not found. Downloading..."
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    tar xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
    rm ngrok-v3-stable-linux-amd64.tgz
else
    echo "ngrok is already installed."
fi

# Install SSH-Server
echo "Running apt update..."
apt update --allow-releaseinfo-change

echo "Installing OpenSSH server..."
apt install openssh-server -y

# SSH Config - Enable password authentication
echo "Configuring SSH..."
echo "PermitRootLogin yes" | tee -a /etc/ssh/sshd_config
echo "PasswordAuthentication yes" | tee -a /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" | tee -a /etc/ssh/sshd_config

echo "Restarting SSH service..."
service ssh restart

echo "SSH Server configured successfully with password authentication!"
