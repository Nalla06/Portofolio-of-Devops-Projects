#!/bin/bash

# Create files and modify
touch /dir1/f2
rm -rf /dir6 /dir8
sed -i 's/DevOps/devops/g' /f3
for i in {1..10}; do sed -n '1p' /f3 >> /f3; done
sed -i 's/Engineer/engineer/g' /f3
rm /f3

echo "User2 operations completed!"
