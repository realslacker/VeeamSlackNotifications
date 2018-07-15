[CmdletBinding()]
param(
	
    [Parameter(Mandatory)]
    [string]
    $OrigJobName,

	[Parameter(Mandatory)]
    [string]
    $Id
)

# Import Helper Functions
Import-Module "$PSScriptRoot\Helpers"


# Get the config from our config file
$Config = Get-Content -Path "$PSScriptRoot\config\VeeamTeamsNotificationConfig.json" -Raw | ConvertFrom-Json


# Should we log?
if( $Config.DebugEnable ) {

	Start-Logging -Path $Config.DebugPath

}


# Add Veeam commands
Add-PSSnapin VeeamPSSnapin


# Get the Veeam session
$Session = Get-VBRBackupSession |
    Where-Object { $_.OrigJobName -eq $OrigJobName -and $_.Id -eq $Id }


# Wait for the session to finish up
while ( -not $Session.IsCompleted ) {

	Write-LogMessage 'Info' 'Session not finished Sleeping...'

	Start-Sleep -Milliseconds 200

	$Session = Get-VBRBackupSession |
        Where-Object { $_.OrigJobName -eq $OrigJobName -and $_.Id -eq $Id }

}


# calculate success/warning/error counts
$TaskSessions  = $Session.GetTaskSessions()
$SuccessCount  = ( $TaskSessions | Where-Object Status -eq 'Success' ).Count
$WarningCount  = ( $TaskSessions | Where-Object Status -eq 'Warning' ).Count
$FailureCount  = ( $TaskSessions | Where-Object Status -eq 'Failed'  ).Count


# setup variables
$SuccessFormat = if ( $SuccessCount ) { '{0} {1}' } else { '{0}' }
$SuccessIcon   = '![Success Image](https://raw.githubusercontent.com/realslacker/VeeamTeamsNotifications/master/asset/img/icon/success.png)'

$WarningFormat = if ( $WarningCount ) { '{0} {1}' } else { '{0}' }
$WarningIcon   = '![Warning Image](https://raw.githubusercontent.com/realslacker/VeeamTeamsNotifications/master/asset/img/icon/warning.png)'

$FailureFormat = if ( $FailureCount ) { '{0} {1}' } else { '{0}' }
$FailureIcon   = '![Failure Image](https://raw.githubusercontent.com/realslacker/VeeamTeamsNotifications/master/asset/img/icon/error.png)'

$Duration      = Convert-TimeSpanToHuman $Session.Progress.Duration
$Rate          = '{0}/s' -f (Convert-BytesToHuman $Session.Progress.AvgSpeed)
$Bottleneck    = 'Anyone know where to find this?'

$Processed     = '{0} ({1}%)' -f (Convert-BytesToHuman $Session.Progress.ProcessedUsedSize), $Session.Info.CompletionPercentage
$Read          = Convert-BytesToHuman $Session.Progress.ReadSize
$Transferred   = '{0} ({1:N1}x)' -f (Convert-BytesToHuman $Session.Progress.TransferedSize), ($Session.Progress.ReadSize / $Session.Progress.TransferedSize)


# set some status variables
switch ( $Session.Result ) {

    Success {
    
        $Title         = "Veeam backup job '{0}' completed successfully" -f $Session.OrigJobName
        $Color         = '54B948'
    
    }

    Warning {
    
        $Title         = "Veeam backup job '{0}' completed with warnings" -f $Session.OrigJobName
        $Color         = 'F5BD4C'
    
    }
    
    Failed  {
    
        $Title         = "Veeam backup job '{0}' has failed!" -f $Session.OrigJobName
        $Color         = 'EF5D4A'
    
    }

    None    {
    
        $Title         = "Veeam backup job '{0}' completed" -f $Session.OrigJobName
        $Color         = '54B948'
    
    }
    
    default {
    
        $Title = "Veeam backup job '{0}' has other status" -f $Session.OrigJobName
        $Color = '54B948'

    }

}


# build MessageCard
$TeamsJSON = @{
    '@type'         = 'MessageCard'
    '@context'      = 'http=//schema.org/extensions'
    'correlationId' = $Session.Id
    'themeColor'    = $Color
    'title'         = $Title
    'summary'       = $Title
    'sections'= @(
        @{
            'facts'= @(
                @{ 'name' = 'Duration';         'value' = $Duration                                     }
                @{ 'name' = 'Processing rate';  'value' = $Rate                                         }
                #@{ 'name' = 'Bottleneck';       'value' = $Bottleneck                                   }
                @{ 'name' = 'Data Processed';   'value' = $Processed                                    }
                @{ 'name' = 'Data Read';        'value' = $Read                                         }
                @{ 'name' = 'Data Transferred'; 'value' = $Transferred                                  }
                @{ 'name' = 'Success';          'value' = $SuccessFormat -f $SuccessCount, $SuccessIcon }
                @{ 'name' = 'Warning';          'value' = $WarningFormat -f $WarningCount, $WarningIcon }
                @{ 'name' = 'Error';            'value' = $FailureFormat -f $FailureCount, $FailureIcon }
            )
        }
    )
}


# Build the web request
$Params = @{
    Uri         = $Config.WebhookURI
    Method      = 'Post'
    Headers     = @{'accept'='application/json'}
    Body        = $TeamsJSON | ConvertTo-Json -Depth 5
}


# Send It
$Request = Invoke-RestMethod @Params
