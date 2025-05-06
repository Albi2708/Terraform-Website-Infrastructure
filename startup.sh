#!/bin/bash
# Install and start a simple apache web server
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create a basic HTML page
echo "<html><body><h1>EC2 instance with ASG is working fine.</h1></body></html>" > /var/www/html/index.html
