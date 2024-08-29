#!/bin/bash

# Check if the script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo. Example sudo $0"
    exit 1
fi

TARGET_USER=${SUDO_USER:-$USER}
echo "$TARGET_USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/bin/docker" | sudo tee -a /etc/sudoers

# Uninstall the existing docker.io package
echo Uninstall the existing docker.io package...
sudo systemctl stop docker
sudo systemctl disable docker
sudo apt-get remove -y docker.io docker-compose docker docker-engine docker.io containerd runc

# Remove Docker repository key and source list
echo Remove Docker repository key and source list...
sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
sudo rm -f /etc/apt/sources.list.d/docker.list

# Update package index and install dependencies
echo Update package index and install dependencies...
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# Define the URL for Docker's GPG key
DOCKER_GPG_URL="https://download.docker.com/linux/ubuntu/gpg"
TEMP_KEY_FILE="/tmp/docker-gpg-key.gpg"

# Download Docker’s GPG key to a temporary file
curl -fsSL "$DOCKER_GPG_URL" -o "$TEMP_KEY_FILE"

# Add Docker’s GPG key
echo Obtaining and adding Docker GPG key...
sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg "$TEMP_KEY_FILE"

# Remove the temporary key file
echo Cleaning up temp files...
rm "$TEMP_KEY_FILE"

# Add Docker repository
echo Add Docker repository...
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
echo Updating package index...
sudo apt-get update

# Install Docker CE
echo  Install Docker CE and containerd...
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Optionally install Docker Compose (if needed)
echo INstalling docker-compose...
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

sleep 5

#Add docker group
#sudo groupadd docker

#Add cur user to docker group
echo Adding current user to docker group...
sudo usermod -aG docker $TARGET_USER

# Apply the group change and run the remaining commands in a subshell
newgrp docker <<EOF
    # Restart Docker service
    echo "Restarting Docker service..."
    sudo systemctl enable docker
    sudo systemctl restart docker

    # Display Docker status
    echo "Docker status:"
    sudo systemctl --no-pager status docker.service

    # Verify Docker installation
    echo "Docker version:"
    docker --version

    echo "Docker system info:"
    docker system info
EOF

# Remove that need for password for sudo for cur user
sudo sed -i "\|$TARGET_USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/bin/docker|d" /etc/sudoers

echo Docker is installed. If the service has failed to start up, you may need a reboot. Once done, you should be able to run docker.
#sudo docker run hello-world

