#!/bin/bash

# Step 1: Create users and groups
echo "Creating users and setting passwords..."
useradd user1 && echo "user1:password1" | chpasswd
useradd user2 && echo "user2:password2" | chpasswd
useradd user3 && echo "user3:password3" | chpasswd

groupadd devops
groupadd aws

# Step 2: Modify group assignments
usermod -g devops user2
usermod -g devops user3
usermod -aG aws user1

# Step 3: Create directory and file structure
echo "Creating directory structure..."
mkdir -p /dir1 /dir2/dir1/dir2 /dir7/dir10
touch /dir1/f1 /dir7/dir10/f2

# Step 4: Change group and ownership
chown user1:devops /dir1 /dir7/dir10 /dir7/dir10/f2
echo "Server setup completed!"
