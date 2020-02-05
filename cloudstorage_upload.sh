#!/bin/bash

#######################
#### Upload Script ####
#######################
####  Version 1.1  ####
#######################

#### Set Variables ####
remote="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
vault="unraidshare" # Unraid share name
uploadlimit="1.25M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)
share="/mnt/user/$vault" # Unraid share location
data="/mnt/user/rclonedata/$vault" # Rclone data folder location
#### End Set Variables ####

# Show installed Rclone version
echo "#### RCLONE VERSION ####"
echo
rclone version
echo
echo "########################"
echo
#### Check if script is already running ####
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING UPLOAD SCRIPT for \""${vault}\"""
if [[ -f "$data/rclone_upload_running" ]]; then
echo "WARN: $(date "+%m/%d/%Y %r") - Upload already in progress!"
echo
exit
else
touch $data/rclone_upload_running
fi
#### End Check if script is already running ####

#### Check if rclone mount created ####
if [[ -f "$data/rclone_mount/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault}\"" is mounted, proceeding with upload"
else
echo "ERROR: $(date "+%m/%d/%Y %X") - Check Failed! \""${vault}\"" is not mounted, please check your configuration"
rm $data/rclone_upload_running
echo
exit
fi
#### End check if rclone mount created ####

#### Rclone upload flags ####
echo "#### RCLONE DEBUG ####"
echo
rclone move $data/rclone_upload/ $remote: \
--log-level INFO \
--buffer-size 512M \
--drive-chunk-size 512M \
--tpslimit 3 \
--checkers 3 \
--transfers 2 \
--order-by modtime,ascending \
--exclude downloads/** \
--exclude .Recycle.Bin/** \
--exclude *fuse_hidden* \
--exclude *_HIDDEN \
--exclude .recycle** \
--exclude *.backup~* \
--exclude *.partial~*  \
--delete-empty-src-dirs \
--bwlimit $uploadlimit \
--min-age 10m
echo "######################"

# Cleanup tracking files
rm $data/rclone_upload_running
echo "SUCCESS: $(date "+%m/%d/%Y %X") - Upload Complete"
#### End rclone upload ####
echo
exit
