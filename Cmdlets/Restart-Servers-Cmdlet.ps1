<#

.Synopsis
This function will restart the machines/servers provided as input to the cmdlet.

.Description
This function will restart the machines/servers.

.Parameter Servers
This parameter is the list of machines/servers to restart.
This parameter is mandatory, possible inputs is the comma separated list of machine/server names.
.Parameter Username
This parameter is used to set the username having access to the machines/servers.
This parameter is mandatory, possible input is the username having admin access to the machines/servers.
.Parameter Password
This parameter is used to set the password to the username provided for the machines/servers.
This parameter is mandatory, possible input is the password to the username having admin access for the machines/servers.
.Parameter WaitForServerToRestart
This parameter is used to set the time to wait for server to restart.
This parameter is not mandatory, possible input is time in seconds. Default value is 60 seconds.
.Parameter PingRetries
This parameter is used to set the number of ping retries to check the machine is online again.
This parameter is not mandatory, possible input is the number of times a ping is required. Default value is 4.

.Example
Restart-Servers -Servers "PC-A" -Username "domain\abc" -Password "xyz"
This command is used to restart a Machine/Server
.Example
Restart-Servers -Servers "PC-A,PC-B,PC-C,PC-D" -Username "domain\abc" -Password "xyz"
This command is used to restart Multiple Machines/Servers
.Example
Restart-Servers -Servers "PC-A" -Username "domain\abc" -Password "xyz" -WaitForServerToRestart "120" -PingRetries "2"
This command is used to restart a Machine/Server, wait And try pinging the Machine/Server
.Example
Restart-Servers -Servers "PC-A,PC-B,PC-C,PC-D" -Username "domain\abc" -Password "xyz" -WaitForServerToRestart "60" -PingRetries "8"
This command is used to restart Multiple Machines/Servers, wait And try pinging the Machines/Servers

#>

Function Restart-Servers
{
    [CmdletBinding()]
    Param(

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$Servers,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$Username,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$Password,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$WaitForServerToRestart,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$PingRetries
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

        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword
        $Servers = $Servers.Split(',')
        [string]$ServerName
        $ServersRestarted = New-Object System.Collections.Generic.List[System.Object]

        if($WaitForServerToRestart -eq "")
        {
            $WaitForServerToRestart = "60"
        }
        if($PingRetries -eq "")
        {
            $PingRetries = "4"
        }
    }

    Process
    {
        try
        {
            foreach ($Server in $Servers)
            {
                Restart-Computer -ComputerName $Server -Credential $Credentials -Force -ErrorAction SilentlyContinue
                if($? -eq $false)
                {
                    $ServerName = $Server
                    Write-Log("Restart-Servers ERROR on Machine :: '$ServerName', couldn't restart this machine. Check machine name or credentials and try again.")
                }
                else
                {
                    $ServersRestarted.Add($Server)
                }
            }
            if($ServersRestarted.Count -ne 0)
            {
                Start-Sleep -s $WaitForServerToRestart
            }
            foreach($Server in $ServersRestarted)
            {
                for($i=1; $i -le $PingRetries; $i++)
                {
                    $a = Test-Connection -ComputerName "$Server" -count 1 -Quiet
                    if($a -eq $true)
                    {
                        $ServerName = $Server
                    }
                    else
                    {
                        Start-Sleep -Seconds 50
                    }
                }
                if($a -eq $true)
                {
                    Write-Log("Machine - '$ServerName' restarted and is up and running.")
                }
                else
                {
                    Write-Log("Machine - '$ServerName' restarted and but is not responding.")
                }
            }
        }
        catch
        {
            Write-Log("ERROR on Machine :: '$ServerName'")
            Write-Log("Error Message :: $_.Exception.Message")
            Break
        }
    }

    End
    {
        Write-Log(":::: 'Restart-Servers' executed successfully. ::::")
    }
}

<#Restart-Servers -Servers "PC1,PC2,PC3,PC4" -Username "domain\<username>" -Password "<password>" -WaitForServerToRestart "60" -PingRetries "4"#>