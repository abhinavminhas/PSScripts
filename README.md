# **posh**
*Repository with certain useful PowerShell Cmdlets, Scripts & Workflows.* <br><br>
![maintainer](https://img.shields.io/badge/Creator/Maintainer-abhinavminhas-e65c00)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# **Cmdlets**
A PowerShell [cmdlet](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-overview) is a lightweight command that is used in the PowerShell environment. The PowerShell runtime invokes these cmdlets within the context of automation scripts that are provided at the command line.  

1. [Configure-InternetSettings](./Cmdlets/Configure-InternetSettings-Cmdlet.ps1)  
   <ins>**Description:**</ins>  
   The function can manipulate internet settings provided as input to the cmdlet. Requires Internet Explorer.  
   <ins>**Usage Example:**</ins> 
   ```
   Configure-InternetSettings -EnableAutomaticDetectSettings "E" -EnableAutomaticConfigScript "E" -EnableProxy "E" -SetProxyServer "http://proxy.internal.poxy.com.au:8080" -EnableBypassProxy "E" -SetBypassLocalAddresses "<local>;www.google.com;www.yahoo.com"
   ```
   **NOTE** *Run cmdlet function file in PowerShell ISE and use below command for more help documentation and examples.*  
   ```
   Get-Help Configure-InternetSettings -Full
   ```

# **Scripts**
A PowerShell [script](https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/how-to-write-and-run-scripts-in-the-windows-powershell-ise) is a plain text file that contains one or more PowerShell commands. PowerShell scripts have a .ps1 file extension. Running a script usually is a lot like running a cmdlet.  

1. [Switch-ProcessorArchitecture64-Script](./Scripts/Switch-ProcessorArchitecture64-Script.ps1)  
   <ins>**Description:**</ins>  
   Switches Powershell running the 32-bit version on a 64-bit machine, forces PowerShell to run in 64-bit mode.  
   <ins>**Usage Example:**</ins>  
   ```
   powershell -executionpolicy bypass -File ".\Scripts\Switch-ProcessorArchitecture64-Script.ps1"
   ```

# **Workflows**
A PowerShell [workflow](https://docs.microsoft.com/en-us/system-center/sma/overview-powershell-workflows) is a sequence of programmed, connected steps that perform long-running tasks or require the coordination of multiple steps across multiple devices or managed nodes. The benefits of a workflow over a normal script include the ability to simultaneously perform an action against multiple devices and the ability to automatically recover from failures.  

1. [RunTest-Parallel](./Workflows/RunTest-Parallel-Workflow.ps1)  
   <ins>**Description:**</ins>  
   This workflow runs a supplied MSTest test in parallel.  