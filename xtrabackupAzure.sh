#!/bin/bash

# Define variables
BACKUP_DIR=/var/backups/mysql
DATE=$(date +%Y-%m-%d_%H-%M-%S)
AZURE_ACCOUNT_NAME=<your_account_name>
AZURE_ACCOUNT_KEY=<your_account_key>
AZURE_CONTAINER_NAME=<your_container_name>

# Create backup directory if it does not exist
if [ ! -d $BACKUP_DIR ]; then
  mkdir -p $BACKUP_DIR
fi

# Take full backup
xtrabackup --backup --user=<username> --password=<password> --target-dir=$BACKUP_DIR/full-$DATE

# Take incremental backups every hour
while true
do
  DATE=$(date +%Y-%m-%d_%H-%M-%S)
  xtrabackup --backup --user=<username> --password=<password> --target-dir=$BACKUP_DIR/inc-$DATE --incremental-basedir=$BACKUP_DIR/full-$DATE

  # Sleep for an hour
  sleep 3600
done

# Upload backups to Azure Blob storage
xbcloud put azure $BACKUP_DIR/full-$DATE/ $AZURE_ACCOUNT_NAME $AZURE_CONTAINER_NAME -k $AZURE_ACCOUNT_KEY
xbcloud put azure $BACKUP_DIR/inc-$DATE/ $AZURE_ACCOUNT_NAME $AZURE_CONTAINER_NAME -k $AZURE_ACCOUNT_KEY
