#!/bin/bash

# Find files and perform maintenance
find / -name 'f3'
find / -type f | wc -l
tail -n 1 /etc/passwd

echo "Root operations completed!"
