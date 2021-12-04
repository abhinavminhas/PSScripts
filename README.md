# **posh**
*Repository with certain useful **PowerShell** Cmdlets, Scripts & Workflows.* <br><br>
![maintainer](https://img.shields.io/badge/Creator/Maintainer-abhinavminhas-e65c00)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# **Cmdlets**
A PowerShell [cmdlet](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-overview) is a lightweight command that is used in the PowerShell environment. The PowerShell runtime invokes these cmdlets within the context of automation scripts that are provided at the command line.  

-  [Update-InternetSettings](./Cmdlets/Update-InternetSettings-Cmdlet.ps1)  
   <ins>**Description:**</ins>  
   The function can manipulate internet settings provided as input to the cmdlet. Requires Internet Explorer to enforce changes.  
   <ins>**Usage Example:**</ins> 
   ```
   Update-InternetSettings -EnableAutomaticDetectSettings "E" -EnableAutomaticConfigScript "E" -SetAutomaticConfigurationURL "//configuration.pac" -EnableProxy "E" -SetProxyServer "http://proxy.internal.poxy.com.au:8080" -EnableBypassProxy "E" -SetBypassLocalAddresses "<local>;www.google.com;www.yahoo.com"
   ```
   **NOTE:** *Run cmdlet function file in PowerShell ISE and use below command for more help documentation and examples.*  
   ```
   Get-Help Update-InternetSettings -Full
   ```

-  [Get-CodedUIHTMLLogger](./Cmdlets/Get-CodedUIHTMLLogger-Cmdlet.ps1)  
   <ins>**Description:**</ins>  
   This function gets the generated Coded UI HTML logger report files from the 'Test Results' folder.  
   <ins>**Usage Example:**</ins> 
   ```
   Get-CodedUIHTMLLogger -TestResultsPath "C:\Test\TestResults" -Zipped -ZippedFileName "Logger Reports"
   ```
   **NOTE:** *Run cmdlet function file in PowerShell ISE and use below command for more help documentation and examples.*  
   ```
   Get-Help Get-CodedUIHTMLLogger -Full
   ```

-  [Get-MatchedStringFromFiles](./Cmdlets/Get-MatchedStringFromFiles-Cmdlet.ps1)  
   <ins>**Description:**</ins>  
   This function gets the matching string values from the supplied files.  
   <ins>**Usage Example:**</ins> 
   ```
   Get-MatchedStringFromFiles -FileFolderPath <File Folder Path> -Regex "<Regular Expression>" -FileIncludeFilter "<File Include Filter>" -FileExcludeFilter "<File Exclude Filter>"
   ```
   **NOTE:** *Run cmdlet function file in PowerShell ISE and use below command for more help documentation and examples.*  
   ```
   Get-Help Get-MatchedStringFromFiles -Full
   ```

# **Scripts**
A PowerShell [script](https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/ise/how-to-write-and-run-scripts-in-the-windows-powershell-ise) is a plain text file that contains one or more PowerShell commands. PowerShell scripts have a .ps1 file extension. Running a script usually is a lot like running a cmdlet.  

-  [Switch-ProcessorArchitecture64-Script](./Scripts/Switch-ProcessorArchitecture64-Script.ps1)  
   <ins>**Description:**</ins>  
   Switches Powershell running the 32-bit version on a 64-bit machine, forces PowerShell to run in 64-bit mode.  
   <ins>**Usage Example:**</ins>  
   ```
   powershell -executionpolicy bypass -File ".\Scripts\Switch-ProcessorArchitecture64-Script.ps1"
   ```

# **Workflows**
A PowerShell [workflow](https://docs.microsoft.com/en-us/system-center/sma/overview-powershell-workflows) is a sequence of programmed, connected steps that perform long-running tasks or require the coordination of multiple steps across multiple devices or managed nodes. The benefits of a workflow over a normal script include the ability to simultaneously perform an action against multiple devices and the ability to automatically recover from failures.  

-  [RunTest-Parallel](./Workflows/RunTest-Parallel-Workflow.ps1)  
   <ins>**Description:**</ins>  
   This workflow runs a supplied MSTest test in parallel.  