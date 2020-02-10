---
title: App-V 5 Does Not Like Shortcut Names That End With A Space!
slug: app-v-5-shortcut-names-that-end-with-a-space
excerpt: If your shortcut name ends in a space it creates a config XML file that SCCM cannot handle.
date: '2014-08-07 09:34:16'
redirect_from: /2014/08/app-v-5-shortcut-names-space/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I just sequenced an app that deployed a shortcut with a space at the end of the name, which went unnoticed. I imported the resulting package using PowerShell to quickly test and all worked fine, but it failed to deploy with SCCM due to an XML validation error. SCCM will always use the configuration XML files, but I did not apply these during testing as I had not made any changes to them!

The event log read:

> Failed to validate provided xml.<br><br>DOM Error: Unknown HResult Error code: 0xc00ce169_ _Reason: 'MYAPPNAME' violates pattern constraint of '[^\s]\|([^\s].*[^\s])'.<br><br>The element '{http://schemas.microsoft.com/appv/2010/deploymentconfiguration}Name' with value 'MicrodietV2 ' failed to parse.

So for some reason a name ending in a space is perfectly valid in the manifest file contained within the .appv file, but not in the external XML files. Watch out for this, and Microsoft please update the regular expression in your schema to allow for this, or at least detect/correct it in the sequencer!