#!/bin/bash
# Update the package manager
sudo yum update -y

# Install Nginx
sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure a basic Nginx welcome page (optional)
sudo tee /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Nginx</title>
</head>
<body>
    <h1>Success! Nginx is installed and running on your instance.</h1>
</body>
</html>
EOF

# Adjust permissions (if required)
sudo chown -R nginx:nginx /usr/share/nginx/html

# Open firewall for HTTP (Port 80)
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# Confirmation message
echo "Nginx setup is complete!"
