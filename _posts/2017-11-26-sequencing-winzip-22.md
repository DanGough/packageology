---
title: Sequencing WinZip 22
slug: sequencing-winzip-22
excerpt: How to work around a sequencer bug that does not capture file associations properly in order to sequence WinZip 22.
date: '2017-11-26 22:07:53'
redirect_from: /2017/11/sequencing-winzip-22/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - WinZip
---

As demonstrated in my [previous article,]({% post_url 2017-11-26-demystifying-pvad %}) older versions of WinZip had issues with App-V 5, requiring you to either install to the PVAD or hack the registry to get it to run. WinZip fixed this at some point during the last couple of years, however I attempted the latest version 22 when writing that article only to find it fail in a completely different way! Try a standard sequence and select the option to edit the resulting capture before saving, and you will see this:

[![Manifest Error]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-sequencing-winzip-22/Manifest-error-1.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-sequencing-winzip-22/Manifest-error-1.png)

> Failed to load virtual services information - Failed to create a manifest instance.

The [last time]({% post_url 2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe %}) I hit a similar issue with the sequencer generating an invalid manifest, it crashed out completely, requiring you to choose the quick save option to even get a package out of it that you could even debug. At least now in this Windows 10 1703 sequencer things are handled a little more gracefully.

However it appears Microsoft have taken one step forward and two steps back here, as the event logs that you could view to identify exactly which section of the manifest was at fault are no longer in Windows 10 1703! I had to try and add this broken package to a Windows 7 machine with App-V 5.1 with the debug logs enabled in order to see the cause in the event viewer:

[![Manifest Error]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-sequencing-winzip-22/Manifest-error-3.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-sequencing-winzip-22/Manifest-error-3.png)

> ERROR: A manifest document failed validation against the schema(s).<br>DOM Error: -1072898030<br>Reason: Content for element '{http://schemas.microsoft.com/appv/2014/manifest}ProgId' is incomplete according to the DTD/Schema.<br>Expecting: {http://schemas.microsoft.com/appv/2014/manifest}Name.

To troubleshoot this we have to delve into the **AppxManifest.xml** file buried within the .appv package (you can extract it by treating it as a zip file). The error message says we are looking for a **ProgId** entry with no name, and it didn't take long to find one. Spot the difference between this file type association for **.hqx** and **.img**:

[![Prog IDs]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-sequencing-winzip-22/ProgIDs.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-sequencing-winzip-22/ProgIDs.png)

**.hqx** has a ProgId named **WinZip** associated with it; **.img** has a ProgId entry that has *no name*, and the same applies to the **.iso** extension. You could fix this in 3 ways:

1. Export the manifest within the sequencer and edit those extensions to match the structure of the other file extensions. Not recommended unless you *really* like XML.
2. Fix the original MSI package (assuming you grabbed the MSI version from WinZip's [alternative download page](http://www.winzip.com/win/en/dprob.html)) by filling in the word WinZip in the empty ProgId columns in the Extension table:<br>
<br>[![Extension Table]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-sequencing-winzip-22/Extension-table.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2017-11-26-sequencing-winzip-22/Extension-table.png)<br>
<br>NB: **wzcloud** has no ProgId in this table either, but the sequencer creates one for it, so I presume the only difference is because **.iso** and **.img** entries pre-exist in Windows and point to the ProgId **Windows.IsoFile**.
3. Add these registry entries after installing WinZip and whilst still monitoring:

{% highlight ini %}
[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.img]
@="WinZip"

[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\.iso]
@="WinZip"
{% endhighlight %}