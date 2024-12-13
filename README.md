# Enterprise Automation Script

## Overview

This Bash script automates system maintenance tasks, including file archiving, system health monitoring, and report generation.

## Features

- Directory Setup: Creates /enterprise with subdirectories /archive and /temp.
- File Management: Moves log files older than 30 days from /var/log to /enterprise/temp.
- File Archiving: Compresses files in /enterprise/temp into a .tar.gz archive stored in /enterprise/archive.
- System Health Monitoring:  
    \- Logs warnings if disk usage exceeds 80%.  
    \- Logs warnings if CPU load exceeds 2.0.
- Automated Reporting: Generates a report summarizing archived files, disk usage, and CPU load average.

## Prerequisites

- Permissions: Requires sudo privileges.
- Dependencies: Ensure bc is installed:  
    sudo apt-get update && sudo apt-get install -y bc

## Usage

1. Make the script executable:  
    chmod +x enterprise_automation.sh
2. Run the script with sudo:  
    sudo ./enterprise_automation.sh

## Output

- Archive Files: Saved in /enterprise/archive with filenames like old_logs_YYYYMMDD.tar.gz.
- Logs:  
    \- Warnings are logged to /var/log/enterprise_script.log.  
    \- A summary report is generated at /var/log/enterprise_report.log.

## Notes

Default thresholds:  
\- Disk usage: 80%  
\- CPU load: 2.0  
Modify these thresholds in the script as needed.
