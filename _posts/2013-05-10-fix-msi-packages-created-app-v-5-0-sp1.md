---
title: Fix for MSI packages created with App-V 5.0 SP1
slug: fix-msi-packages-created-with-app-v-5-0-sp1
excerpt: The MSI packages create by the 5.0 SP1 sequencer refuse to install on the client, so here is an MST to fix it.
date: '2013-05-10 17:00:37'
redirect_from: /2013/5/fix-msi-packages-created-app-v-5-0-sp1/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

**There is an updated version of this MST available from [this post]({% post_url 2016-08-14-fix-app-v-sequencer-generated-msi-packages %})**
{: .notice--warning}

So, having just started a project where I get to use App-V 5 outside of the lab environment, this of many posts I plan to make regarding v5, hopefully some of you may find it useful! The MSI packages created by the 5.0 SP1 sequencer refuse to install on the client, showing the following in the MSI log:

> Error: could not load custom action class Microsoft.AppV.MsiTemplate.CustomActions.CustomActions from assembly: AppVMsiPackageTemplate

Using InstEd, I generated a transform between a 5.0 and similar 5.0 SP1 package. I then stripped out all of the application-specific entries to be left with just a couple of changes to the binary table. These hold the custom action dlls responsible for the error above. To use this, just append the following to your msiexec command line:

`msiexec /i package.msi /qb **TRANSFORMS=AppV5_MSI_Fix.mst**`

Using InstEd/Orca or similar, you can also save a transformed version if you don't want to mess about with command lines. Use this at your own risk! Whilst everything appears to work fine so far, this is unsupported by Microsoft. I suspect that all the dlls are doing is running Powershell commands to import the package, and as far as I know these haven't changed, so you should be ok.

[Click here to download the MST.]({{ site.url }}{{ site.baseurl }}/downloads/AppV5_MSI_Fix.zip)

**UPDATE:**
<br><br>
Sebastian Gernert, App-V issue escalation engineer at Microsoft, has posted an alternative solution on his blog which involves adding a couple of registry keys to the client:
<br>
[http://blogs.msdn.com/b/sgern/archive/2013/05/23/10420879.aspx](http://blogs.msdn.com/b/sgern/archive/2013/05/23/10420879.aspx)
<br><br>
Or if you don't speak German:
<br>
[http://kirxblog.wordpress.com/2013/05/24/if-app-v-5-msis-arent-working](http://kirxblog.wordpress.com/2013/05/24/if-app-v-5-msis-arent-working)
{: .notice--info}