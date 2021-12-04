<#

.Synopsis
This function gets the matching string values from the supplied files.

.Description
This function gets the matching string values from the supplied files with a path.
The function can also incude & exclude file types to consider for string matching.

.Parameter FileFolderPath
This parameter is set as the 'Folder Path' for files to look for string matching.
This parameter is mandatory.
.Parameter Regex
TThis parameter is set as the 'Regular Expressionh' to look for while matching the file contents.
This parameter is mandatory.
.Parameter FileIncludeFilter
This parameter is set as the 'File Type Include Match' for files to add to the search for string mathcing.
.Parameter FileExcludeFilter
This parameter is set as the 'File Type Include Match' for files to add to the search for string mathcing.

.Example
Get-MatchedStringFromFiles -FileFolderPath <File Folder Path> -Regex "<Regular Expression>"
This command matches file contents for string match using mandatory parameters.
.Example
Get-MatchedStringFromFiles -FileFolderPath <File Folder Path> -Regex "<Regular Expression>" -FileIncludeFilter "<File Include Filter>" -FileExcludeFilter "<File Exclude Filter>"
This command matches file contents for string match using all parameters.

#>

Function Get-MatchedStringFromFiles
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$FileFolderPath,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Regex,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$FileIncludeFilter,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$FileExcludeFilter
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

        Write-Log("====>> EXECUTING FILE STRING MATCH <<====")

        if(![string]::IsNullOrEmpty($FileFolderPath))
        {
            if(![string]::IsNullOrEmpty($FileIncludeFilter) -and [string]::IsNullOrEmpty($FileExcludeFilter))
            {
                $files = Get-ChildItem -Path $FileFolderPath -Filter $include -Recurse -ErrorAction SilentlyContinue -Force
            }
            elseif ([string]::IsNullOrEmpty($FileIncludeFilter) -and ![string]::IsNullOrEmpty($FileExcludeFilter))
            {
                $files = Get-ChildItem -Path $FileFolderPath -Exclude $exclude -Recurse -ErrorAction SilentlyContinue -Force
            }
            elseif((![string]::IsNullOrEmpty($FileIncludeFilter)) -or (![string]::IsNullOrEmpty($FileExcludeFilter)))
            {
                if(!($FileIncludeFilter -eq $FileExcludeFilter))
                {
                    $files = Get-ChildItem -Path $FileFolderPath -Filter $include -Exclude $exclude -Recurse -ErrorAction SilentlyContinue -Force
                }
            }
            else
            {
                $files = Get-ChildItem -Path $FileFolderPath -Recurse -ErrorAction SilentlyContinue -Force
            }
            $path = $FileFolderPath
            $requireFiles = New-Object System.Collections.ArrayList
            foreach ($file in $files)
            {
                $filename = $file | Select-Object -Property Name
                $filepath = Join-Path $path $filename.Name
                if((Test-Path -Path $filepath -PathType leaf))
                {
                    [void]$requireFiles.add($filepath)
                }
            }
        }
    }
    
    Process
    {
        try
        {
            [bool]$found = $false;
            if($requireFiles.Count -eq 0)
            {
                Write-Log(":::: No Files Found For Matching Regular Expression - '$Regex' ::::")
            }
            else
            {
                foreach ($file in $requireFiles)
                {
                    [string]$temp = Get-Content $file
                    [regex]$regex = $Regex
                    if($temp -match $Regex)
                    {
                        $found = $true
                        $regex.Matches($temp) | foreach-object {$_.Value}
                    }
                }
                if($found -eq $false)
                {
                    Write-Log(":::: No Match Found For Regular Expression - '$Regex' ::::")
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
        Write-Log("====>> COMPLETED FILE STRING MATCH <<====")
    }
}

<# Get-MatchedStringFromFiles -FileFolderPath "C:\Users\abhinavminhas\Files" -Regex ":::::::: Application ID: \[[0-9]{0,9}\]\; Student ID: \[[0-9]{0,9}\] ::::::::" #>
<# Get-MatchedStringFromFiles -FileFolderPath "C:\Users\abhinavminhas\Files" -FileIncludeFilter "*.trx" -FileExcludeFilter "*.txt" -Regex ":::::::: Application ID: \[[0-9]{0,9}\]\; Student ID: \[[0-9]{0,9}\] ::::::::" #>
