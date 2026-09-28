#!/bin/bash

# network connection check script
# This script checks the network connection by pinging a specified host and reports if the connection is successful or not.
# Usage: ./network-check.sh <hostname-or-ip> [port]

mkdir -p ./logs

# Redirect all subsequent stdout and stderr to the log file
exec > >(tee -a "./logs/network-check.log-$(date +%Y-%m-%d_%H-%M-%S)" 2>&1)

REGEX_IP="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
REGEX_HOSTNAME="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <hostname-or-ip> [port]"
    exit 2
fi

host=$1

if [[ ! "$host" =~ $REGEX_IP ]] && [[ ! "$host" =~ $REGEX_HOSTNAME ]]; then
    echo "Error: Invalid hostname or IP address"
    exit 2
fi

lookup=$(dig "$host" +short 2>/dev/null | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
if [[ -n "$lookup" ]]; then
    echo "Resolving hostname $host to IP address: $lookup"
    echo "__________________________________________________________"
    echo "Resolved lookup for $host: $lookup"
elif [[ -z "$lookup" ]]; then
    lookup=$(getent hosts "$host" | awk '{ print $1 }')
    echo "Resolved lookup for $host: $lookup"
else
    echo "Error: Unable to resolve hostname $host"
    exit 2
fi

echo ""

echo "_____________Checking network connection to $host ...____________"
echo "Pinging $host ..."
ping=$(ping -c 2 "$host" >/dev/null 2>&1 && echo "Success" || echo "Failed")
echo "Ping result: $ping"

if [[ "$ping" == "Success" ]]; then
    echo "Network connection to $host is successful."
else
    echo "Network connection to $host failed."
    exit 1
fi

echo ""

echo "__________Network Interface Information:__________"
ifconfig_output=$(ifconfig 2>/dev/null)
if [[ -n "$ifconfig_output" ]]; then
    echo "$ifconfig_output"
else
    echo "Error: Unable to retrieve network interface information."
fi

echo "Ping localhost (127.0.0.1):"
ping -c 2 127.0.0.1 >/dev/null 2>&1 && echo "Success" || echo "Failed"

echo ""

port=${2:-}

if [[ -n "$port" ]]; then
    if [[ ! "$port" =~ ^[0-9]+$ ]]; then
        echo "Error: Port must be a positive integer"
        exit 2
    fi

    if [[ "$port" -lt 1 ]] || [[ "$port" -gt 65535 ]]; then
        echo "Error: Port must be between 1 and 65535"
        exit 2
    fi
fi

if [[ -n "$port" ]]; then
    echo "__________Port Check:__________"
    echo "Checking port $port on $host..."
    nc -zv "$host" "$port" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo "TCP connection to $host on port $port is successful."
        echo "Port $port on $host is open."
    else
        echo "TCP connection to $host on port $port failed."
        echo "Port $port on $host is closed or unreachable."
    fi
fi

