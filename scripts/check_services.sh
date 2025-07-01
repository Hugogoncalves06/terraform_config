#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function check_http() {
  local name=$1
  local url=$2
  if curl -s --max-time 3 "$url" > /dev/null; then
    echo -e "${GREEN}$name is UP at $url${NC}"
  else
    echo -e "${RED}$name is DOWN at $url${NC}"
  fi
}

function check_tcp() {
  local name=$1
  local host=$2
  local port=$3
  if nc -z "$host" "$port"; then
    echo -e "${GREEN}$name is UP at $host:$port${NC}"
  else
    echo -e "${RED}$name is DOWN at $host:$port${NC}"
  fi
}

echo "Checking services..."

# Node.js API
check_http "Node.js API" "http://localhost:8080/health"

# Python API
check_http "Python API" "http://localhost:8000/health"

# MongoDB
check_tcp "MongoDB" "localhost" 27017

# MySQL
check_tcp "MySQL" "localhost" 3306

# Frontend
check_http "Frontend" "http://localhost:3000"

echo "Done." 