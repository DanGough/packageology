---
title: Preventing VM's From Falling Off The Domain
slug: preventing-vms-falling-off-the-domain
excerpt: How to prevent your VMs from falling off the domain every 30 days due to computer password changes.
date: '2011-12-03 08:11:00'
redirect_from: /2011/12/preventing-vms-falling-off-the-domain/
layout: single
classes: wide
categories:
  - Other
tags:
  - Other
---

When working in a virtual lab continuously rolling back machine snapshots, unless you have taken steps to prevent it you may find your machines being kicked off of the domain (see [here](http://blogs.msdn.com/b/mikekol/archive/2009/03/18/does-restoring-a-snapshot-break-domain-connectivity-here-s-why.aspx) for a more detailed explanation). There's a registry tweak you can apply to stop this happening (from [http://support.microsoft.com/kb/154501](http://support.microsoft.com/kb/154501)):

{% highlight ini %}
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetLogon\Parameters]
"DisablePasswordChange"=dword:00000001
{% endhighlight %}

Also, the following article shows you how to do this via group policy:

[https://technet.microsoft.com/en-us/library/jj852191(v=ws.11).aspx](https://technet.microsoft.com/en-us/library/jj852191(v=ws.11).aspx)

You can either apply the policy to a limited number of test machines in their own OU, or if the domain is strictly being used for test purposes you can just apply it to the default domain policy like I did. After setting this key, either reboot or run the command `gpupdate /force` to apply the policy before taking your snapshots.

If the worst happens and you have to rejoin the domain, most people will take the machine off of the domain and join a workgroup, reboot, re-join the domain, then reboot again. However, you can skip this workgroup part altogether and save yourself an unnecessary reboot. The GUI for changing the computer name/domain will not let you press OK until you have changed the domain name or removed it. You can fool it into thinking you've changed it by trimming the name down to just keep the lowest level part, e.g. change '**testlab.local**' to just '**testlab**'. When you press OK, it should automatically resolve the fully qualified domain name:

[![Changing the domain name]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-03-preventing-vms-falling-off-the-domain/domainname.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-03-preventing-vms-falling-off-the-domain/domainname.png)