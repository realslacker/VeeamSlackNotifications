Param(
	[String]$JobName,
	[String]$Id
)

####################
# Import Functions #
####################
Import-Module "$PSScriptRoot\Helpers"

# Get the config from our config file
$Config = (Get-Content "$PSScriptRoot\config\MSTeamsNotificationConfig.json") -Join "`n" | ConvertFrom-Json

# Should we log?
if($Config.debug_log) {
	Start-Logging "$PSScriptRoot\log\debug.log"
}

# Add Veeam commands
Add-PSSnapin VeeamPSSnapin

# Get the session
$Session = Get-VBRBackupSession | ?{($_.OrigJobName -eq $JobName) -and ($Id -eq $_.Id.ToString())}

# Wait for the session to finish up
while ($Session.IsCompleted -eq $false) {
	Write-LogMessage 'Info' 'Session not finished Sleeping...'
	Start-Sleep -Milliseconds 200
	$session = Get-VBRBackupSession | ?{($_.OrigJobName -eq $JobName) -and ($Id -eq $_.Id.ToString())}
}

# build our MessageCard
$TeamsJSON = @{
    '@type'      = 'MessageCard'
    '@content'   = 'http://schema.org/extensions'
    'themeColor' = '54B948'
    'text'       = "Veeam Backup Job '$JobName' completed with status '$Status'"
    'sections'   = @(
        @{
            'activityTitle'    = "Veeam Backup Job '$JobName' completed with status '$Status'"
            'activitySubtitle' = (Get-Date).ToString()
            'markdown'         = $true
            'facts'            = @(
                @{ 'name' = 'Job Name';       'value' = $session.Name                      },
                @{ 'name' = 'Job Type';       'value' = $session.JobTypeString             },
                @{ 'name' = 'Duration';       'value' = Convert-TimeSpanToHuman $Session.Info.Progress.Duration },
                @{ 'name' = 'Backup Size';    'value' = Convert-BytesToHuman -Bytes $session.BackupStats.BackupSize },
                @{ 'name' = 'Data Size';      'value' = Convert-BytesToHuman -Bytes $session.BackupStats.DataSize   },
                @{ 'name' = 'Dedup Ratio';    'value' = [String]$session.BackupStats.DedupRatio    },
                @{ 'name' = 'Compress Ratio'; 'value' = [String]$session.BackupStats.CompressRatio },
                @{ 'name' = 'Status';         'value' = [string]$session.Result                    }
            )
        }
    )
}

$TeamsJSON | ConvertTo-Json -Depth 5

return

# Build the web request
$Params = @{
    Uri         = 'https://outlook.office.com/webhook/7aa7ff76-133a-4b14-a4fc-13002b3d78c8@3cad78c0-165a-40df-8a09-0e50742a2d1b/IncomingWebhook/e40125d29b1d4fdf906610c5bd94a1f8/4235b79f-88b5-4519-bb08-ac5d861c6b2f'
    Method      = 'Post'
    Headers     = @{'accept'='application/json'}
    Body        = $TeamsJSON | ConvertTo-Json -Depth 5
}

# Send It
$Request = Invoke-RestMethod @Params
