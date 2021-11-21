# **posh**
*Repository with certain useful PowerShell Cmdlets, Scripts & Workflows.*  

# **Cmdlets**
A powershell [cmdlet](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-overview) is a lightweight command that is used in the PowerShell environment. The PowerShell runtime invokes these cmdlets within the context of automation scripts that are provided at the command line.  

1. [Configure-InternetSettings](./Cmdlets/Configure-InternetSettings-Cmdlet.ps1)  
   The function can manipulate internet settings provided as input to the cmdlet. Requires Internet Explorer.  
   #### Usage Example ####
   ```
   Configure-InternetSettings -EnableAutomaticDetectSettings "E" -EnableAutomaticConfigScript "E" -EnableProxy "E" -SetProxyServer "http://proxy.internal.poxy.com.au:8080" -EnableBypassProxy "E" -SetBypassLocalAddresses "<local>;www.google.com;www.yahoo.com"
   ```
   **NOTE** *Run cmdlet function file in powesrhell ISE and use ```Get-Help Configure-InternetSettings -Full``` for more help documentation and examples.*

# **Scripts**
A powershell [script](https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/how-to-write-and-run-scripts-in-the-windows-powershell-ise) is a plain text file that contains one or more PowerShell commands. PowerShell scripts have a .ps1 file extension. Running a script usually is a lot like running a cmdlet.  

1. [Switch-ProcessorArchitecture64-Script](./Scripts/Switch-ProcessorArchitecture64-Script.ps1)  
   Switches Powershell running the 32-bit version on a 64-bit machine, forces powershell to run in 64-bit mode.  
   #### Usage Example ####
   ```
   powershell -executionpolicy bypass -File ".\Scripts\Switch-ProcessorArchitecture64-Script.ps1"
   ```

# **Workflows**
A powershell [workflow](https://docs.microsoft.com/en-us/system-center/sma/overview-powershell-workflows) is a sequence of programmed, connected steps that perform long-running tasks or require the coordination of multiple steps across multiple devices or managed nodes. The benefits of a workflow over a normal script include the ability to simultaneously perform an action against multiple devices and the ability to automatically recover from failures.  

1. [RunTest-Parallel-Workflow](./Workflows/RunTest-Parallel-Workflow.ps1)  
   This workflow runs a supplied MSTest test in parallel.  