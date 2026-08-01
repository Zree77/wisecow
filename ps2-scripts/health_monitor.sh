#!/bin/bash

# System Health Monitoring Script
# Checks CPU, memory, disk, and running processes against thresholds

LOGFILE="health_monitor.log"
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log_alert() {
    echo "[$(timestamp)] ALERT: $1" | tee -a "$LOGFILE"
}

log_info() {
    echo "[$(timestamp)] INFO: $1" | tee -a "$LOGFILE"
}

# --- CPU Usage ---
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)
if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
    log_alert "High CPU usage: ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)"
else
    log_info "CPU usage normal: ${CPU_USAGE}%"
fi

# --- Memory Usage ---
MEM_USAGE=$(free | awk '/Mem/{printf("%.0f"), $3/$2 * 100}')
if [ "$MEM_USAGE" -ge "$MEM_THRESHOLD" ]; then
    log_alert "High memory usage: ${MEM_USAGE}% (threshold: ${MEM_THRESHOLD}%)"
else
    log_info "Memory usage normal: ${MEM_USAGE}%"
fi

# --- Disk Usage (root partition) ---
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    log_alert "High disk usage: ${DISK_USAGE}% (threshold: ${DISK_THRESHOLD}%)"
else
    log_info "Disk usage normal: ${DISK_USAGE}%"
fi

# --- Running Processes Count ---
PROCESS_COUNT=$(ps -e | wc -l)
log_info "Running processes: ${PROCESS_COUNT}"

log_info "Health check completed."
echo "-------------------------------------------"
