---
title: Running 32-bit MMC snap-ins in App-V on 64-bit Windows
slug: running-32-bit-mmc-snap-ins-app-v-64-bit-windows
excerpt: Modifying shortcuts to .mmc files to make them compatible with App-V 4.x.
date: '2012-02-17 16:58:11'
redirect_from: /2012/02/running-32-bit-mmc-snap-ins-app-v-64-bit-windows/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I came across an issue today whilst sequencing an application on Windows 7 x64 that contained a start menu shortcut to a .MSC file. During sequencing the application launched fine but it would not do so on the client. The solution is to modify the OSD to point to MMC.exe with the `-32` switch and the path to your .MSC file wrapped in quotes:

{% highlight xml %}
<CODEBASE HREF="*" GUID="*" FILENAME="%CSIDL_SYSTEM%\mmc.exe" PARAMETERS="-32 &quot;%SFT_MNT%\ROOTFOLDER\PathToFile.msc&quot;" SYSGUARDFILE="*" SIZE="*"/>
{% endhighlight %}

You will also need to set the __COMPAT_LAYER environment variable if MMC.exe requests elevation:

{% highlight xml %}
<ENVLIST>
  <ENVIRONMENT VARIABLE="__COMPAT_LAYER">RunAsInvoker</ENVIRONMENT>
</ENVLIST>
{% endhighlight %}

This should allow it to work on both x86 and x64 clients.