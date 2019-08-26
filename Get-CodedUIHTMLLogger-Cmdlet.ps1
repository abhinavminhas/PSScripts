<#
.Synopsis
This function will get the HTML logger files from the 'Test Results' folder.

.Description
This function will get all the unique HTML logger files and put it under 'HTMLLoggerReports' folder in the Test Results Directory path supplied. Use 'Test Results' folder path to get all the CodedUI generated 'UITestActionLog.html' files.

.Parameter TestResultsPath
This parameter is set as the 'Test Results Path' for Test Results Directory.
This parameter is mandatory.
.Parameter Zipped
This parameter is set as a switch to zip the HTML Logger files folder.
This parameter is not mandatory.
.Parameter ZippedFileName
This parameter is set as 'Zipped File Name'. Sets the custom name for the zipped folder.
This parameter is not mandatory, has default value = 'HTMLLoggerReports'.

.Example
Get-CodedUIHTMLLogger -TestResultsPath "C:\Test\TestResults"
This command is used to get all the unique HTML logger files from the 'Test Results' folder.
.Example
Get-CodedUIHTMLLogger -TestResultsPath "C:\Test\TestResults" -Zipped
This command is used to get all the unique HTML logger files from the 'Test Results' folder and zip the contests of HTML logger files folder. Zipped folder has default name = 'HTMLLoggerReports'.
.Example
Get-CodedUIHTMLLogger -TestResultsPath "C:\Test\TestResults" -Zipped -ZippedFileName "Logger Reports"
This command is used to get all the unique HTML logger files from the 'Test Results' folder, zip the contests of HTML logger files folder and set the name of the zipped folder.
#>

Function Get-CodedUIHTMLLogger
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$TestResultsPath,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [switch]$Zipped,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$ZippedFileName
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
        if($Zipped) { $Zipped =$true }
        else { $Zipped = $false }
        $loggerFileDirectoryName = "HTMLLoggerReports"
        if($ZippedFileName -ne "") { $ZippedFileName =$ZippedFileName }
        else { $ZippedFileName = "HTMLLoggerReports" }
    }
    
    Process
    {
        try
        {
            $path = $TestResultsPath            
            $newpath = Join-Path $path $loggerFileDirectoryName
            $htmlLoggerFiles = Get-ChildItem -Path $path -Exclude *.trx.html -Filter *.html -Recurse -ErrorAction SilentlyContinue -Force
            New-Item -Path $path -ItemType Directory -Name $loggerFileDirectoryName -Force
            foreach ($htmlLoggerFile in $htmlLoggerFiles)
            {
                $filename = $htmlLoggerFile | select -Property Name
                if(!(Test-Path(Join-Path $newpath $filename.Name)))
                {
                    Copy-Item -LiteralPath $htmlLoggerFile -Destination $newpath
                }
            }
            if($zipped -eq $true)
            {
                if((ls $path $loggerFileDirectoryName -Recurse -Directory -Name) -eq  $loggerFileDirectoryName)
                {
                    Compress-Archive -LiteralPath $newpath -DestinationPath $path\$ZippedFileName -Force
                }
            }
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
        Write-Log(":::: HTML Logger Files Collated Into '$loggerFileDirectoryName' Folder. ::::")
    }
}

<# Get-CodedUIHTMLLogger -TestResultsPath C:\Test\TestResults #>