---
title: Sequencing LibreOffice
slug: sequencing-libreoffice
excerpt: How to sequence LibreOffice 4.1.6 in App-V 5.
date: '2015-10-07 10:34:02'
redirect_from: /2015/10/sequencing-libreoffice-4-1-6/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

Not many of you would want to actually sequence this... If you are using App-V, chances are you have licenses to use Microsoft Office already! But if you want to learn a cool trick that might help out with other apps, read on!

This one was coming up with an error on launch:

[![LibreOfficeError]({{ site.url }}{{ site.baseurl }}/assets/images/2015-10-07-sequencing-libreoffice-4-1-6/LibreOfficeError.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2015-10-07-sequencing-libreoffice-4-1-6/LibreOfficeError.png)

Procmon showed that it was trying to access (but could not find) the user profile of the account used to sequence it, even though it was not launched during sequencing, there was no appdata folder in the package, and there was no evidence of the user name stored anywhere that I could find. This is a prime example of why you should always use a different account to test the app than the one used to sequence it by the way!

My solution was to install the MSI under the System account during monitoring. The user profile for this account is stored under *C:\Windows\System32\config\systemprofile*, and with VFS Write enabled, users should not have a problem accessing this folder within the bubble. To do this I used Sysinternals tool [PsExec](https://technet.microsoft.com/en-gb/sysinternals/bb897553.aspx) to start a CMD prompt as System:

`psexec -s -i cmd`

Then install the software from within there. Now the sequenced package works! I could not find it trying to write to the System profile during use, instead the application writes to *%APPDATA%\LibreOffice* as intended, but this little trick solved whatever was causing it to hiccup during launch previously.