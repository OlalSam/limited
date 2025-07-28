#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Payara domain path
PAYARA_DOMAIN="/home/olal/server/payara-6.2025.3/payara6/glassfish/domains/testdomain"

# Function to monitor a log file
monitor_log() {
    local log_file=$1
    local color=$2
    local name=$3
    
    echo -e "${color}=== Monitoring $name ===${NC}"
    tail -f "$log_file" | while read line; do
        echo -e "${color}[$name]${NC} $line"
    done
}

# Monitor server.log
monitor_log "$PAYARA_DOMAIN/logs/server.log" "$GREEN" "SERVER" &

# Monitor application specific logs
monitor_log "$PAYARA_DOMAIN/logs/Nganya-1.0.log" "$YELLOW" "APP" &

# Monitor JVM logs
monitor_log "$PAYARA_DOMAIN/logs/jvm.log" "$RED" "JVM" &

# Wait for any process to exit
wait -n

# Kill all background processes on exit
pkill -P $$ 