---
title: 'App-V Shell Extensions Broken in Windows 10 1903/1909 (Now Fixed!)'
slug: app-v-shell-extensions-broken-in-1903-1909
date: '2020-03-16 08:30:00'
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

Shell extensions for App-V packages are broken in Windows 10 1903 and 1909. Previous OS versions are OK, even when fully patched.

{: .notice--info}
This issue has now been fixed in the [KB4550945](https://support.microsoft.com/en-us/help/4550945) update, released 21st April 2020!

Here's an example when trying to use the context menu from 7-Zip. The menu still appears but generates an error when trying to use it:

[![7-Zip Error]({{ site.url }}{{ site.baseurl }}/assets/images/2020-03-16-app-v-shell-extensions-broken-in-1903-1909/7-Zip Error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2020-03-16-app-v-shell-extensions-broken-in-1903-1909/7-Zip Error.png)

Note that you can also see this error on 1809 and previous if you enable App-V for the first time then try to use this functionality before rebooting.