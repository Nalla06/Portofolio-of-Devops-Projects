#!/bin/bash

# Delete users, groups, and directories
userdel -r user1
userdel -r user2
userdel -r user3
userdel -r user4
userdel -r user5

groupdel app
groupdel aws
groupdel database
groupdel devops

umount /data
rm -rf /data

echo "Cleanup operations completed!"
