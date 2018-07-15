# This function logs messages with a type tag
function Write-LogMessage([string]$Tag, [string]$Message) {
    Write-Host "[$Tag] $Message"
}

# This function handles Logging
function Start-Logging([string]$Path) {
    try {
        Start-Transcript -Path $Path -Force -Append 
        Write-LogMessage -Tag 'Info' -Message "Transcript is being logged to $path"
    } catch [Exception] {
        Write-LogMessage -Tag 'Info' -Message "Transcript is already being logged to $path"
    }
}

# This function converts sizes to human readable formats
function Convert-BytesToHuman([int64]$Bytes) {
    switch ($Bytes) {
        {$Bytes -gt 1PB} { return '{0:N1} PB' -f ($Bytes / 1PB) }
        {$Bytes -gt 1TB} { return '{0:N1} TB' -f ($Bytes / 1TB) }
        {$Bytes -gt 1GB} { return '{0:N1} GB' -f ($Bytes / 1GB) }
        {$Bytes -gt 1MB} { return '{0:N1} MB' -f ($Bytes / 1MB) }
        {$Bytes -gt 1KB} { return '{0:N1} KB' -f ($Bytes / 1KB) }
        default          { return '{0:N1} B ' -f $Bytes         }
    }
}

# This function converts time to human readable formats
function Convert-TimeSpanToHuman([TimeSpan]$TimeSpan) {
    switch ($TimeSpan) {
        { $TimeSpan.Days  -gt 1 } { $Format ='{0}.{1:00}:{2:00}:{3:00}' }
        { $TimeSpan.Hours -gt 1 } { $Format =    '{1:00}:{2:00}:{3:00}' }
        default                   { $Format =           '{2:00}:{3:00}' }
    }

    $Format -f $TimeSpan.Days, $TimeSpan.Hours, $TimeSpan.Minutes, $TimeSpan.Seconds
}