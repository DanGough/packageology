---
title: Fix for Mouse Freezes in App-V Apps
slug: fix-for-mouse-freezes-in-app-v-apps
excerpt: Solve mouse freezes in App-V by updating the .NET Framework from v4.5.2 and applying a registry setting.
date: '2015-03-07 11:53:44'
redirect_from: /2015/03/fix-mouse-freezes-app-v-apps/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Hotfix
---

You may have seen Nicke Källén's blog post about this issue recently along with some workarounds provided by the App-V community:

[http://www.applepie.se/app-v-and-wisptis-exe](http://www.applepie.se/app-v-and-wisptis-exe)

Microsoft have now have an official knowledge base article for this:

[https://support.microsoft.com/en-us/kb/2987845](https://support.microsoft.com/en-us/kb/2987845)

The article describes a patch available for .NET 4.5.2:

[http://support.microsoft.com/kb/3026376/en-us](http://support.microsoft.com/kb/3026376/en-us)

The issue can also be resolved by updating to .NET 4.6, however the RTM release of that has a critical bug that you will want to patch:

[http://blogs.msdn.com/b/dotnet/archive/2015/07/28/ryujit-bug-advisory-in-the-net-framework-4-6.aspx](http://blogs.msdn.com/b/dotnet/archive/2015/07/28/ryujit-bug-advisory-in-the-net-framework-4-6.aspx)

**EDIT:** .NET 4.6.1 is now available which should fix the issues without the need for any additional .NET patches - this is the recommended way forward:

[https://www.microsoft.com/en-us/download/details.aspx?id=49982](https://www.microsoft.com/en-us/download/details.aspx?id=49982)

I have tested both of the above and found them to resolve the issue on my test machine. However, the problem was still occurring in one particular live environment for some reason unless I added the registry key listed in the article also. It appears that Microsoft have squeezed this fix into the 5.1 client, with the addition of wildcards either side of the GUID:

{% highlight ini %}
[HKLM\SOFTWARE\Microsoft\AppV\Subsystem\ObjExclusions]
"WPFMouseAndTouchInput"="*773F1B9A-35B9-4E95-83A0-A210F2DE3B37*"
{% endhighlight %}