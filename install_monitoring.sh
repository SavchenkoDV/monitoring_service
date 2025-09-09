#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root"
    echo "Please use: sudo ./install_monitoring.sh"
    exit 1
fi

echo "Installing test process monitoring system..."

echo "Creating directories..."
mkdir -p /usr/local/bin
mkdir -p /var/log

echo "Installing monitoring script..."
if [ -f "script.sh" ]; then
    cp script.sh /usr/local/bin/test-monitor.sh
    chmod +x /usr/local/bin/test-monitor.sh
    echo "Monitoring script installed"
else
    echo "ERROR: script.sh not found"
    exit 1
fi

echo "Creating log file..."
touch /var/log/monitoring.log
chmod 666 /var/log/monitoring.log
echo "✓ Log file created"

echo "Installing systemd files..."
if [ -f "test-monitoring.service" ] && [ -f "test-monitoring.timer" ]; then
    cp test-monitoring.service /etc/systemd/system/
    cp test-monitoring.timer /etc/systemd/system/
    echo "✓ Systemd files installed"
else
    echo "ERROR: Systemd files not found"
    exit 1
fi

echo "Starting monitoring system..."
systemctl daemon-reload
systemctl enable test-monitoring.timer
systemctl start test-monitoring.timer

if systemctl is-active --quiet test-monitoring.timer; then
    echo "Monitoring system is running"
    echo ""
    echo "SUCCESS: Installation complete!"
    echo "The monitoring system will check every minute automatically."
else
    echo "ERROR: Failed to start monitoring system"
    exit 1
fi
