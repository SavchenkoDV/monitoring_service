#!/bin/bash

PROCESS_NAME="test"
PROCESS_PATH="/usr/local/bin/test"
MONITORING_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
PID_FILE="/tmp/test_monitor.pid"

write_log() {
    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/monitoring.log"
        chmod 666 "$LOG_FILE" 2>/dev/null
    fi
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

check_server() {
    if curl -s --max-time 10 "$MONITORING_URL" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

current_pid=$(pgrep -f "$PROCESS_PATH" | head -1)

previous_pid=""
if [ -f "$PID_FILE" ]; then
    previous_pid=$(cat "$PID_FILE")
fi

if [ -n "$current_pid" ]; then
    echo "Process $PROCESS_NAME is running with PID: $current_pid"
    
    if [ "$current_pid" != "$previous_pid" ] && [ -n "$previous_pid" ]; then
        write_log "Process $PROCESS_NAME restarted. Old PID: $previous_pid, New PID: $current_pid"
    fi
    
    echo "$current_pid" > "$PID_FILE"
    
    if check_server; then
        write_log "Successfully contacted monitoring server at $MONITORING_URL"
    else
        write_log "Failed to contact monitoring server at $MONITORING_URL"
    fi
    
else
    echo "Process $PROCESS_NAME is not running"
    
    if [ -f "$PID_FILE" ]; then
        rm -f "$PID_FILE"
    fi
fi
