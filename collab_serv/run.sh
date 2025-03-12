#!/bin/bash

LOG_FILE="/var/cs/run.log"
touch $LOG_FILE

echo "[INFO] $(date) - Container starting..." | tee -a $LOG_FILE

if [ ! -f "/var/cs/.initialized" ]; then
    echo "[INFO] $(date) - First run detected. Running init.sh..." | tee -a $LOG_FILE
    /app/init.sh | tee -a $LOG_FILE
    echo "[INFO] $(date) - Initialization done." | tee -a $LOG_FILE
    touch /var/cs/.initialized
else
    echo "[INFO] $(date) - Already initialized. Running restart.sh..." | tee -a $LOG_FILE
    /app/restart.sh | tee -a $LOG_FILE
fi

echo "[INFO] $(date) - Container started successfully." | tee -a $LOG_FILE

tail -f $LOG_FILE
