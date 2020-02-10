---
title: Fixing VLC's MSI Package
slug: fixing-vlcs-msi-package
excerpt: VLC offer a hidden MSI release on their FTP site. Unfortunately they built it under WINE and the resulting package is corrupt and cannot be modified.
date: '2019-01-24 22:24:06'
redirect_from: /2019/01/fixing-vlcs-msi-package/
layout: single
classes: wide
categories:
  - MSI
---

VLC don't shout about it, but they have offered an MSI package to download for some time from their FTP site:

[https://download.videolan.org/pub/videolan/vlc/](https://download.videolan.org/pub/videolan/vlc/)

However the packages suffer from a strange bug where any attempt to modify the tables or apply an MST (to delete the desktop shortcut for example) corrupts the database and breaks the installer.
<!--More-->
It turns out this is because the developers are building the MSI package on Linux with WiX running under WINE, which is listed as incompatible on WINE's AppDB. There is an open ticket for this here:

[https://trac.videolan.org/vlc/ticket/18985](https://trac.videolan.org/vlc/ticket/18985)

I tried exporting the database tables to a new MSI and repacking the cab files with InstEd Plus (if you deal with MSIs regularly you should [buy it!](http://www.instedit.com/instedplus.html). This fixed the problem, and so I have created a Powershell script to perform the same tasks.

This script leverages Deployment Tools Foundation (DTF), a very useful .NET wrapper around the Windows Installer API that comes from the [WiX Toolset](http://wixtoolset.org). It also shoehorns in WiMakCab.vbs from the now defunct Windows Installer SDK to perform the cab file operations (until I figure out how to do this natively with DTF!).

Simply put your VLC MSI packages you want to rebuild into the Input folder and run Rebuild-Msi.ps1. Then you will be able to modify the package to tweak shortcuts, automatic updates, privacy settings, file associations, etc without it breaking on you.

Download the script below:

[VLC MSI Patcher v1.0]({{ site.url }}{{ site.baseurl }}/downloads/VLC-MSI-Patcher-v1.0.zip)

