---
title: Launching reg / bat / cmd / vbs files in App-V 5
slug: launching-reg-bat-cmd-vbs-files-in-app-v-5
excerpt: Not all shortcuts in App-V 5 launch inside the bubble. In particular, any shortcuts to .bat or .cmd files need to be modified to point to cmd.exe.
date: '2013-06-03 07:59:24'
redirect_from: /2013/06/launching-reg-bat-cmd-vbs-files-app-v-5/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

App-V 5 behaves a little differently to App-V 4 when it comes to launching files with different file extensions. For instance, if you have a shortcut pointing to a PDF file, in App-V 4 this could prove a problem if Adobe Reader was already running since it would pass the command onto the already running instance, asking it to open a file in the virtual environment that it could not see.

This is no longer a problem in App-V 5 since the shortcut points directly to a PDF file under C:\ProgramData, which Adobe Reader can open since the location is always visible. I had the pleasure of sequencing an application recently that had start menu shortcuts to .reg files to configure the application in different ways. When launching these .reg files, the registry settings were applied locally, outside of the virtual environment, which were then hidden from the application due to the main keys being set to override.

The solution to this was to point the shortcuts to `reg.exe import <Path to reg file>` instead. But then I had to do a couple of tests to satisfy my curiosity to see what would happen with batch files and vbscripts! I created a .bat, .cmd and .vbs file that each created a registry key under HKCU and added them to a sequence. A point of note is that the vbscript uses the **RegRead** method, since the WMI method will always write outside of the bubble anyway due to the WMI Windows service being run outside of App-V.

### Test.bat:
{% highlight biml %}
reg add HKCU\Software\Test /v Test.bat /d Success /f
{% endhighlight %}

### Test.cmd:
{% highlight biml %}
reg add HKCU\Software\Test /v Test.cmd /d Success /f
{% endhighlight %}

### Test.vbs:
{% highlight visualbasic %}
Set wshShell = CreateObject("WScript.Shell")
wshShell.RegWrite "HKCU\Software\Test\Test.vbs", "Success", "REG_SZ"
{% endhighlight %}

The result was that the .bat and .cmd wrote the registry keys **outside** of the virtual environment, whereas the .vbs file wrote the registry entry **inside** the virtual environment as desired.

Weirdly, if you right-click the shortcut and run as administrator, it both .bat and .cmd will run inside the bubble!

To workaround this you can change the shortcut to run:

`cmd.exe /c <Path to batch file>`

I don't know why .vbs behaves differently and we don't have to resort to using `wscript.exe <Path to script file>`, but nobody ever said that any of this would make any sense!