<center>
<h1 align="center">UnraidCloudStorage</h1>
<h4 align="center">Mount rclone cloud storage drives for use in "Sonarr,Radarr,Plex,etc"</h4>
<h5 align="Center"><strong>03/03/2020 - Version 1.3</strong>
</center>

## Info

These are modified scripts from [BinsonBuzz/unraid_rclone_mount](https://github.com/BinsonBuzz/unraid_rclone_mount). Scripts are updated from source with some features not included.

### Features Not Used

- Bandwidth Time Limits
- IP Binding
- Docker Autostart
- Backup Job

NOTE: If you need these features please grab the original scripts.

### Prerequisites

Install both plugins from "Community Applications Store"
NOTE: These are meant for UNRAID
- Rclone-Beta (Beta is needed) [INSTALL](https://forums.unraid.net/topic/51633-plugin-rclone/)
- CA User Scripts [INSTALL](https://forums.unraid.net/topic/48286-plugin-ca-user-scripts/)

## Configure Rclone Remotes

- Create your rclone.conf
- I assume most use Google Drive so make sure you create your own client_id [INSTRUCTIONS HERE](https://rclone.org/drive/#making-your-own-client-id)
- Watch Spaceinvador One video for more help [WATCH HERE](https://youtu.be/-b9Ow2iX2DQ)

```bash
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

## Rclone Mount Script

- Configure the **rclone-mount** script. You only need to modify the "CONFIGURE" section

```bash
# CONFIGURE
REMOTE="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
MEDIA="media" # Local share name NOTE: The name you want to give your share mount
MEDIAROOT="/mnt/user" # Local share directory
```
- Set a schedule to run the script 10min, hourly, or when you would like to begin upload
- [Crontab Calculator](https://corntab.com/)

## Rclone Unmount Script

- Configure the **rclone-unmount** script. You only need to modify the "CONFIGURE" section

```bash
# CONFIGURE
media="unraidshare" # Unraid share name NOTE: The name you want to give your share mount
mediaroot="/mnt/user" # Unraid share location
```
- Set a schedule to run at array startup. Note: You can manually trigger the unmount if needed

## Rclone Upload Script

- Configure the **rclone-upload** script. You only need to modify the "CONFIGURE" section

```bash
# CONFIGURE
REMOTE="googledrive" # Name of rclone remote mount NOTE: Choose your encrypted remote for sensitive data
UPLOADREMOTE="googledrive_upload" # If you have a second remote created for uploads put it here. Otherwise use the same remote as REMOTE
MEDIA="media" # Local share name NOTE: The name you want to give your share mount
MEDIAROOT="/mnt/user" # Local share directory
UPLOADLIMIT="75M" # Set your upload speed Ex. 10Mbps is 1.25M (Megabytes/s)

# SERVICE ACCOUNTS
# Drop your .json files in your "appdata/rclonedata/service_accounts"
# Name them "sa_account01.json" "sa_account02.json" etc.
USESERVICEACCOUNT="N" # Y/N. Choose whether to use Service Accounts NOTE: Bypass Google 750GB upload limit
SERVICEACCOUNTNUM="15" # Integer number of service accounts to use.

# DISCORD NOTIFICATIONS
DISCORD_WEBHOOK_URL="" # Enter your Discord Webhook URL for notifications. Otherwise leave empty to disable
DISCORD_ICON_OVERRIDE="https://raw.githubusercontent.com/rclone/rclone/master/graphics/logo/logo_symbol/logo_symbol_color_256px.png" # The poster user image
DISCORD_NAME_OVERRIDE="RCLONE" # The poster user name
```
- Set a schedule to run the script whenever you feel is a good time. For me it is midnight (0 00 * * *)

## Changelog

- v1.3 - Discord Webhook Notifications, Service Accounts
- v1.2 - Code revision and less configuration
- v1.1 - Integrated mountcheck and Logging changes
- v1.0 - Initial Scripts

## Support

I am only a novice when it comes to scripting so for help and support please visit the forum for help

- [Guide: How To Use Rclone To Mount Cloud Drives And Play Files](https://forums.unraid.net/topic/75436-guide-how-to-use-rclone-to-mount-cloud-drives-and-play-files/)
- [Original Scripts](https://github.com/BinsonBuzz/unraid_rclone_mount)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* BinsonBuzz for his super useful scripts :clap:
