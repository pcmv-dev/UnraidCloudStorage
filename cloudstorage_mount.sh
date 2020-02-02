#!/bin/bash

######################
#### Mount Script ####
######################
#### Version 1.0 #####
######################

#### Set Variables ####
remote="googledrive:" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
vault="unraidshare" # Unraid share name
share="/mnt/user/media/$vault" # Unraid share location
data="/mnt/user/rclonedata/$vault" # Rclone data folder location
#### End Set Variables ####

#### Check if script is already running ####
sleep 1
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING MOUNT SCRIPT for \""${vault^}\"""
echo "INFO: $(date "+%m/%d/%Y %r") - Checking if script is already running"
if [[ -f "$data/rclone_mount_running" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault^}\"" is already mounted"
exit
else
touch $data/rclone_mount_running
fi
#### End check if script is already running ####

# Create directories
mkdir -p $data # Rclone data folder
mkdir -p $data/mergerfs # Mergerfs data folder
mkdir -p $data/rclone_mount # Rclone data folder
mkdir -p $data/rclone_upload # Staging folder of files to be uploaded
mkdir -p $share # Unraid share folder

#### Start rclone mount ####
# Check if rclone mount already created
if [[ -f "$data/rclone_mount/mountcheck" ]]; then
echo "WARN: $(date "+%m/%d/%Y %r") - Remote already mounted to rclone mount"
else
echo "INFO: $(date "+%m/%d/%Y %r") - Mounting remote to \""$data/rclone_mount\"""

# Rclone mount command and flags
rclone mount \
--allow-other \
--buffer-size 256M \
--dir-cache-time 720h \
--drive-chunk-size 512M \
--log-level INFO \
--vfs-read-chunk-size 128M \
--vfs-read-chunk-size-limit off \
--vfs-cache-mode writes \
$remote $data/rclone_mount &

# Check if mount successful with slight pause to give mount time to finalise
echo "INFO: $(date "+%m/%d/%Y %r") - Mount in progress please wait..."
sleep 5
echo "INFO: $(date "+%m/%d/%Y %r") - Proceeding..."
if [[ -f "$data/rclone_mount/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! remote mounted to rclone mount"
else
echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! please check your configuration"
rm $data/rclone_mount_running
exit
fi
fi
#### End rclone mount ####

#### Start share mount ####
if [[ -f "$share/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! MERGERFS is already mounted"
else
echo "INFO: $(date "+%m/%d/%Y %r") - Please wait while MERGERFS is installed, this can take a while"
# Build mergerfs binary and delete old binary as precaution
rm /bin/mergerfs
# Create Docker
docker run -v $data/mergerfs:/build --rm trapexit/mergerfs-static-build > /dev/null 2>&1
# Move to bin to use for commands
mv $data/mergerfs/mergerfs /bin
# Create mergerfs mount
mergerfs $data/rclone_upload:$data/rclone_mount $share -o rw,async_read=false,use_ino,allow_other,func.getattr=newest,category.action=all,category.create=ff,cache.files=partial,dropcacheonclose=true
if [[ -f "$share/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault^}\"" is mounted"
else
echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! \""${vault^}\"" failed to mount, please check your configuration"
rm $data/rclone_mount_running
exit
fi
fi
#### End share mount ####
exit
