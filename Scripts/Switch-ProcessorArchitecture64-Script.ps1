#########################################################
# Summary: This script tests if Powershell is
#          running in 32-bit mode and if true
#          launches itself in 64-bit mode for completion
#########################################################

###########################################################################################################
# If Powershell is running the 32-bit version on a 64-bit machine, forces powershell to run in 64-bit mode.
###########################################################################################################

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