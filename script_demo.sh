#!/bin/bash

# Install Docker
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Start Docker service
sudo systemctl start docker

# Clone the GitHub repository
git clone https://github.com/taimoorahmed91/compose.git

# Navigate to the cloned repository directory
cd compose

# Pull images using Docker Compose and capture output
docker-compose pull | tee docker-compose-pull-output.txt

# Create a directory to store digest files
mkdir -p ../image-digests

# Extract digests and save them to files named after each image (with tags)
grep "Digest:" docker-compose-pull-output.txt | while read -r line; do
  image=$(echo $line | awk '{print $2}' | sed 's/sha256:.*//')
  digest=$(echo $line | awk '{print $4}')
  echo $digest > "../image-digests/$(echo $image | tr '/' '_').txt"
done

# Run Docker Compose
sudo docker-compose up -d

# Wait for Docker Compose services to be fully up and running
echo "Waiting for Docker Compose services to be fully up and running..."
while ! docker-compose ps | grep -q "Up"; do
  sleep 5
done

echo "Docker Compose services are up and running."

# Navigate back to the parent directory
cd ..

# Remove the cloned repository directory
rm -rf compose

echo "'compose' directory removed."
echo "Digest files are saved in 'image-digests' directory."
