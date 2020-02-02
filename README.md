<center>
<h1 align="center">UnraidCloudStorage</h1>
<h4 align="center">Mount rclone cloud storage drives for use in "Sonarr,Radarr,Plex,etc"</h4>
<h5 align="left"><strong>Version 1.0</strong>
</center>

## Info

These are modified scripts from [BinsonBuzz/unraid_rclone_mount](https://github.com/BinsonBuzz/unraid_rclone_mount). The difference is that I setup some variables in the scripts to make it easier to configure and my goal to setup several cloud storage mounts.

### Prerequisites

Install both plugins from "Community Applications Store"
NOTE: These are meant for UNRAID
- Rclone-Beta/Stable [INSTALL](https://forums.unraid.net/topic/51633-plugin-rclone/)
- CA User Scripts [INSTALL](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/)

### Configure Rclone Remotes

- Create your rclone.conf
- I assume most use Google Drive so make sure you create your own client_id [INSTRUCTIONS HERE](https://rclone.org/drive/#making-your-own-client-id)
- Watch Spaceinvador One video for more help [WATCH HERE](https://youtu.be/-b9Ow2iX2DQ)

```
[googledrive]
type = drive
client_id = **********
client_secret = **********
scope = drive
token = {"access_token":"**********"}
server_side_across_configs = true

[googledrive_encrypted]
type = crypt
remote = gdrive:crypt
filename_encryption = standard
directory_name_encryption = true
password = **********
password2 = **********
```

- :heavy_exclamation_mark: Create mountcheck files :heavy_exclamation_mark:
- This is an important step or your mount script will fail
- Open the terminal from Unraid Webui or SSH into your server and run the following:


```
root@unraid:# touch mountcheck
root@unraid:# rclone copy mountcheck googledrive_encrypted: -vv --no-traverse
```

![Mountcheck](screenshots/dashboard.png)

## Rclone Mount Script

- Configure the <strong>cloudstorage_mount</strong> script. You only need to configure the "Set Variables" section

```
#### Set Variables ####
remote="googledrive:" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
vault="unraidshare" # Unraid share name
share="/mnt/user/media/$vault" # Unraid share location
data="/mnt/user/rclonedata/$vault" # Rclone data folder location
#### End Set Variables ####
```
- Set a schedule to run the script (10min - hourly)
- [Crontab Calculator](https://crontab.guru/)

### Rclone Unmount Script

- Configure the <strong>cloudstorage_unmount</strong> script. You only need to configure the "Set Variables" section

```
#### Set Variables ####
vault="unraidshare" # Unraid share name
share="/mnt/user/media/$vault" # Unraid share location
data="/mnt/user/rclonedata/$vault" # Rclone data folder location
#### End Set Variables ####
```
- Set a schedule to run at array startup. Note: I sometimes manually trigger this script to unmount when you need to stop the array as this will make it hang and the solutions are reboot or terminal command "pkill rclone"

### Rclone Upload Script

- Configure the <strong>cloudstorage_upload</strong> script. You only need to configure the "Set Variables" section

```
#### Set Variables ####
remote="googledrive:" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
vault="unraidshare" # Unraid share name
uploadlimit="1.25M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)
share="/mnt/user/media/$vault" # Unraid share location
data="/mnt/user/rclonedata/$vault" # Rclone data folder location
#### End Set Variables ####
```
- Set a schedule to run the script whenever you feel is a good time. For me it is midnight (0 00 * * *)
## Support

I am only a novice when it comes to scripting so for help and support please visit the forum for help

- [Guide: How To Use Rclone To Mount Cloud Drives And Play Files](https://forums.unraid.net/topic/75436-guide-how-to-use-rclone-to-mount-cloud-drives-and-play-files/)
- [Original Scripts](https://github.com/BinsonBuzz/unraid_rclone_mount)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* BinsonBuzz for his super useful scripts :clap:
