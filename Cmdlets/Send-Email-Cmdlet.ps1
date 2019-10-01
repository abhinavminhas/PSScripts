<#

.Synopsis
This function sends email using SMTP Client.

.Description
This function sends email using SMTP Client to the email addresses in (To, Cc, Bcc).
The function can also send files as attachments in emails. It can also use filters (Include/Exclude) to match the required files in the supplied path.

.Parameter SMTPServer
This parameter is set as the 'SMTP Server'.
This parameter is mandatory.
.Parameter SMTPPort
This parameter is set as the 'SMTP port'.
This parameter is mandatory.
.Parameter From
This parameter is set as the 'From' email address. Also used as a user to authenticate the email.
This parameter is mandatory.
.Parameter Password
This parameter is set as the 'Password' for the from user email address.
This parameter can have null or empty string value in case there is no password required.
This parameter is mandatory.
.Parameter To
This parameter is set as the 'To' email (recipient) addresses. Uses a comma separated value for multiple email addresses.
This parameter is mandatory.
.Parameter Cc
This parameter is set as the 'Cc' email (recipient) addresses. Uses a comma separated value for multiple email addresses.
.Parameter Bcc
This parameter is set as the 'Bcc' email (recipient) addresses. Uses a comma separated value for multiple email addresses.
.Parameter Subject
This parameter is set as the 'Subject' in the email.
.Parameter Body
This parameter is set as the 'Body' in the email.
.Parameter AttachmentFolderPath
This parameter is set as the 'Attachment Folder Path' for attachments to add to the email (Ignores directories and only looks for files).
.Parameter AttachmentIncludeFilter
This parameter is set as the 'Attachment Type Include Match' for attachments to add to the email.
.Parameter AttachmentExcludeFilter
This parameter is set as the 'Attachment Type Exclude Match' for attachments to add to the email.

.Example
Send-Email -SMTPServer "<SMTP Server Address>" -SMTPPort "<SMTP Server Port>" -From "<From Address>" -Password "<Password>" -To "<To Addresses>" -Subject "<Subject Line>"
This command sends email using mandatory parameters.
.Example
Send-Email -SMTPServer "<SMTP Server Address>" -SMTPPort "<SMTP Server Port>" -From "<From Address>" -Password "<Password>" -To "<To Addresses>" -Cc "<Cc Addresses>" -Bcc "<Bcc Addresses>" -Subject "<Subject Line>" -Body "<Email Body>" -AttachmentFolderPath "<Attachment Folder Path>" -AttachmentIncludeFilter "<Include Filter>" -AttachmentExcludeFilter "<Exclude Filter>"
This command sends email using all the parameters.

#>

Function Send-Email
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$SMTPServer,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$SMTPPort,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$From,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [AllowNull()]
        [AllowEmptyString()]
        [String]$Password,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$To,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Cc,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Bcc,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Subject,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Body,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$AttachmentFolderPath,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$AttachmentIncludeFilter,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$AttachmentExcludeFilter
    )

    Begin
    {
        Function Write-Log([string]$logMessage)
        {
            $print = $logMessage.length + 6
            Write-Output $("-" * ($print))
            Write-Output "[[ $logMessage ]]"
            write-output $("-" * ($print))
        }
        $toRecipients = $To.Split(',')
        $ccRecipients = $Cc.Split(',')
        $bccRecipients = $Bcc.Split(',')
        $include = $AttachmentIncludeFilter
        $exclude = $AttachmentExcludeFilter
        if(![string]::IsNullOrEmpty($AttachmentIncludeFilter) -and [string]::IsNullOrEmpty($AttachmentExcludeFilter))
        {
            $attachmentFiles = Get-ChildItem -Path $path -Filter $include -Recurse -ErrorAction SilentlyContinue -Force
        }
        elseif ([string]::IsNullOrEmpty($AttachmentIncludeFilter) -and ![string]::IsNullOrEmpty($AttachmentExcludeFilter))
        {
            $attachmentFiles = Get-ChildItem -Path $path -Exclude $exclude -Recurse -ErrorAction SilentlyContinue -Force
        }
        elseif((![string]::IsNullOrEmpty($AttachmentIncludeFilter)) -or (![string]::IsNullOrEmpty($AttachmentExcludeFilter)))
        {
            $attachmentFiles = Get-ChildItem -Path $path -Filter $include -Exclude $exclude -Recurse -ErrorAction SilentlyContinue -Force
        }
        else
        {
            $attachmentFiles = Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue -Force
        }
        $path = $AttachmentFolderPath
        $attachments = New-Object System.Collections.ArrayList
        foreach ($attachmentFile in $attachmentFiles)
        {
            $filename = $attachmentFile | select -Property Name
            $filepath = Join-Path $path $filename.Name
            if((Test-Path -Path $filepath -PathType leaf))
            {
                $attachments.add($filepath)
            }
        }
    }
    
    Process
    {
        try
        {
            $message = New-Object System.Net.Mail.MailMessage
            $message.from = $From
            foreach ($recipient in $toRecipients)
            {
                $message.to.add($To)
            }
            if(![string]::IsNullOrEmpty($Cc))
            {
                foreach ($recipient in $ccRecipients)
                {
                    $message.cc.add($Cc)
                }
            }
            if(![string]::IsNullOrEmpty($Bcc))
            {
                foreach ($recipient in $bccRecipients)
                {
                    $message.bcc.add($Bcc)
                }
            }
            if(![string]::IsNullOrEmpty($Subject))
            {
                $message.subject = $Subject
            }
            if(![string]::IsNullOrEmpty($Body))
            {
                $message.body = $Body
            }
            foreach ($attachment in $attachments)
            {
                $message.attachments.add($attachment)
            }
            $smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
            $smtp.EnableSSL = $true
            $smtp.UseDefaultCredentials = $false;
            $smtp.DeliveryMethod = [Net.Mail.SmtpDeliveryMethod]::Network;
            $smtp.Credentials = New-Object System.Net.NetworkCredential($From, $Password);
            $smtp.send($message)
        }
        catch
        {
            Write-Log(":: SCRIPT ERROR ::")
            Write-Log("Error Message :: $_.Exception.Message")
            Break
        }
    }

    End
    {
        Write-Log(":::: Email Sent. ::::")
    }
}

#Send-Email -SMTPServer "<SMTP Server Address>" -SMTPPort "<SMTP Server Port>" -From "<From Address>" -Password "<Password>" -To "<To Addresses>" -Subject "<Subject Line>"
#Send-Email -SMTPServer "<SMTP Server Address>" -SMTPPort "<SMTP Server Port>" -From "<From Address>" -Password "<Password>" -To "<To Addresses>" -Cc "<Cc Addresses>" -Bcc "<Bcc Addresses>" -Subject "<Subject Line>" -Body "<Email Body>" -AttachmentFolderPath "<Attachment Folder Path>" -AttachmentIncludeFilter "<Include Filter>" -AttachmentExcludeFilter "<Exclude Filter>"