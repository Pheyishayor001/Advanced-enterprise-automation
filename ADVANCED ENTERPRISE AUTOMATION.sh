#!/bin/bash

# Creating the /enterprise directory and its subdirectories
echo "Creating /enterprise directory and subdirectories /archive and /temp"
sudo mkdir -p /enterprise/archive
sudo mkdir -p /enterprise/temp

# Moving files older than 30 days to /enterprise/temp
echo "Moving files older than 30 days from /var/log to /enterprise/temp"
if sudo find /var/log -type f -mtime +30 -print0 | sudo xargs -0 -I{} mv {} /enterprise/temp/; then
    echo "Files moved successfully."
else
    echo "No files older than 30 days were found or an error occurred."
fi

# Archiving files and moving the archive to /enterprise/archive
DATE=$(date +%Y%m%d)
ARCHIVE_FILE="/enterprise/archive/old_logs_$DATE.tar.gz"

echo "Creating archive $ARCHIVE_FILE"
if sudo tar -czvf "$ARCHIVE_FILE" -C /enterprise/temp .; then
    echo "Archive created successfully."
else
    echo "An error occurred while creating the archive."
fi

# Cleaning up /enterprise/temp
echo "Cleaning up /enterprise/temp"
sudo rm -rf /enterprise/temp/*

# SYSTEM HEALTH MONITORING
# Defining the threshold percentage
THRESHOLD=80

# Get the disk usage percentage for the root filesystem
USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

# Log file location
LOGFILE="/var/log/enterprise_script.log"

# Checking if usage exceeds the threshold
if [ "$USAGE" -ge "$THRESHOLD" ]; then
    # Logging the warning
    echo "$(date): WARNING: Disk usage is at ${USAGE}%." >> "$LOGFILE"
fi

# Checking CPU load average
# Defining the threshold value
CPU_THRESHOLD=2.0

# Ensure bc is installed
if ! command -v bc &> /dev/null; then
    echo "bc is not installed. Installing bc..."
    sudo apt-get update && sudo apt-get install -y bc
fi

# Get the 1-minute load average
LOAD_AVERAGE=$(uptime | awk -F'load average: ' '{print $2}' | awk '{print $1}')

# Compare the load average with the threshold
if (( $(echo "$LOAD_AVERAGE > $CPU_THRESHOLD" | bc -l) )); then
    # Log the warning
    echo "$(date): WARNING: CPU load average for the past 1 minute is ${LOAD_AVERAGE}." >> "$LOGFILE"
fi

# AUTOMATED REPORTING
# Generate the report
ARCHIVE_COUNT=$(ls /enterprise/archive | wc -l)
REPORT="/var/log/enterprise_report.log"

# Check for permission issues and handle them
if [ ! -w "$REPORT" ]; then
    sudo touch "$REPORT"
    sudo chmod 666 "$REPORT"
fi

{
    echo "Enterprise Automation Report - $(date)"
    echo "----------------------------------"
    echo "Files Archived: $ARCHIVE_COUNT"
    echo "Disk Usage: $USAGE%"
    echo "CPU Load Average: $LOAD_AVERAGE"
} > "$REPORT"

# Send the report via email
EMAIL="admin@example.com"
mail -s "Enterprise Automation Report" $EMAIL < "$REPORT"
