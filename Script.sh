#!/bin/bash

# Step 1: Identify user
USER_NAME=$(whoami)
echo "Script run by: $USER_NAME"

# Step2: Create log directory and save daily log
LOG_DIR=/home/nongshim/Documents/dailylogs
mkdir -p "$LOG_DIR"

LOGFILE="$LOG_DIR/log_$(date +%Y-%m-%d).txt"

{
  echo "User: $USER_NAME"
  echo "Date: $(date)"
  echo "Uptime:"
  uptime
  echo "Top 5 CPU processes:"
  ps -eo pid,comm,%mem,%cpu --sort=-%cpu | head -n 6
  echo "Disk usage:"
  df -h
} > "$LOGFILE"

echo "Daily log saved: $LOGFILE"

# Step 3: Weekly archive (on Monday) 
ARCHIVE_DIR=/home/nongshim/Documents/dailylogs/archive
mkdir -p "$ARCHIVE_DIR"

DAY_OF_WEEK=$(date +%u)  # 1 = Monday
if [ "$DAY_OF_WEEK" -eq 1 ]; then
  tar -czf "$ARCHIVE_DIR/weeklylogs_$(date +%Y-%m-%d).tar.gz" -C "$LOG_DIR" .
  echo "Weekly archive created."
fi

# --- Step 4: Move logs older than 7 days ---
for file in "$LOG_DIR"/log_*.txt; do
  if [ -f "$file" ] && [ $(find "$file" -mtime +7) ]; then
    mv "$file" "$ARCHIVE_DIR/"
    echo "Moved $file to archive"
  fi
done

# Menu for manual operations---
echo ""
echo "Select an option:"
echo "1) Archive all logs manually"
echo "2) Move logs older than 7 days manually"
echo "3) View latest log"
echo "4) Exit"
read -p "Enter your choice (1-4): " choice

case $choice in
  1)
    echo "Archiving all logs..."
    tar -czf "$ARCHIVE_DIR/manual_archive_$(date +%Y-%m-%d).tar.gz" -C "$LOG_DIR" .
    echo "Manual archive created."
    ;;
  2)
    echo "Moving logs older than 7 days to archive..."
    for file in "$LOG_DIR"/log_*.txt; do
      if [ -f "$file" ] && [ $(find "$file" -mtime +7) ]; then
        mv "$file" "$ARCHIVE_DIR/"
        echo "Moved $file to archive"
      fi
    done
    ;;
  3)
    echo "Latest log content:"
    cat "$LOGFILE"
    ;;
  4)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "I
