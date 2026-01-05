#!/bin/bash
# scripts/setup-ec2.sh
# Run this script on your EC2 instance to prepare it for deployments

set -e

echo "Setting up EC2 instance for Clock App deployment..."

# Update system
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
sudo usermod -aG docker $USER
sudo newgrp docker

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Nginx
echo "Installing Nginx..."
sudo apt-get install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create Nginx configuration for reverse proxy
echo "Configuring Nginx reverse proxy..."
sudo tee /etc/nginx/sites-available/clock-app > /dev/null <<'EOF'
server {
    listen 80;
    server_name _;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    location /health {
        access_log off;
        proxy_pass http://localhost:8080/health;
    }
}
EOF

# Enable the site
sudo ln -sf /etc/nginx/sites-available/clock-app /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload Nginx
sudo nginx -t
sudo systemctl reload nginx

# Install monitoring tools (optional)
echo "Installing monitoring tools..."
sudo apt-get install -y htop nethogs iotop

# Configure firewall
echo "Configuring firewall..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS (for future)
sudo ufw --force enable

# Create deployment directory
echo "Creating deployment directory..."
mkdir -p ~/deployments
cd ~/deployments

# Set up log rotation for Docker
echo "Configuring Docker log rotation..."
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo systemctl restart docker

# Display system info
echo ""
echo "EC2 setup complete!"
echo ""
echo "System Information:"
echo "=================="
echo "Docker version: $(docker --version)"
echo "Nginx version: $(nginx -v 2>&1)"
echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo ""
echo "Next steps:"
echo "1. Add this EC2 public IP to GitHub secrets as EC2_HOST"
echo "2. Add your SSH private key to GitHub secrets as EC2_SSH_KEY"
echo "3. Run the GitHub Actions workflow to deploy"
echo ""
echo " Note: You may need to log out and back in for Docker group permissions to take effect"