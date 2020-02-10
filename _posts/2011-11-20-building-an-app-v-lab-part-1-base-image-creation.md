---
title: 'Building an App-V Lab Part 1: Base Image Creation'
slug: building-an-app-v-lab-part-1-base-image-creation
excerpt: Building an App-V lab with VMware Workstation. Part 1 - creating the base images.
date: '2011-11-20 13:00:39'
redirect_from: /2011/11/building-an-app-v-lab-part-1-base-image-creation/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - VMWare
---

This is the first thing many people will have to go through when starting to look at App-V. Although I have a lot of sequencing experience, I have been fortunate enough to have been supplied with pre-built virtual machines for the sequencer, client and App-V server. This time around I am doing it my own way, and sharing how I got there.

First of all, I am using VMWare Workstation for this, for the simple fact that I am very familiar with it and already have a license. I would have liked to use Hyper-V, but I don't have a dedicated box to run 2008 R2 on. I am building this on a freshly installed Windows 7 desktop machine equipped with an i7, 8GB RAM and a fast 256GB SSD. I decided to create simple base images of each OS, then make linked clones from each of these for specific tasks. Linked clones do run slightly slower than separate VMs, but the major advantage is they take up far less disk space, which is very important when using expensive SSD's! Since these machines will not undergo heavy loads and I could not even find any published performance benchmarks, I felt this was the best option.

To install the operating systems, I started with Windows 7 x64. I let VMWare do it's 'easy install', but didn't enter a product key and just entered 'Administrator' as the user name. Once it had booted up, I ran C:\Windows\System32\Sysprep\Sysprep.exe and selected to reboot into audit mode where I could perform a few common customisations, e.g:

* Change Explorer view options to show all file extensions, show hidden files, show and expand full browsing tree, etc
* Delete default pictures/music/videos, uninstall games

Note that any changes you make to the taskbar will not copy over to the default profile after Sysprepping - for that you will have to do a bit of [scripting!](http://theitbros.com/copy-taskbar-icons-windows-7-sysprep) Next for some simple optimisations. I gathered these from various sources but mainly this [VMWare guide](http://www.vmware.com/files/pdf/VMware-View-OptimizationGuideWindows7-EN.pdf) and also the Phase III whitepaper from [Project VRC](http://www.projectvrc.com/). First of all I performed the following:

* Disable Automatic Updates
* Delete all System Restore points and disable System Restore
* Disable Screensaver, set power plan to High Performance

I set the following services to manual:

* Diagnostic Policy Service
* Offline Files
* Windows Update

And these to disabled:

* Security Center
* Superfetch
* Windows Defender
* Windows Search

I also disabled the following scheduled tasks:

* Microsoft\Windows\Defrag\ScheduledDefrag
* Microsoft\Windows\Diagnosis\Scheduled
* Microsoft\Windows\DiskDiagnostic\DataCollector
* Microsoft\Windows\Maintenance\WinSAT
* Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem
* Microsoft\Windows\Registry\RegIdleBackup
* Microsoft\Windows\SystemRestore\SR
* Microsoft\Windows\WindowsBackup\ConfigNotification
* Microsoft\Windows Defender\MP Scheduled Scan
* Microsoft\Windows Defender\MPIdleTask

There were some additional tweaks I made via the registry:

{% highlight ini %}
;Disables First Run Wizard for Internet Explorer
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Internet Explorer\Main]
"DisableFirstRunCustomize"=dword:00000001

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application]
"MaxSize"=dword:00100000
"Retention"=dword:00000000
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Security]
"MaxSize"=dword:00100000
"Retention"=dword:00000000
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\System]
"MaxSize"=dword:00100000
"Retention"=dword:00000000

;Allows RDP to be used – ensure firewall is configured or turned off
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server]
"fDenyTSConnections"=dword:00000000
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp]
"UserAuthentication"=dword:00000000

;Disable NTFS last access time stamp
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem]
"NtfsDisableLastAccessUpdate"=dword:00000001

;Disable Superfetch, Prefetch and Readyboot – SSD optimisations
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SysMain]
"Start"=dword:00000004
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters]
"EnableSuperfetch"=dword:00000000
"EnablePrefetcher"=dword:00000000
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\ReadyBoot]
"Start"=dword:00000000

;Disable screensaver
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Control Panel\Desktop]
"ScreenSaveActive"="0"

;Ensures that temporary internet files are always purged
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Cache]
"Persistent"=dword:00000000

;Hide the Action Center Task Tray Icon
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAHealth"=dword:00000001
{% endhighlight %}

Once I was satisfied with the base image, I prepared an unattend.xml file using Windows System Image Manager from the Windows Automated Installation Kit, using some guidance from [here](http://theitbros.com/sysprep-a-windows-7-machine-%E2%80%93-start-to-finish). You can download a sample of the file I created [here]({{ site.url }}{{ site.baseurl }}/downloads/Win7-x64-Unattend.zip).

This needs to be copied to the C:\Windows\System32\Sysprep folder, then Sysprep can be run once more with the following command:

`C:\windows\system32\sysprep\sysprep /generalize /oobe /shutdown /unattend:C:\windows\system32\sysprep\unattend.xml`

Once it has shut down, take a snapshot. You can then follow a similar process to create clean Sysprepped images of Windows Server 2008 R2, Windows 7 x86, or whatever you require. Bear in mind that the Server OS won't use the same optimisations as Windows 7, and each will require their own unattend.xml file. Once you have a Sysprepped base image for each OS, you can create your linked clones. I created a Domain Controller and an App-V Management Server from my Windows Server 2008 R2 image, and App-V sequencer and client machines using both 32-bit and 64-bit variants of Windows 7.

Click here for [Part 2]({% post_url 2011-11-21-building-an-app-v-lab-part-2-building-the-network %}) where I cover configuring the domain controller and VMWare networking.