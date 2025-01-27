#!/bin/bash

# Step 2: Create users and groups as user1
sudo useradd user4 && echo "user4:password4" | sudo chpasswd
sudo useradd user5 && echo "user5:password5" | sudo chpasswd

sudo groupadd app
sudo groupadd database

echo "User1 operations completed!"
