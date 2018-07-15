# Veeam Backup and Restore Notification for Microsoft Teams

Sends notifications from Veeam Backup & Restore to Microsoft Teams

![Chat Example](https://raw.githubusercontent.com/realslacker/VeeamTeamsNotifications/master/asset/img/screens/example-notification.png)


This is a fork of [Veeam Slack Notifications](https://github.com/TheSageColleges/VeeamSlackNotifications) by [TheSageColleges](https://github.com/TheSageColleges).

---

## Setup

Make a scripts directory such as: `C:\Scripts`

```powershell
# To make the directory run the following command in PowerShell
New-Item -Path C:\Scripts -Type Directory
```

#### Clone or Download

To clone with Git:

```powershell
cd C:\Scripts
git clone https://github.com/realslacker/VeeamTeamsNotifications.git
```

Without Git:

Download the repo, then extract to `VeeamTeamsNotifications`.
```powershell
# GitHub requires TLS v1.2, so enable before downloading
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Grab the file
Invoke-WebRequest -Uri https://github.com/realslacker/VeeamTeamsNotifications/archive/master.zip -OutFile C:\Scripts\VeeamTeamsNotifications.zip
# Unzip the archive
Expand-Archive -Path C:\Scripts\VeeamTeamsNotifications.zip -DestinationPath C:\Scripts\
# Rename the extracted folder
Move-Item -Path C:\Scripts\VeeamTeamsNotifications-master C:\Scripts\VeeamTeamsNotifications

```

Configure the project:

```powershell
# Copy the default configuration file
Copy-Item -Path C:\Scripts\VeeamTeamsNotifications\config\VeeamTeamsNotificationConfig.example.json -Destination C:\Scripts\VeeamTeamsNotifications\config\VeeamTeamsNotificationConfig.json
# Configure the Webhook URI
$Config = Get-Content -Path "C:\Scripts\VeeamTeamsNotifications\config\VeeamTeamsNotificationConfig.json" -Raw | ConvertFrom-Json
$Config.WebhookURI = Read-Host "Enter your fully qualified webhook URI"
$Config | ConvertTo-Json | Set-Content -Path "C:\Scripts\VeeamTeamsNotifications\config\VeeamTeamsNotificationConfig.json"

```

Finally open Veeam and configure your jobs. Edit each job, going to the storage section and clicking on the **Advanced** button.

![Edit Job Screenshot](https://raw.githubusercontent.com/realslacker/VeeamTeamsNotifications/master/asset/img/screens/backup-storage-screen.png)

Navigate to the "Scripts" tab and paste the following line the script that runs after the job is completed:

```shell
powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\VeeamTeamsNotifications\Start-VeeamTeamsNotification.ps1
```

![Advanced Settings - Scripts Screenshot](https://raw.githubusercontent.com/realslacker/VeeamTeamsNotifications/master/asset/img/screens/backup-advanced-settings.png)

---

## Example Configuration:

Below is an example configuration file.

```shell
{
	"WebhookURI"  : "https://outlook.office.com/webhook/...",
	"DebugEnable" : false,
	"DebugPath"   : "./log/debug.log"
}
```
