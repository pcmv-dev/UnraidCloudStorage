#!/bin/bash

######################
#### Mount Script ####
######################
#### Version 1.1 #####
######################

#### Set Variables ####
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
vault="unraidshare" # Unraid share name NOTE: The name you want to give your share
share="/mnt/user/$vault" # Unraid share location NOTE: This is where you point "Sonarr,Radarr,Plex,etc" for media
data="/mnt/user/rclonedata/$vault" # Rclone data folder location NOTE: Best not to touch this or map anything here
#### End Set Variables ####

# Show installed Rclone version
echo "#### RCLONE VERSION ####"
echo
rclone version
echo
echo "########################"
echo
#### Check if script is already running ####
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING MOUNT SCRIPT for \""${vault}\"""
echo "INFO: $(date "+%m/%d/%Y %r") - Checking if script is already running"
if [[ -f "$data/rclone_mount_running" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault}\"" is already mounted"
echo
exit
else
touch $data/rclone_mount_running
fi
#### End check if script is already running ####

# Create directories
mkdir -p $data # Rclone data folder
mkdir -p $data/mergerfs # Mergerfs data folder
mkdir -p $data/rclone_mount # Rclone mount folder
mkdir -p $data/rclone_upload # Staging folder of files to be uploaded
mkdir -p $share # Unraid share folder

#### Start rclone mount ####
# Check if rclone mount already created
if [[ -f "$data/rclone_mount/mountcheck" ]]; then
echo "WARN: $(date "+%m/%d/%Y %r") - Remote already mounted to rclone mount"
else
echo "INFO: $(date "+%m/%d/%Y %r") - Mounting remote to \""$data/rclone_mount\"""

# Creating mountcheck file in case it doesn't already exist
echo "INFO: $(date "+%m/%d/%Y %r") - Recreating mountcheck file for \""${remote}\"" remote"
echo "#### RCLONE DEBUG ####"
echo
touch mountcheck
rclone copy mountcheck $remote: --no-traverse --log-level INFO
echo "######################"
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Created mountcheck file for \""${remote}\"" remote"

# Rclone mount command and flags
rclone mount \
--log-level ERROR \
--allow-other \
--buffer-size 256M \
--dir-cache-time 720h \
--drive-chunk-size 512M \
--vfs-read-chunk-size 128M \
--vfs-read-chunk-size-limit off \
--vfs-cache-mode writes \
$remote: $data/rclone_mount &

# Check if mount successful
echo "INFO: $(date "+%m/%d/%Y %r") - Mount in progress please wait..."
sleep 5
echo "INFO: $(date "+%m/%d/%Y %r") - Proceeding..."
if [[ -f "$data/rclone_mount/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! remote mounted to rclone mount"
else
echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! please check your configuration"
rm $data/rclone_mount_running
echo
exit
fi
fi
#### End rclone mount ####

#### Start share mount ####
if [[ -f "$share/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! MERGERFS is already mounted"
else
# Check if mergerfs already installed
if [[ -f "/bin/mergerfs" ]]; then
echo "INFO: $(date "+%m/%d/%Y %r") - MERGERFS already installed, proceeding to create mount"
else
echo "INFO: $(date "+%m/%d/%Y %r") - Please wait while MERGERFS is installed, this can take a while"
# Create Docker
docker run -v $data/rclone:/build --rm trapexit/mergerfs-static-build > /dev/null 2>&1
mv $data/mergerfs /bin
fi
# Create mergerfs mount
mergerfs $data/rclone_upload:$data/rclone_mount $share -o rw,async_read=false,use_ino,allow_other,func.getattr=newest,category.action=all,category.create=ff,cache.files=partial,dropcacheonclose=true
if [[ -f "$share/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault}\"" is mounted"
echo
echo "#### REMOTE DIRECTORIES ####"
rclone lsd $remote:
echo "############################"
echo
else
echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! \""${vault}\"" failed to mount, please check your configuration"
rm $data/rclone_mount_running
echo
exit
fi
fi
#### End share mount ####
echo
exit
