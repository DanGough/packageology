---
title: Overriding Group Policy Settings With App-V
slug: overriding-group-policy-settings-with-app-v
excerpt: Group Policy registry settings captured in App-V packages do not alway work in App-V.
date: '2014-02-05 00:02:06'
redirect_from: /2014/02/overriding-group-policy-settings-app-v/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

There are certain situations where it is desirable to override group policy settings in an App-V package, for example:

*   Relaxing security settings to enable Data URI support in Internet Explorer in the virtual environment
*   Increasing security to restrict a virtualised legacy Java version so that only specific websites can access it

The last statement made by Microsoft on this subject was that it is not supported, and as of App-V 4.5, the client will ignore any policy registry keys in the package:

[http://blogs.technet.com/b/appv/archive/2009/04/23/some-insight-into-how-softgrid-and-app-v-4-5-handle-group-policies.aspx](http://blogs.technet.com/b/appv/archive/2009/04/23/some-insight-into-how-softgrid-and-app-v-4-5-handle-group-policies.aspx "The Microsoft App-V Team Blog - Some insight into how SoftGrid and App-V 4.5 handle group policies")

I'm not sure if Microsoft changed their stance on this at some point, but in my testing with App-V 4.6 SP3, any registry keys stored under **HKLM\Software\Policies** work just fine and are read and used by the virtual application. However, in a DSC linking scenario, any policies from the child packages are ignored similar to the way described in the link above; **only policy keys in the parent package are used**.

With App-V 5.0, **all policies are ignored by default**. Any attempt to read or write to **HKLM\Software\Polices**, **HKCU\Software\Policies**, or even **HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings**, will get redirected to the native registry. Thankfully this is all configurable however! Please note that this is a global setting that will affect all virtual applications on the client, so care must be taken to avoid capturing policy settings in other packages unintentionally. Here is the registry key in question, along with its default contents:

{% highlight ini %}
[HKEY_LOCAL_MACHINE \SOFTWARE\Microsoft\AppV\Subsystem\VirtualRegistry]
PassThroughPaths = REG_MULTI_SZ :
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\eventlog\Application
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger
HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib
HKEY_LOCAL_MACHINE\SOFTWARE\Policies
HKEY_CURRENT_USER\SOFTWARE\Policies
{% endhighlight %}

Delete the value **HKEY_LOCAL_MACHINE\SOFTWARE\Policies** to allow the policy keys captured in the package to work. It appears that policies in HKLM override any equivalent policies placed in HKCU, so I advise just erasing this value and ensuring any policy values required in your sequences are stored under HKLM.

With connection groups, the policies can be placed in any of the packages, although the final result may be affected by the package load order and the merge/override status of the registry keys.

I recommend that all keys are set to merge unless you absolutely want to override all content from a policy area in the native registry. For example, if **HKLM\SOFTWARE\Polices\Microsoft\Windows\CurrentVersion\Internet Settings** is captured and set to override, it may mask setting such as the proxy configuration, resulting in the browser not functioning correctly.

