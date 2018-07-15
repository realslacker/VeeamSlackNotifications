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


# Get Veeam job from parent process
$ParentPID = ( Get-WmiObject Win32_Process -Filter "ProcessID='$PID'" ).ParentProcessId.ToString()

$ParentCmd = ( Get-WmiObject Win32_Process -Filter "ProcessID='$ParentPID'" ).CommandLine

$BackupJob = Get-VBRJob |
    Where-Object { $ParentCmd -match $_.Id }


# Get the Veeam session
$Session = Get-VBRBackupSession |
    Where-Object { ( $_.OrigJobName -eq $BackupJob.Name ) -and ( $ParentCmd -match $_.Id ) }


# Start a new new script in a new process with some of the information gathered her
# Doing this allows Veeam to finish the current session so information on the job's status can be read
$Process = @{
    FilePath        = 'powershell.exe'
    ArgumentList    = "-ExecutionPolicy ByPass -Command ""& '$PSScriptRoot\Send-VeeamTeamsNotification.ps1' -Id '$($Session.Id)' -OrigJobName '$($Session.OrigJobName)'"""
    Verb            = 'RunAs'
    WindowStyle     = 'Hidden'
}

Start-Process @Process
