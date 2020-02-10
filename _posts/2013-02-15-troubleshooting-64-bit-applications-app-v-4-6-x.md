---
title: Troubleshooting 64-bit Apps in App-V 4.6.x
slug: troubleshooting-64-bit-applications-app-v-4-6-x
date: '2013-02-15 12:11:57'
redirect_from: /2013/02/troubleshooting-64-bit-applications-app-v-4-6-x/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I discovered a few things yesterday when trying to troubleshoot a 64-bit application in App-V - here are some notes!

* I was trying to view the contents of the virtual registry by launching regedit inside the bubble via ACDC v1.1. I could not see the HKLM keys of my virtual registry, only the HKCU keys. The same happened if I ran `sfttray /exe cmd "<APPNAME> <APPVERSION>"` and launched regedit from there.
* It turns out that this method was launching the 32-bit versions of cmd and regedit, which was confirmed by looking at the Processes tab of the task manager where the processes were appended with ***32**.
* The VM value in the OSD file was set to Win64, but it made no difference whether it was set to that or Win32.
* To get this to work correctly I had to specify the full path to cmd.exe in the sfttray command line, e.g:<br>`sfttray /exe c:\windows\system32\cmd.exe "<APPNAME> <APPVERSION>"`
* This also applies to regedt32.exe, odbcad32.exe and any other commonly used executables that have both a 64-bit version in C:\Windows\System32 and a 32-bit version in C:\Windows\SysWOW64.

I saw another curiosity whilst investigating this. I had the 32-bit regedt32.exe open, trying (and failing) to look for my 64-bit registry keys. Normally when you open the 32-bit regedit on 64-bit Windows, you don't see a Wow6432Node entry because of registry redirection - the HKLM\Software you are viewing is actually the HKLM\Software\Wow6432Node you would see in the 64-bit version of regedit.

However, I did have such a node, and not only that but it was an infinitely repeating copy of what I could already see in HKLM\Software! Regedit would only let me go 20 folders deep, e.g. HKLM\Software\Wow6432Node\Wow6432Node\Wow6432Node... until it stopped displaying them however. After a bit of digging I found that this happens when you delete the Wow6432Node registry key from the sequence of a 64-bit app (which I did in this case as it only contained junk IE settings). If you leave this key intact you will still see the Wow6432Node but get an error when trying to view it instead of infinitely recursing.

