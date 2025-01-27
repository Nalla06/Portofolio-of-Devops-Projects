#!/bin/bash

# Create, attach, and manage EBS volume
aws ec2 create-volume --size 5 --availability-zone <AZ>
aws ec2 attach-volume --volume-id <VolumeID> --instance-id <InstanceID> --device /dev/xvdf

mkfs.ext4 /dev/xvdf
mount /dev/xvdf /data
df -h
touch /data/f1

echo "AWS EBS operations completed!"
