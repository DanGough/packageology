---
title: User Scripts Broken In App-V 5.0 SP2 For Local Accounts
slug: user-scripts-broken-in-app-v-5-0-sp2-for-local-accounts
date: '2014-03-25 14:24:25'
redirect_from: /2014/03/user-scripts-broken-app-v-5-0-sp2-local-accounts/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

This bug is now fixed in Windows 10.
{: .notice--success}

I received a comment on my post ['Fixing File Permissions in App-V 5'](http://packageology.com/2013/06/file-permissions-app-v-5/ "Fixing File Permissions in App-V 5") from someone that was unable to run the script since updating to SP2. I did a bit of testing in my home lab and found it still worked fine, so put it down to user error and carried on with my day. Until, that is, I got the very same error working on a client's system. I had a UserScript configured to run at StartVirtualEnvironment, but whenever it was launched I saw the following error:

[![Script error]({{ site.url }}{{ site.baseurl }}/assets/images/2014-03-25-user-scripts-broken-app-v-5-0-sp2-local-accounts/Script-error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-03-25-user-scripts-broken-app-v-5-0-sp2-local-accounts/Script-error.png)

[![MSVCR100 error]({{ site.url }}{{ site.baseurl }}/assets/images/2014-03-25-user-scripts-broken-app-v-5-0-sp2-local-accounts/MSVCR100-error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-03-25-user-scripts-broken-app-v-5-0-sp2-local-accounts/MSVCR100-error.png)

The error code 534 in hex (1332 decimal) can be looked up [here](http://msdn.microsoft.com/en-us/library/windows/desktop/ms681385(v=vs.85).aspx "System Error Codes"):

> **ERROR_NONE_MAPPED**<br>**1332 (0x534)**<br>No mapping between account names and security IDs was done.

As well as the 534 error, I was getting an MSVCR100.dll not found error. Disabling App-V scripts stops both of these error messages and the application loads correctly. The second error is a curious one, since by default if you install only the App-V 5.0 SP2 client on a clean machine, you will only have the 64-bit MSVCR100.dll present in C:\Windows\System32. For some reason, the 32-bit virtual application is being told to use this dll when it doesn't exist under C:\Windows\SysWOW64. I think this second error is nothing to worry about, being just a curious side effect of the virtual environment not starting up correctly due to the first error.

So after a lengthy troubleshooting session examining the differences between the working and non-working systems, I came to the conclusion that user scripts are broken in App-V 5.0 SP2 for **local accounts** only. Log on with a domain account and everything is ok. Whether or not the accounts have admin rights or not makes no difference. The RTM and SP1 releases are not affected by this issue.

Luckily pretty much all live implementations of App-V will be used with everybody logging on with domain accounts, so this isn't a major issue. Packagers however tend to sequence and test using local admin accounts, which is where I and others ran into the problem!

