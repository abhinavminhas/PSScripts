<#
.Synopsis
This function will set the internet settings provided as input to the cmdlet.

.Description
This function will set the internet settings like (optional) Enable/Disable 'Automatically Detect Settings', (optional) Enable/Disable 'Use Automatic Configuration Script' and set 'Automatic Configuration URL', (optional) Enable/Disable 'Proxy' and set 'Proxy Server', (optional) Enable/Disable 'Bypass Proxy' and set 'Bypass Local Addresses'.

.Parameter EnableAutomaticDetectSettings
This parameter is set as the 'Automatically Detect Settings' for internet settings of the system.
This parameter is not mandatory, possible inputs "E" for enable & "D" for disable.
.Parameter EnableAutomaticConfigScript
This parameter is set as the 'Use Automatic Configuration Script' for internet settings of the system.
This parameter is not mandatory, possible inputs "E" for enable & "D" for disable.
.Parameter SetAutomaticConfigurationURL
This parameter is set as the 'Automatic Configuration Script URL' for internet settings of the system.
This parameter is not mandatory, and can be empty. Default value is 'https://www.URL-NotDefined.com'.
.Parameter EnableProxy
This parameter is used to 'Enable Proxy' for internet settings of the system.
This parameter is not mandatory, possible inputs "E" for enable & "D" for disable.
.Parameter SetProxyServer
This parameter is set as the 'Proxy Server Address' for internet settings of the system.
This parameter is not mandatory, and can be empty.
.Parameter EnableBypassProxy
This parameter is used to 'Enable Bypass Proxy' for internet settings of the system.
This parameter is not mandatory, possible inputs "E" for enable & "D" for disable.
.Parameter SetBypassLocalAddresses
This parameter is set as the 'Bypass Local Addresses' for internet settings of the system. Requires semicolon separated values for multiple addresses.
This parameter is not mandatory, and can be empty. Default value is '<local>'. 

.Example
Configure-InternetSettings -EnableAutomaticDetectSettings "E"
This command is used for enabling 'Automatically Detect Settings'.
.Example
Configure-InternetSettings -EnableAutomaticDetectSettings "D"
This command is used for disabling 'Automatically Detect Settings'.
.Example
Configure-InternetSettings -EnableAutomaticConfigScript "E" -SetAutomaticConfigurationURL "https://www.example.com"
This command is used for enabling 'Use Automatic Configuration Script' and setting 'Automatic Configuration URL'.
.Example
Configure-InternetSettings -EnableAutomaticConfigScript "D"
This command is used for disabling 'Use Automatic Configuration Script'.
.Example
Configure-InternetSettings -EnableProxy "E" -SetProxyServer "proxy:7890"
This command is used for enabling 'Proxy' and setting 'Proxy Information'.
.Example
Configure-InternetSettings -EnableProxy "D"
This command is used for disabling 'Proxy'.
.Example
Configure-InternetSettings -EnableBypassProxy "E" -SetBypassLocalAddresses "<local>;www.example.com"
This command is used for enabling 'Bypass Proxy' and setting 'Bypass Local Addresses'.
.Example
Configure-InternetSettings -EnableBypassProxy "D"
This command is used for disabling 'Bypass Proxy'.
.Example
Configure-InternetSettings -EnableAutomaticDetectSettings "E" -EnableAutomaticConfigScript "E" -SetAutomaticConfigurationURL "https://www.example.com" -EnableProxy "E" -SetProxyServer "http://proxyURL:8080" -EnableBypassProxy "E" -SetBypassLocalAddresses "<local>;www.URL1.com;www.URL2.com"
This command is used for enabling the entire Internet Settings.
.Example
Configure-InternetSettings -EnableAutomaticDetectSettings "D" -EnableAutomaticConfigScript "D" -EnableProxy "D" -EnableBypassProxy "D"
This command is used for disabling the entire Internet Settings.

#>

Function Configure-InternetSettingsMachineGroup
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$Servers,
        
        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$EnableAutomaticDetectSettings,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$EnableAutomaticConfigScript,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [String]$SetAutomaticConfigurationURL,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$EnableProxy,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [String]$SetProxyServer,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$EnableBypassProxy,

        [Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [AllowEmptyString()]
        [String]$SetBypassLocalAddresses
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

        [string]$RegPath = "Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

        if($SetAutomaticConfigurationURL -eq "")
        {
            $SetAutomaticConfigurationURL = "https://www.URL-NotDefined.com"
        }
        if($SetBypassLocalAddresses -eq "")
        {
            $SetBypassLocalAddresses = "<local>"
        }

        $Servers = $Servers.Split(',')
    }
    
    Process
    {
        foreach ($Server in $Servers)
        {
            $env:COMPUTERNAME = $Server
            try
            {
                [boolean] $ChangeFlag = $False
                <# Close Internet explorer #>
                if($EnableAutomaticDetectSettings -eq "E" -or $EnableAutomaticDetectSettings -eq "D" -or $EnableAutomaticConfigScript -eq "E" -or $EnableAutomaticConfigScript -eq "D" -or $EnableProxy -eq "E" -or $EnableProxy -eq "D" -or $EnableBypassProxy -eq "E" -or $EnableBypassProxy -eq "D")
                {
                    $IEProcess = Get-Process | Where-Object -Property Name -EQ "iexplore"
                    if($IEProcess -ne $null)
                    {
                        Get-Process iexplore | Stop-Process
                        Write-Log("'Internet Explorer' process found running and stopped on Machine :: '$env:COMPUTERNAME'.")
                        Start-Sleep -s 2
                    }
                    else
                    {
                        Write-Log("No 'Internet Explorer' process found running on Machine :: '$env:COMPUTERNAME'.")
                    }
                }

                <# Enable/Disable Automatically Detect Settings #>
                if($EnableAutomaticDetectSettings -eq "E")
                {
                    Set-ItemProperty -Path $RegPath AutoDetect -value 1
                    Write-Log("'Automatically Detect Settings' enabled on Machine :: '$env:COMPUTERNAME'.")
                    $ChangeFlag = $true
                }
                elseif($EnableAutomaticDetectSettings -eq "D")
                {
                    Set-ItemProperty -Path $RegPath AutoDetect -value 0
                    Write-Log("'Automatically Detect Settings' disabled on Machine :: '$env:COMPUTERNAME'.")
                    $ChangeFlag = $true
                }
                else
                {
                    Write-Log("'Automatically Detect Settings' not changed on Machine :: '$env:COMPUTERNAME'.")
                }

                <# Enable/Disable Use Automatic Configuration Script #>
                if($EnableAutomaticConfigScript -eq "E")
                {
                    Get-ItemProperty -Path $RegPath -Name "AutoConfigURL" -ErrorAction SilentlyContinue
                    if($? -eq $false)
                    {
                        New-ItemProperty -Path $RegPath -Name "AutoConfigURL" -Value "$SetAutomaticConfigurationURL" -PropertyType Multistring -Force
                    }
                    else
                    {
                        Remove-ItemProperty -Path $RegPath -Name "AutoConfigURL"
                        New-ItemProperty -Path $RegPath -Name "AutoConfigURL" -Value "$SetAutomaticConfigurationURL" -PropertyType Multistring -Force
                    }
                    Write-Log("'Use Automatic Configuration Script' for URL '$SetAutomaticConfigurationURL' enabled on Machine :: '$env:COMPUTERNAME'.")
                    $ChangeFlag = $true
                }
                elseif($EnableAutomaticConfigScript -eq "D")
                {
                    Get-ItemProperty -Path $RegPath -Name "AutoConfigURL" -ErrorAction SilentlyContinue
                    if($? -eq $true)
                    {
                        Remove-ItemProperty -Path $RegPath -Name "AutoConfigURL"
                        Write-Log("'Use Automatic Configuration Script' disabled on Machine :: '$env:COMPUTERNAME'.")
                        $ChangeFlag = $true
                    }
                    else
                    {
                        Write-Log("'Use Automatic Configuration Script' disabled on Machine :: '$env:COMPUTERNAME'.")
                    }            
                }
                else
                {
                    Write-Log("'Use Automatic Configuration Script' not changed on Machine :: '$env:COMPUTERNAME'.")
                }

                <# Enable/Disable Proxy and set Proxy Server#>
                if($EnableProxy -eq "E")
                {
                    Set-ItemProperty -Path $RegPath ProxyEnable -value 1
                    Write-Log("'Internet Proxy' enabled on Machine :: '$env:COMPUTERNAME'.")
                    Set-ItemProperty -Path $RegPath ProxyServer -value $SetProxyServer
                    Write-Log("Internet Proxy Server is set to - '$SetProxyServer' on Machine :: '$env:COMPUTERNAME'.")
                    $ChangeFlag = $true
                }
                elseif($EnableProxy -eq "D")
                {
                    Set-ItemProperty -Path $RegPath ProxyEnable -value 0
                    Write-Log("'Internet Proxy' disabled on Machine :: '$env:COMPUTERNAME'.")
                    $ChangeFlag = $true
                }
                else
                {
                    Write-Log("'Internet Proxy' was not changed on Machine :: '$env:COMPUTERNAME'.")
                }

                <# Enable/Disable Bypass Proxy Server for local addresses and define addresses#>
                if($EnableBypassProxy -eq "E")
                {
                    Get-ItemProperty -Path $RegPath -Name "ProxyOverride" -ErrorAction SilentlyContinue
                    if($? -eq $false)
                    {
                        New-ItemProperty -Path $RegPath -Name "ProxyOverride" -Value "$SetBypassLocalAddresses" -PropertyType Multistring -Force
                    }
                    else
                    {
                        Remove-ItemProperty -Path $RegPath -Name "ProxyOverride"
                        New-ItemProperty -Path $RegPath -Name "ProxyOverride" -Value "$SetBypassLocalAddresses" -PropertyType Multistring -Force
                    }
                    Write-Log("Bypass proxy server for local addresses '$SetBypassLocalAddresses' enabled on Machine :: '$env:COMPUTERNAME'.")
                    $ChangeFlag = $true
                }
                elseif($EnableBypassProxy -eq "D")
                {
                    Get-ItemProperty -Path $RegPath -Name "ProxyOverride" -ErrorAction SilentlyContinue
                    if($? -eq $true)
                    {
                        Remove-ItemProperty -Path $RegPath -Name "ProxyOverride"
                        Write-Log("Bypass proxy server for local addresses disabled on Machine :: '$env:COMPUTERNAME'.")
                        $ChangeFlag = $true
                    }
                    else
                    {
                        Write-Log("Bypass proxy server for local addresses disabled on Machine :: '$env:COMPUTERNAME'.")
                    }          
                }
                else
                {
                    Write-Log("'Bypass proxy server for local addresses' not changed on Machine :: '$env:COMPUTERNAME'.")
                }

                <# Wait for changes to take effect #>
                if($ChangeFlag -eq $true)
                {
                    Start-Sleep -s 2
                    Start-Process -FilePath "C:\Program Files\Internet Explorer\iexplore.exe"
                    Start-Sleep -s 10
                    Get-Process iexplore | Stop-Process
                }

                Write-Log(":::: 'Internet Settings' configuration completed on Machine :: '$env:COMPUTERNAME'. ::::")
            }
            catch
            {
                Write-Log("ERROR on Machine :: '$env:COMPUTERNAME'")
                Write-Log("Error Message :: $_.Exception.Message")
                Break
            }
        }
    } 
   
    End
    {
        Write-Log(":::: 'Internet Settings' Configuration Executed Successfully. ::::")
    }
}

<# Configure-InternetSettings -Servers "PC1,PC2,PC3,PC4" -EnableAutomaticDetectSettings "E" -EnableAutomaticConfigScript "E" -EnableProxy "E" -SetProxyServer "http://proxy.internal.proxy.com.au:8080" -EnableBypassProxy "E" -SetBypassLocalAddresses "<local>;www.google.com;www.yahoo.com" #>