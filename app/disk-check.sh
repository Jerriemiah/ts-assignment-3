#!/bin/bash

# Disk Usage Check Script
# This script checks the disk usage of the root filesystem and reports if it exceeds a specified threshold 
# Usage: ./disk-check.sh <threshold_percentage> [path]

mkdir -p ./logs
# Redirect all subsequent stdout and stderr to the log file

exec > >(tee -a "./logs/disk-check.log") 2>&1
echo "===== Disk check started: $(date '+%Y-%m-%d %H:%M:%S') ====="

echo "______________________________"
echo "Disk Usage percentage"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <threshold_percentage> [path]"
    exit 2
fi

threshold=$1

if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
    echo "Error: Threshold must be a positive integer"
    exit 2
fi

if [ "$threshold" -lt 1 ] || [ "$threshold" -gt 100 ]; then
    echo "Error: Threshold must be between 1 and 100"
    exit 2
fi

path=${2:-/}  # Default to filesystem if no path is provided
disk_usage=$(df -h "$path" | awk 'NR==2 {print $5}' | sed 's/%//')
echo "Current disk usage of filesystem: $disk_usage%"

if [[ "$disk_usage" -lt "$threshold" ]]; then
    echo "Info: Current disk usage is below the provided threshold"
    exit 0
elif [[ "$disk_usage" -eq "$threshold" ]]; then
    echo "Info: Current disk usage is equal to the provided threshold"
    exit 0
else
    echo "Info: Current disk usage is above the provided threshold"
    exit 0
fi
