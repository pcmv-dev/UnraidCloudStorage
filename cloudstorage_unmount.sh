#!/bin/bash

########################
#### Unmount Script ####
########################
####  Version 1.0  #####
########################

#### Set Variables ####
vault="unraidshare" # Unraid share name
share="/mnt/user/media/$vault" # Unraid share location
data="/mnt/user/rclonedata/$vault" # Rclone data folder location
#### End Set Variables ####

#### Start unmount script ####
# unmount to be safe
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING UNMOUNT SCRIPT for \""${vault^}\"""
echo "INFO: $(date "+%m/%d/%Y %r") - Unmounting share and rclone mount..."
fusermount -uz $share
fusermount -uz $data/rclone_mount
# Remove empty folders
sleep 3
if [[ "$(ls $share/)" != "" ]]; then
echo "INFO: $(date "+%m/%d/%Y %r") - Removing empty directories in \""$share\"""
rmdir $share/*
else
echo "SUCCESS: $(date "+%m/%d/%Y %r") - No empty directories to remove"
fi
#### End unmount script ####

#### Cleanup tracking files ####
if [[ -f "$data/rclone_mount_running" ]]; then
echo "INFO: $(date "+%m/%d/%Y %r") - Rclone mount file detected, removing tracking file"
rm $data/rclone_mount_running
else
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Rclone mount exited properly"
fi
if [[ -f "$data/rclone_upload_check" ]]; then
echo "INFO: $(date "+%m/%d/%Y %r") - Rclone upload file detected, removing tracking file"
rm $data/rclone_upload_check
else
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Rclone upload exited properly"
fi
#### End cleanup tracking files ####
exit
