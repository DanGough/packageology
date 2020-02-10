---
title: Demystifying the PVAD
slug: demystifying-the-pvad
excerpt: What is the PVAD, and why do some App-V apps only work when installed there?
date: '2017-11-26 22:00:23'
redirect_from: /2017/11/demystifying-pvad/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

**App-V 4.x** gave you the option of either installing an application to its default location on C: (known as a **VFS** install), or a special virtual drive Q: (known as an **MNT** install). Best practice was to use this MNT (or mount) drive since everything ran slightly quicker due to the file system driver not having to layer those files over the existing OS contents. However some apps were fussy and would only work with either an MNT of VFS install.

One of the first things the sequencer did was to ask you to enter the location of the root directory on Q: where you would be installing to. For **App-V 5**, Microsoft pretty much re-wrote everything from scratch. The virtual drive letter was no more, but the sequencer still asked the user where the Primary Virtual Application Directory (**PVAD**) was prior to sequencing. This caused many people to question why it still worked like this and found that you can just enter a dummy folder name in here every single time and most apps would still work just fine. In the end Microsoft removed this PVAD functionality from the sequencer (although you could bring it back with a startup switch or registry key).

Just as with App-V 4 where some apps required either a VFS or MNT install, today there are many apps that require to be sequenced to the PVAD in order to work. In fact it's one of my primary troubleshooting steps if an app is not working as expected, as it can often magically fix problems without having to bang your head against Procmon trying to work out what's going wrong. But what difference does it make under the hood if you install to the PVAD and why is it required to enable certain applications to work? I believe it boils down to two common reasons:

### Shortened Paths

Paths can get ridiculously long in App-V 5. Instead of running from `C:\Program Files\MyApp`, your app could now be running from `C:\ProgramData\App-V\ReallyLongGUID\AnotherReallyLongGUID\Root\VFS\ProgramFilesX64\MyApp`. This could make you hit the 260 character path limit, or hit another limit when it comes to shortcuts, especially if your command line features parameters that also contain these long paths. Sequencing to the PVAD means the app could be running directly from the Root folder, resulting in shortened paths. This problem is less common than the next one I will describe, but a PVAD install of some versions of Crystal Reports for example is known to resolve issues for this very reason.

### Path Values in the Registry

This was a eureka moment for me as it means it is possible to fix some apps by changing a single registry key instead of having to re-sequence them to the PVAD. If you have a registry value that points to the install location of your application, for example `C:\Program Files\MyApp`, they would be encoded differently in the registry of the resulting package depending on whether or not you used the PVAD:

* VFS Install:
    * `[{ProgramFilesX64}]\MyApp`
* PVAD Install:
    * `[{AppVPackageRoot}]` (assuming the PVAD was set to C:\Program Files\MyApp)

When the package is published on the client, these variables are replaced but they are handled rather differently. Inside the virtual environment, the registry values would read as:

* VFS Install:
    * `C:\Program Files\MyApp`
* PVAD Install:
    * `C:\ProgramData\App-V\ProductID\VersionID\Root`
    
Now, when you hit an issue with an app that doesn't like being installed to the VFS, you often get a cryptic error message suggesting that the app has realised things have moved. For example, ArcGIS:

[![ArcGIS]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-demystifying-pvad/ArcGIS.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-demystifying-pvad/ArcGIS.png)

Also WinZip (this is v15, they seem to have fixed this issue in recent versions BTW):

[![WinZip]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-demystifying-pvad/PVAD-error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-demystifying-pvad/PVAD-error.png)

I believe that App-V's file redirection works the same way for the VFS and PVAD; the exes are running from `C:\ProgramData\App-V` and if they ask the OS where they are running from they will be told so. If the app happens to request reads or writes to the `C:\Program Files` path originally installed with, then it will step in and perform the redirections as required. However, if you did a VFS install, **registry entries** would still say `C:\Program Files`. If the app tries to be too clever and verify itself by comparing the known install location pulled from the registry to the actual runtime location, that's when things can go awry.

So as an example, the error seen in WinZip above goes away if you open RegEdit in the bubble and change the registry key `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ProductCode\InstallLocation` to reflect the actual path where the exe now lives. So change the value from this:

`C:\Program Files\WinZip`

To this:

`C:\ProgramData\App-V\ProductID\VersionID\Root\ProgramFilesX64\WinZip`

So it appears that WinZip is saying *"hey Windows, where am I running from?"* and comparing that to this registry value, and thinking something is wrong if they don't match. To fix this in the actual package, you need to be a bit sneaky and substitute in the `[{AppVPackageRoot}]` variable. So the original value in the package when sequenced to the VFS would be:

`[{ProgramFilesX64}]\WinZip`

Change this to:

`[{AppVPackageRoot}]\VFS\ProgramFilesX64\WinZip`

I've fixed a handful of apps using this method now instead of having to re-sequence the entire application, I'll try and post more info as I encounter them!