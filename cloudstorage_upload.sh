#!/bin/bash

#######################
#### Upload Script ####
#######################
####  Version 1.0  ####
#######################

#### Set Variables ####
remote="googledrive:" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
vault="unraidshare" # Unraid share name
uploadlimit="1.25M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)
share="/mnt/user/media/$vault" # Unraid share location
data="/mnt/user/rclonedata/$vault" # Rclone data folder location
#### End Set Variables ####

#### Check if script is already running ####
echo "INFO: $(date "+%m/%d/%Y %r") - STARTING UPLOAD SCRIPT for \""${vault^}\"""
if [[ -f "$data/rclone_upload_check" ]]; then
echo "WARN: $(date "+%m/%d/%Y %r") - Upload already in progress!"
exit
else
touch $data/rclone_upload_check
fi
#### End Check if script is already running ####

#### Check if rclone mount created ####
if [[ -f "$data/rclone_mount/mountcheck" ]]; then
echo "SUCCESS: $(date "+%m/%d/%Y %r") - Check Passed! \""${vault^}\"" is mounted, proceeding with upload."
else
echo "ERROR: $(date "+%m/%d/%Y %X") - Check Failed! \""${vault^}\"" please check your configuration"
rm $data/rclone_upload_check
exit
fi
#### End check if rclone mount created ####

#### Rclone upload flags ####
rclone move $data/rclone_upload/ $remote -vv \
--drive-chunk-size 512M \
--checkers 3 \
--transfers 2 \
--order-by modtime,ascending \
--exclude downloads/** \
--exclude *fuse_hidden* \
--exclude *_HIDDEN \
--exclude .recycle** \
--exclude *.backup~* \
--exclude *.partial~*  \
--delete-empty-src-dirs \
--bwlimit $uploadlimit \
--tpslimit 3 \
--min-age 30m

# Cleanup tracking files
rm $data/rclone_upload_check
#### End rclone upload ####
exit
