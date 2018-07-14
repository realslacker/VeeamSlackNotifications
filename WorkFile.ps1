$Webhook = 'https://outlook.office.com/webhook/7aa7ff76-133a-4b14-a4fc-13002b3d78c8@3cad78c0-165a-40df-8a09-0e50742a2d1b/IncomingWebhook/e40125d29b1d4fdf906610c5bd94a1f8/4235b79f-88b5-4519-bb08-ac5d861c6b2f'

$Body = @"
{
    "@type": "MessageCard",
    "@context": "http://schema.org/extensions",
    "themeColor": "54B948",
    "summary": "Backup Completed Successfully",
    "sections": [{
        "activityTitle": "Backup [JOBNAME] Completed Successfully",
        "activitySubtitle": "date time",
        "facts": [{
            "name": "Job Name",
            "value": "Unassigned"
        }, {
            "name": "Completed Date",
            "value": "Mon May 01 2017 17:07:18 GMT-0700 (Pacific Daylight Time)"
        }, {
            "name": "Status",
            "value": "Success"
        }],
        "markdown": true
    }]
}
"@

$Params = @{
    Headers = @{'accept'='application/json'}
    Body = $Body # | convertto-json
    Method = 'Post'
    URI = $Webhook
}

Invoke-RestMethod @Params