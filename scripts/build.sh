#!/usr/bin/env bash

# Find the absolute path of the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build using the directory one level up as the context
docker build -t devops-tool "$SCRIPT_DIR/../"

