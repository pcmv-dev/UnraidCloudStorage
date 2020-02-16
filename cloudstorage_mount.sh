#!/bin/bash

######################
#### Mount Script ####
######################
#### Version 1.2 #####
######################

# CONFIGURE
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
media="unraidshare" # Unraid share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # Unraid share location

#########################################
#### DO NOT EDIT ANYTHING BELOW THIS ####
#########################################

# Create location variables
appdata="/mnt/user/appdata/rclonedata/$media" # Rclone data folder location NOTE: Best not to touch this or map anything here
rcloneupload="$appdata/rclone_upload" # Staging folder of files to be uploaded
rclonemount="$appdata/rclone_mount" # Rclone mount folder
mergerfsmount="$mediaroot/$media" # Media share location

# Create directories
mkdir -p $appdata
mkdir -p $rcloneupload
mkdir -p $rclonemount
mkdir -p $mergerfsmount

# Check if script is already running
echo "------------------"
rclone version
echo "------------------"
echo "INFO: $(date "+%m/%d/%Y %r") - ==== STARTING MOUNT SCRIPT ===="
echo "INFO: $(date "+%m/%d/%Y %r") - Checking if script is already running"
if [ -f "$appdata/rclone_mount_running" ]; then
    echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${media}\"" is already mounted"
    exit
else
    touch $appdata/rclone_mount_running
fi

# Check if rclone mount already created
if [ -f "$rclonemount/mountcheck" ]; then
    echo "WARN: $(date "+%m/%d/%Y %r") - Remote already mounted to rclone mount"
else
    echo "INFO: $(date "+%m/%d/%Y %r") - Mounting remote to \""${rclonemount}\"""
    
    # Create mountcheck file in case it doesn't already exist
    echo "INFO: $(date "+%m/%d/%Y %r") - Recreating mountcheck file for remote"
    echo "==== RCLONE DEBUG ===="
    touch $appdata/mountcheck
    rclone copy $appdata/mountcheck $remote: --no-traverse --log-level INFO
    echo "SUCCESS: $(date "+%m/%d/%Y %r") - Created mountcheck file for remote"
    
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
    $remote: $rclonemount &
    
    # Check if mount successful
    echo "INFO: $(date "+%m/%d/%Y %r") - Mount in progress please wait..."
    sleep 5
    echo "INFO: $(date "+%m/%d/%Y %r") - Proceeding..."
    if [ -f "$rclonemount/mountcheck" ]; then
        echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! remote mounted to rclone mount"
    else
        echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! please check your configuration"
        rm $appdata/rclone_mount_running
        exit
    fi
fi
# Check media share mount
if [ -f "$mergerfsmount/mountcheck" ]; then
    echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${media}\"" is already mounted"
else
    
    # Check if mergerfs already installed
    if [ -f "/bin/mergerfs" ]; then
        echo "INFO: $(date "+%m/%d/%Y %r") - Mergerfs is insatlled, creating mount..."
    else
        echo "INFO: $(date "+%m/%d/%Y %r") - Installing Mergerfs, please wait..."
        # Install mergerfs docker
        docker run -v $appdata/mergerfs:/build --rm trapexit/mergerfs-static-build >/dev/null 2>&1
        mv $appdata/mergerfs /bin
    fi
    
    # Create mergerfs mount
    mergerfsoptions="rw,async_read=false,use_ino,allow_other,func.getattr=newest,category.action=all,category.create=ff,cache.files=partial,dropcacheonclose=true"
    mergerfs $rcloneupload:$rclonemount $mergerfsmount -o $mergerfsoptions >/dev/null 2>&1
    
    # Check if mergerfs mounted correctly
    if [ -f "$mergerfsmount/mountcheck" ]; then
        echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${media}\"" is mounted"
        echo "==== REMOTE DIRECTORIES ===="
        rclone lsd $remote:
        echo "============================"
    else
        echo "ERROR: $(date "+%m/%d/%Y %r") - Check Failed! \""${media}\"" failed to mount, please check your configuration"
        rm $appdata/rclone_mount_running
        exit
    fi
fi
exit
