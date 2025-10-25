# Process Monitoring System

This is an automatic system for Linux. It checks if your process is running and sends status to a monitoring server.

## What does it do?

This project helps you monitor your processes. It can:

- 🔍 **Check if process is running** - it looks for your process on the system
- 📊 **Save logs** - it writes all checks and changes to a log file
- 🔄 **Detect restarts** - it knows when your process restarts (PID changes)
- 🌐 **Send data to server** - it sends HTTP requests to your monitoring server
- ⏰ **Work automatically** - it checks every minute using systemd timer

## Project Files

This project has 4 files:

1. **script.sh** - main monitoring script that checks the process
2. **test-monitoring.service** - systemd service file to run the script
3. **test-monitoring.timer** - systemd timer file for automatic running
4. **install_monitoring.sh** - installation script (makes setup easy)

## What you need

- **OS**: Linux with systemd (Ubuntu, Debian, CentOS, Fedora, etc.)
- **Access**: root user access for installation
- **Programs**: 
  - `bash`
  - `curl` (for sending requests to monitoring server)
  - `systemd` (for automatic running)

## How to Install

### Step 1: Download the project

```bash
git clone <repository-url>
cd monitoring_service
```

### Step 2: Edit settings

Before installation, open file `script.sh` and change these settings:

```bash
PROCESS_NAME="test"                                    # Name of your process
PROCESS_PATH="/usr/local/bin/test"                     # Full path to your process
MONITORING_URL="https://test.com/monitoring/test/api"  # URL of your monitoring server
LOG_FILE="/var/log/monitoring.log"                     # Path to log file
```

### Step 3: Run installation

```bash
sudo ./install_monitoring.sh
```

The installation script will do everything for you:
- Create needed directories
- Copy monitoring script to `/usr/local/bin/test-monitor.sh`
- Create log file `/var/log/monitoring.log`
- Install systemd service and timer files
- Start the monitoring system

## How to Use

### Check if system is working

```bash
# Check if timer is running
sudo systemctl status test-monitoring.timer

# Check last service runs
sudo systemctl status test-monitoring.service
```

### View logs

```bash
# View log file
sudo tail -f /var/log/monitoring.log

# View systemd logs
sudo journalctl -u test-monitoring.service -f
```

### Control the system

```bash
# Stop monitoring
sudo systemctl stop test-monitoring.timer

# Start monitoring
sudo systemctl start test-monitoring.timer

# Restart monitoring
sudo systemctl restart test-monitoring.timer

# Disable automatic start on boot
sudo systemctl disable test-monitoring.timer

# Enable automatic start on boot
sudo systemctl enable test-monitoring.timer
```

### Run check manually

```bash
# Run check by hand
sudo /usr/local/bin/test-monitor.sh

# Or use systemd
sudo systemctl start test-monitoring.service
```

## How does it work?

Here is what happens:

1. **Systemd Timer** starts when your computer boots. It runs every minute.
2. **Systemd Service** runs the monitoring script each time the timer activates.
3. **Monitoring Script** does these things:
   - Looks for the process by name and path
   - Compares current PID with previous PID (saved in `/tmp/test_monitor.pid`)
   - Writes to log if process restarted (PID changed)
   - Sends HTTP request to monitoring server
   - Writes results to log file

## Log Format

The logs look like this:

```
2025-10-25 14:30:45 - Process test restarted. Old PID: 1234, New PID: 5678
2025-10-25 14:30:45 - Successfully contacted monitoring server at https://test.com/monitoring/test/api
2025-10-25 14:31:45 - Failed to contact monitoring server at https://test.com/monitoring/test/api
```

## How to Uninstall

If you want to remove this system:

```bash
# Stop and disable timer
sudo systemctl stop test-monitoring.timer
sudo systemctl disable test-monitoring.timer

# Delete systemd files
sudo rm /etc/systemd/system/test-monitoring.service
sudo rm /etc/systemd/system/test-monitoring.timer

# Delete script
sudo rm /usr/local/bin/test-monitor.sh

# Delete PID file
sudo rm /tmp/test_monitor.pid

# Reload systemd
sudo systemctl daemon-reload
```

You can keep the log file or delete it:
```bash
sudo rm /var/log/monitoring.log
```

## Setup for Different Process

If you want to monitor a different process:

1. Edit file `script.sh`:
   - Change `PROCESS_NAME` to your process name
   - Change `PROCESS_PATH` to your process path
   - Change `MONITORING_URL` to your server URL

2. Install again:
```bash
sudo systemctl stop test-monitoring.timer
sudo ./install_monitoring.sh
```

## Change Check Time

By default, the system checks every minute. To change this:

1. Edit file `test-monitoring.timer`
2. Change line `OnUnitActiveSec` (for example, `5min` for 5 minutes)
3. Install again:
```bash
sudo cp test-monitoring.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl restart test-monitoring.timer
```

## Problems and Solutions

### System does not start

```bash
# Check errors in systemd logs
sudo journalctl -xe -u test-monitoring.timer
sudo journalctl -xe -u test-monitoring.service
```

### Cannot write to log file

If there are problems writing to `/var/log/monitoring.log`, the script will automatically use `/tmp/monitoring.log`.

### Process not found

Make sure that:
- `PROCESS_PATH` is correct path to your process file
- Your process is really running: `ps aux | grep <process_name>`

## Security Notes

- System runs as root user (needs this for system access)
- Log files can be read by all users (chmod 666)
- HTTP requests have no authentication (you can add it if you need)

## License

This project is open-source.

## Author

Dmitrii Savchenko

---

📝 **Important**: Remember to change settings in `script.sh` before installation!

