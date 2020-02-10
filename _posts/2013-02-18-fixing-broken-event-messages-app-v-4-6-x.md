---
title: Fixing Broken Event Messages in App-V 4.6.x
slug: fixing-broken-event-messages-in-app-v-4-6
excerpt: How to handle apps that register custom event types in App-V 4.6.
date: '2013-02-18 16:08:24'
redirect_from: /2013/02/fixing-broken-event-messages-app-v-4-6-x/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I was given an app to troubleshoot today, **Becrypt Enterprise Manager Console**, part of an enterprise disk encryption system. The application displays Windows events, much like the built-in event viewer, but within its own console window, but they were not showing up correctly in the sequenced application, displaying instead as:

> "Message XXXX (Becrypt Enterprise Manager) could not be found."

First step as always was to install it locally. The MSI puts down some keys in `HKLM\System\CurrentControlSet\Services\Eventlog\Application`, but these were not captured in the sequence. There was no exclusion for this path configured in the sequencer, but there is a checkbox **'Allow Virtualization of Events'**, which did nothing to fix it - probably because this app is displaying events from remote machines rather than producing its own.

Now I knew that these keys were the culprit, I tried to add the keys manually to the sequence, but after launching regedit in the bubble to confirm, they did not show up! If I tried to import them manually from there, it fixed the event messages, but upon further inspection I discovered that these keys had leaked from the virtual environment into the actual registry! Same thing happened if trying to import these keys via a pre-launch script. The solution was to use the good old `<REGISTRY>` tags in the OSD file:

{% highlight xml %}
<VIRTUALENV>
<REGISTRY>
  <REGKEY HIVE="HKLM" KEY="SYSTEM\CurrentControlSet\Services\Eventlog\Application\Becrypt Enterprise Manager">
    <REGVALUE REGTYPE="REG_DWORD" NAME="CategoryCount">1000</REGVALUE>
    <REGVALUE REGTYPE="REG_SZ" NAME="EventMessageFile">C:\Windows\System32\BEMEvents.dll</REGVALUE>
    <REGVALUE REGTYPE="REG_DWORD" NAME="TypesSupported">31</REGVALUE>
  </REGKEY>
  <REGKEY HIVE="HKLM" KEY="SYSTEM\CurrentControlSet\Services\Eventlog\Application\DISK Protect">
    <REGVALUE REGTYPE="REG_DWORD" NAME="CategoryCount">1000</REGVALUE>
    <REGVALUE REGTYPE="REG_SZ" NAME="EventMessageFile">C:\Windows\System32\BCDPES.dll</REGVALUE>
    <REGVALUE REGTYPE="REG_DWORD" NAME="TypesSupported">31</REGVALUE>
  </REGKEY>
</REGISTRY>
</VIRTUALENV>
{% endhighlight %}

Now, these keys show up inside the virtual environment rather than the real registry, and the events display correctly.