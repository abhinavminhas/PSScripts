#################################################################################
# Summary: This script tests if Powershell is running in 32-bit mode and if true,
#          launches itself in 64-bit mode for completion.
#################################################################################

##############################################################################################################################################
# If Powershell is running the 32-bit version on a 64-bit machine, forces powershell to run in 64-bit mode, so that Workflows can be executed.
##############################################################################################################################################

# ==> START
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64")
{
    write-warning "....Off To 64-bit....."
    if ($myInvocation.Line)
    {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }
    else
    {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
    exit $lastexitcode
}
# ==> FINISH

<#

.Synopsis
This workflow runs test in parallel.

.Description
This workflow runs supplied test in parallel. The filter used for tests is '/Tests:<<Comma Separated Test Name (Full/Partial)>>'

.Parameter VSTestAdapterPath
This parameter is set as the path to test adapter 'vstest.console.exe'.
This parameter is mandatory.
.Parameter TestFileLocation
This parameter is set as the path to test file/files '.dll'.
This parameter is mandatory.
.Parameter Threads
This parameter is set as the number of test run threads to run in parallel.
This parameter is mandatory.
.Parameter TestCaseName
This parameter is set as the 'Test Case' to run.
This parameter is mandatory.
.Parameter TestResultsDirectory
This parameter is set as the path to 'TestResults' directory.
This parameter is mandatory.
.Parameter TestReportNamePrefix
This parameter is set as the 'Test Report Name'.
By default the test file name format is 'TestResultFile_dd_MM_yy_hh_mm_ss_fffff.trx'. If this value is provided the format will be set as '<TestReportNamePrefix>_dd_MM_yy_hh_mm_ss_fffff.trx'
Note: Refrain from giving too long prefix names.

.Example
RunTest-Parallel -VSTestAdapterPath "<Path To 'vstest.console.exe' File>" -TestFileLocation "<Path To '.dll' file/files>" -Threads <Number Of Threads To Run In Parallel> -TestCaseName "<Test Case Name To Execute>" -TestResultsDirectory "<Path To 'Test Result' Directory>"
This command runs test in parallel using mandatory parameters.

.Example
RunTest-Parallel -VSTestAdapterPath "<Path To 'vstest.console.exe' File>" -TestFileLocation "<Path To '.dll' file/files>" -Threads <Number Of Threads To Run In Parallel> -TestCaseName "<Test Case Name To Execute>" -TestResultsDirectory "<Path To 'Test Result' Directory>" -TestReportNamePrefix "<Prefixed Name Of Test Report (.trx) File>"
This command runs test in parallel using all parameters.

#>

Workflow RunTest-Parallel
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$VSTestAdapterPath,
        [Parameter(Mandatory=$true)]
        [string]$TestFileLocation,
        [Parameter(Mandatory=$true)]
        [int]$Threads,
        [Parameter(Mandatory=$true)]
        [string]$TestCaseName,
        [Parameter(Mandatory=$true)]
        [string]$TestResultsDirectory,
        [Parameter(Mandatory=$false)]
        [string]$TestReportNamePrefix
        )

    #Function to write log
    Function Write-Log([string]$logMessage)
    {
        $print = $logMessage.length + 6
        Write-Output $("-" * ($print))
        Write-Output "[[ $logMessage ]]"
        write-output $("-" * ($print))
    }

    #Function to initialise test
    Function InitialiseTest()
    {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)]
            [int]$Threads,
            [Parameter(Mandatory=$true)]
            [string]$TestCaseName
            )

        $tests = New-Object System.Collections.ArrayList
        for ($i = 0; $i -lt $Threads; $i++)
        {
            [void]$tests.add($TestCaseName)
        }
        return $tests
    }

    #Function to generate test report name
    Function GetTestReportName
    {
        [CmdletBinding()]
            Param(
            [Parameter(Mandatory=$true)]
            [string]$TestReportNamePrefix
            )

        $reqiredTestReportName = $TestReportName
        $requiredDateTime = Get-Date -Format 'dd_MM_yy_hh_mm_ss_fffff'
        $reqiredTestReportName = $TestReportNamePrefix + $requiredDateTime
        return $reqiredTestReportName
    }

    #Function to run test
    Function RunTest()
    {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true)]
            [string]$VSTestAdapterPath,
            [Parameter(Mandatory=$true)]
            [string]$TestFileLocation,
            [Parameter(Mandatory=$true)]
            [string]$Test,
            [Parameter(Mandatory=$true)]
            [string]$TestResultsDirectory,
            [Parameter(Mandatory=$false)]
            [string]$TestReportName
            )

        $arguments = "$TestFileLocation /Tests:$Test /ResultsDirectory:$TestResultsDirectory '/Logger:trx;LogFileName=$TestReportName.trx'"
        Invoke-Expression "$VSTestAdapterPath $arguments"
    }

    #Workflow
    if ($Threads -eq 0)
    {
        Write-Log "NOTHING TO EXECUTE. THREADS REQUESTED: $Threads"
    }
    elseif (!$VSTestAdapterPath.EndsWith("vstest.console.exe"))
    {
        Write-Log "SUPPLIED VS TEST ADAPTER PATH '$VSTestAdapterPath' DOES NOT HAVE 'vstest.console.exe'. CHECK THE PATH AND SUPPLY FULL PATH TO 'vstest.console.exe'"
    }
    elseif ((!$TestFileLocation.Contains(".dll")) -or (!$TestFileLocation.EndsWith(".dll")))
    {
        Write-Log "SUPPLIED TEST LOCATION PATH '$TestFileLocation' DOES NOT HAVE '.dll' FILE. CHECK THE PATH AND SUPPLY FULL PATH TO '.dll' FILE"
    }
    else
    {
        $vSTestAdapterPath = $VSTestAdapterPath
        $testFileLocation = $TestFileLocation
        $testResultsDirectory = $TestResultsDirectory
        $requiredTests = InitialiseTest -Threads $Threads -TestCaseName $TestCaseName
        if($TestReportNamePrefix -eq $null -or $TestReportNamePrefix -eq "")
        {
            $TestReportNamePrefix = "TestResultFile_"
        }
        else
        {
            if(!$TestReportNamePrefix.EndsWith('_'))
            {
                $TestReportNamePrefix = $TestReportNamePrefix + "_"
            }
        }
        if(!$testResultsDirectory.EndsWith("\TestResults"))
        {
            if(!$testResultsDirectory.EndsWith("\"))
            {
                $testResultsDirectory = $testResultsDirectory + "\TestResults"
            }
            else
            {
                $testResultsDirectory = $testResultsDirectory + "TestResults"
            }
        }
        ForEach -Parallel -ThrottleLimit $Threads ($test in $requiredTests)
        {
            $reqiredTestReportName = GetTestReportName -TestReportName  $TestReportNamePrefix
            RunTest -VSTestAdapterPath $vSTestAdapterPath -TestFileLocation $testFileLocation -Test $test -TestResultsDirectory $testResultsDirectory -TestReportName $reqiredTestReportName
        }
    }
}

#RunTest-Parallel -VSTestAdapterPath "<Path To 'vstest.console.exe' File>" -TestFileLocation "<Path To '.dll' file/files>" -Threads <Number Of Threads To Run In Parallel> -TestCaseName "<Test Case Name To Execute>" -TestResultsDirectory "<Path To 'Test Result' Directory>"
#RunTest-Parallel -VSTestAdapterPath "<Path To 'vstest.console.exe' File>" -TestFileLocation "<Path To '.dll' file/files>" -Threads <Number Of Threads To Run In Parallel> -TestCaseName "<Test Case Name To Execute>" -TestResultsDirectory "<Path To 'Test Result' Directory>" -TestReportNamePrefix "<Prefixed Name Of Test Report (.trx) File>"