---
title: Powershell Scripts For Testing App-V Packages
slug: powershell-scripts-for-testing-app-v-packages
excerpt: Two simple Powershell scripts for importing and removing all App-V packages in a specific folder.
date: '2015-07-09 11:30:26'
redirect_from: /2015/07/powershell-scripts-testing-app-v-packages/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Powershell
---

I thought I'd share these as some of you may find them useful! When I am testing App-V packages, I generally either have them on a network share in one folder, or have copied them to my desktop, and want a simple way to add and remove them. These Powershell scripts do just this:

* **Add-AppvPackages.ps1 -** Searches recursively for all .appv files under the same folder as the script, adds them (without config files), and publishes them globally.
* **Remove-AppvPackages.ps1 -** Looks for all published App-V packages, and Stops/Repairs/Unpublishes/Removes any that have the path of the .appv file matching a package foundÂ under the same folder as the script.

Both scripts do these jobs in one line of code, albeit with a few lines at the start to relaunch the script with admin rights if required. For example, copy these scripts and a bunch of packages to your desktop, right-click the script and select Run with Powershell, and it will automatically prompt for elevation if you have UAC turned on (which you should).

**[Download them here.]({{ site.url }}{{ site.baseurl }}/downloads/AddRemove-AppvPackages.zip)**

{% highlight powershell %}
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID) 
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator 
if ($myWindowsPrincipal.IsInRole($adminRole) -eq $false)
{
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);
   exit
}

Get-ChildItem -path (Split-Path -parent $PSCommandPath) -recurse | where extension -eq .appv | Add-AppvClientPackage | Publish-AppvClientPackage -global
{% endhighlight %}

{% highlight powershell %}
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID) 
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator 
if ($myWindowsPrincipal.IsInRole($adminRole) -eq $false)
{
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);
   exit
}

Get-AppvClientPackage | Where Path -Match ([regex]::escape((Split-Path -parent $PSCommandPath))) | Stop-AppvClientPackage -Global | Repair-AppvClientPackage -UserState -Global | Unpublish-AppvClientPackage -Global | Remove-AppvClientPackage
{% endhighlight %}