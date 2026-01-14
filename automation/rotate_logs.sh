#!/bin/bash

# ==============================================================================
# Script Name: rotate_logs.sh
# Description: Rotates, compresses, and cleans up logs for application.log
# Requirements: Must be run with sudo/root permissions for /var/log access
# ==============================================================================

# Configuration
LOG_FILE="/var/log/application.log"
BACKUP_DIR="/var/log/archive"
RETENTION_DAYS=5
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# 1. Handle Edge Case: Permission Check
if [[ $EUID -ne 0 ]]; then
   echo "[$(date)] ERROR: This script must be run as root/sudo."
   exit 1
fi

# 2. Handle Edge Case: Log file not present
if [ ! -f "$LOG_FILE" ]; then
    echo "[$(date)] WARNING: $LOG_FILE not found. Nothing to rotate."
    exit 0
fi

# Create archive directory if it doesn't exist (Idempotent behavior)
mkdir -p "$BACKUP_DIR"

# 3. Rotate and Compress
# Logic: 'copytruncate' strategy. 
# We copy the content to a new file and then truncate the original.
# This ensures the application continues writing without interruption or file handle errors.
echo "[$(date)] INFO: Rotating $LOG_FILE..."
cp "$LOG_FILE" "$BACKUP_DIR/application.log.$TIMESTAMP"
cat /dev/null > "$LOG_FILE"

# Compress the archived log
gzip "$BACKUP_DIR/application.log.$TIMESTAMP"
echo "[$(date)] INFO: Archive created at $BACKUP_DIR/application.log.$TIMESTAMP.gz"

# 4. Retention Policy: Remove logs older than 5 days
echo "[$(date)] INFO: Cleaning up logs older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -maxdepth 1 -name "application.log.*.gz" -mtime +$RETENTION_DAYS -type f -delete

echo "[$(date)] INFO: Log rotation cycle complete."
