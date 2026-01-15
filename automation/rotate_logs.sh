#!/bin/bash

set -o pipefail

LOG_FILE="/var/log/application.log"
ARCHIVE_DIR="/var/log/archive"
RETENTION_DAYS=5
TIMESTAMP=$(date +%Y%m%d%H%M%S)
ARCHIVE_FILE="$ARCHIVE_DIR/application.log.$TIMESTAMP"

# Must run as root
[[ $EUID -ne 0 ]] && exit 1

# Log file missing → safe exit
[[ ! -f "$LOG_FILE" ]] && exit 0

mkdir -p "$ARCHIVE_DIR"

# Copy before truncate to avoid data loss
cp "$LOG_FILE" "$ARCHIVE_FILE" || exit 1

# Truncate without breaking file descriptor
: > "$LOG_FILE"

# Idempotent compression
[[ ! -f "$ARCHIVE_FILE.gz" ]] && gzip "$ARCHIVE_FILE"

# Retention cleanup
find "$ARCHIVE_DIR" -type f -name "application.log.*.gz" -mtime +$RETENTION_DAYS -delete
