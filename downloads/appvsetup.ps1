# App-V sequencer / client generic build script
# Version 1.0 - Dan Gough 04/07/15
# Version 1.1 - Fixed HideSCAHealth registry key
# Version 1.2 - Fixed install on 32-bit Windows
# Version 1.3 - Update for .NET 4.6 and Windows 10, better method of disabling Defender on Win8+
# Version 1.3.1 - Typo corrected

try {
    Clear-Host
    
    If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\AppV\Sequencer") { $setuptype = "Sequencer" }
    If (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\AppV\Client") { $setuptype = "Client" }

    If (-Not $setuptype) {
        Do {
            $choice = Read-Host -Prompt "Enter C to configure this machine as a client, or S to configure as a sequencer"
            If ($choice -eq "s") { $setuptype = "Sequencer" }
            If ($choice -eq "c") { $setuptype = "Client" }
        }
        Until ($setuptype)
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\AppV" -Name $setuptype -Force | Out-Null
    }

    Write-Host "Installing App-V pre-reqs..."
    cinst dotnet3.5
    cinst dotnet4.6
    cinst powershell4
    try { Update-Help }
    catch { Invoke-Reboot }

    Write-Host "Disabling automatic Windows Updates..."
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name AUOptions -PropertyType DWord -Value 1 -Force | Out-Null
    
    If (([environment]::OSVersion.Version.Major -eq 6 -and [environment]::OSVersion.Version.Minor -gt 1) -or ([environment]::OSVersion.Version.Major -gt 6)) {
        Write-Host "Disabling automatic Windows Store Updates..."
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" -Name AutoDownload -PropertyType DWord -Value 2 -Force | Out-Null
    }

    Enable-MicrosoftUpdate
    try {Install-WindowsUpdate -Criteria "IsHidden=0 and IsInstalled=0 and Type='Software'" }
    catch { Install-WindowsUpdate -Criteria "IsHidden=0 and IsInstalled=0 and Type='Software'" }

    Update-ExecutionPolicy Unrestricted
    
    Write-Host "Disabling Security Centre..."
    Set-Service -Name wscsvc -StartupType Disabled
    If ([environment]::OSVersion.Version.Major -lt 10) {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name HideSCAHealth -PropertyType DWord -Value 1 -Force | Out-Null
    }
    Else {
        If (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) { New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null }
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name DisableNotificationCenter -PropertyType DWord -Value 1 -Force | Out-Null
    }

    Write-Host "Disabling System Restore..."
    Disable-ComputerRestore -Drive "C:\"
    Start-Process -FilePath vssadmin -ArgumentList "delete shadows /for=c: /all /quiet" -Wait | Out-Null
    
    Write-Host "Peforming SSD optimisations..."
    Set-Service -Name SysMain -StartupType Disabled
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnableSuperfetch -PropertyType DWord -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name EnablePrefetcher -PropertyType DWord -Value 0 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\ReadyBoot" -Name Start -PropertyType DWord -Value 0 -Force | Out-Null
        
    Write-Host "Disabling computer password change..."
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NetLogon\Parameters" -Name DisablePasswordChange -PropertyType DWord -Value 1 -Force | Out-Null

    Write-Host "Configuring power options..."
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -h off
      
    Enable-RemoteDesktop

    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions

    If ([environment]::OSVersion.Version.Major -eq 6 -and [environment]::OSVersion.Version.Minor -gt 1) { 
        Set-StartScreenOptions -EnableBootToDesktop -EnableDesktopBackgroundOnStart -EnableShowStartOnActiveScreen -EnableShowAppsViewOnStartScreen -EnableSearchEverywhereInAppsView -EnableListDesktopAppsFirst
    }
 
    Write-Host "Pinning taskbar shortcuts..."
    Install-ChocolateyPinnedTaskBarItem "$env:windir\System32\cmd.exe"
    Install-ChocolateyPinnedTaskBarItem "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe"
    Install-ChocolateyPinnedTaskBarItem "$env:windir\regedit.exe"
    Install-ChocolateyPinnedTaskBarItem "$env:windir\Notepad.exe"
    Install-ChocolateyPinnedTaskBarItem "$env:windir\System32\SnippingTool.exe"

    Write-Host "Configuring Internet Explorer..."
    Disable-InternetExplorerESC
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name DisableFirstRunCustomize -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "Start Page" -PropertyType String -Value "about:blank" -Force | Out-Null

    switch ($setuptype)
    {
        "Client" {
        
            Write-Host "Setting up App-V Client build."
        
            #&".\App-V 5.0 SP3 Client\appv_client_setup.exe" /ACCEPTEULA /q | Out-Null
                        
            cinst appvmanage
            cinst ace
            cinst insted
            cinst 7zip
            cinst sysinternals
            If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { 
            Install-ChocolateyPinnedTaskBarItem "C:\Program Files (x86)\TMurgent\AppV_Manage\AppV_Manage.exe"
            Install-ChocolateyPinnedTaskBarItem "C:\Program Files (x86)\Virtual Engine\ACE\Ace.exe"
            }
            Else {
            Install-ChocolateyPinnedTaskBarItem "C:\Program Files\TMurgent\AppV_Manage\AppV_Manage.exe"
            Install-ChocolateyPinnedTaskBarItem "C:\Program Files\Virtual Engine\ACE\Ace.exe"
            }

        }

        "Sequencer" {
        
            Write-Host "Setting up App-V Sequencer build."

            Disable-UAC

            Write-Host "Disabling Windows Defender..."
            If ([environment]::OSVersion.Version.Major -eq 6 -and [environment]::OSVersion.Version.Minor -lt 2) {
                Set-Service -Name WinDefend -StartupType Disabled
            }
            Else {
                New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -PropertyType dword -Value 1 -Force | Out-Null
            }

            Write-Host "Disabling Windows Search..."
            Set-Service -Name WSearch -StartupType Disabled
            
            Write-Host "Disabling Sheduled Tasks..."
            schtasks /change /tn "\Microsoft\Windows\Application Experience\AitAgent" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\AutoChk\Proxy" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Diagnosis\Scheduled" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Maintenance\WinSAT" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\RAC\RacTask" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Registry\RegIdleBackup" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Windows Error Reporting\QueueReporting" /disable | Out-Null
            schtasks /change /tn "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary" /disable | Out-Null

            Write-Host "Creating dummy ODBC keys..."
            New-Item -Path "HKCU:\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" -Force | Out-Null
            New-Item -Path "HKLM:\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources" -Force | Out-Null
            If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\ODBC\ODBC.INI\ODBC Data Sources" -Force | Out-Null }

            #Install sequencer
            #&".\App-V 5.0 SP3 Sequencer\appv_sequencer_setup.exe" /ACCEPTEULA /q | Out-Null
            #Install-ChocolateyPinnedTaskBarItem "<Sequencer Path>"

        }
    }

    Write-Host "Optimising .NET assemblies..."
    Start-Process -FilePath "C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe" -ArgumentList "executeQueuedItems" -Wait
    If ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { Start-Process -FilePath "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe" -ArgumentList "executeQueuedItems" -Wait }

    Write-Host "Performing disk clean up..."
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" -Name "StateFlags0001" -PropertyType dword -Value 2 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup" -Name "StateFlags0001" -PropertyType dword -Value 2 -Force | Out-Null
    Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -Wait
    Remove-Item $env:temp\* -Force -Recurse
    Remove-Item C:\Windows\Temp\* -Force -Recurse
    #Zero unused sectors to allow VHD to be compacted efficiently with Optimize-VHD cmdlet
    $env:SEE_MASK_NOZONECHECKS = 1
    Start-Process -FilePath "\\live.sysinternals.com\tools\sdelete.exe" -ArgumentList "-AcceptEula -s -z c:" -Wait

    Write-ChocolateySuccess 'AppVSetup'

} catch {

  Write-ChocolateyFailure 'AppVSetup' $($_.Exception.Message)
  throw

}