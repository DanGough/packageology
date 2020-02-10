---
title: App-V Connection Group Registry Corruption Bug
slug: app-v-connection-group-registry-corruption-bug
excerpt: Prior to the latest App-V hotfixes, trying to write a value containing C:\ to a HKCU key within a connection group would corrupt the virtual registry.
date: '2018-03-10 21:23:21'
redirect_from: /2018/03/app-v-connection-group-registry-corruption-bug/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Hotfix
---

The [latest patches]({% post_url 2018-03-10-app-v-hotfixes %}) for App-V contain this in the list of fixed issues:

* Addresses an issue in which the user's hive data in the registry isn't maintained correctly when some App-V packages belong to the connection group.

Having recently hit this issue myself but not found it described anywhere online, I thought I'd detail the symptoms of this issue so that you can know what to look for if you happen to be stuck using a system without the latest patches! Prior to these fixes, if using the VREG registry system, i.e. App-V 5.1 or Windows 10 1703/1709 prior to the aformentioned patches but with VREG enabled via a registry setting:

{% highlight ini %}
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\Client\Compatibility]
"RegistryCompatibilityMode"=dword:00000001
{% endhighlight %}

If you tried to write a registry value under HKCU containing the string `C:\` anywhere within, it would result in a corrupt unreadable value and also prevent the system from reading any further keys added after that point:  

[![VREG bug 1]({{ site.url }}{{ site.baseurl }}/assets/images/2018-03-10-app-v-connection-group-registry-corruption-bug/VREG-bug-1.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2018-03-10-app-v-connection-group-registry-corruption-bug/VREG-bug-1.png)

Regedit would also show the values as missing:  

[![VREG bug 2]({{ site.url }}{{ site.baseurl }}/assets/images/2018-03-10-app-v-connection-group-registry-corruption-bug/VREG-bug-2.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2018-03-10-app-v-connection-group-registry-corruption-bug/VREG-bug-2.png)

The value `C:\` could be anywhere within the string; other driver letters seem to be ok, and both the colon and backslash are required to trigger it. Plenty of apps like to store data under HKCU listing configuration items such as folder locations, it appears that these apps could have been potentially broken when using connection groups prior to these patches!