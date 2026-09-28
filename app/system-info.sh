#!/bin/bash

mkdir -p ./logs

# Redirect all subsequent stdout and stderr to the log file
exec > >(tee -a "./logs/system-info.log-$(date +%Y-%m-%d_%H-%M-%S)" 2>&1)

echo "System Information"
echo "------------------"
# Display the hostname
echo "Hostname: $(hostname)"
# Display the current user
echo "Current User: $(whoami)"
# Display the date and time
echo "Date and Time: $(date)"
# Display the operating system
echo "Operating System: $(uname -o)"
# Display the kernel version
echo "Kernel Version: $(uname -r)"
# Display the system uptime
echo "System Uptime: $(uptime -p)"
# Display the CPU information
echo "CPU Information: $(lscpu | grep 'Model name' | awk -F: '{print $2}')"
# Display the total memory
echo "Total Memory: $(free -h | grep 'Mem:' | awk '{print $2}')"
# Display the available disk space
echo "Available Disk Space: $(df -h / | awk 'NR==2 {print $4}')"
# Display current working directory
echo "Current Working Directory: $(pwd)"
echo "------------------"
