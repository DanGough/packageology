---
title: Fix For App-V .NET Applications Broken By Recent Security Updates
slug: fix-for-net-applications-broken-by-security-updates
excerpt: A fix for App-V applications that may have stopped working after recent updates to the .NET Framework.
date: '2012-09-24 16:17:10'
redirect_from: /2012/09/fix-net-applications-broken-app-v-security-updates/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

Over the past 9 months or so I've either experienced or heard about issues where a sequenced .NET application runs fine on a clean App-V client but not a live production build. I recently found this again in **Attachmate Reflection 2011 R2 SP1**; I had a sequence that worked, but when I re-sequenced it, I got a '**CLR error: 80004005**' error when trying to launch on the customer's Windows 7 x64 desktop. It worked fine on my clean unpatched test VM however.

[![Error]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/Error1.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/Error1.png)

This application uses .NET 4, and a Google search indicated that re-installing the .NET Framework v4 might fix my problem, which indeed it did! I came to the conclusion that this was due to the fact that re-installing the framework also removes all of the .NET 4 related security updates. I grabbed a copy of these patches to see which ones could replicate the crash on my test machine:

* OK:
    * MS11-039 (KB2478663)
    * MS11-066 (KB2487367)
    * MS11-044 (KB2518870)
    * MS11-069 (KB2539636)
    * MS11-100 (KB2656351)
* Problematic:
    * MS11-078 (KB2572078)
    * MS12-035 (KB2604121)
    * MS12-016 (KB2633870)
    * MS12-025 (KB2656368)
    * MS12-034 (KB2656405)
    * MS12-038 (KB2686831)

So, one patch from 2011 and all of the ones from 2012 caused the issue. But simply not deploying these patches wasn't really an option for me. Luckily I was in a good position to troubleshoot as I had an older version of the sequence that worked fine with these .NET patches, so I set about comparing them. Through a bit of trial and error, I found that the registry keys under `HKLM\Software\Microsoft\Fusion\NativeImagesIndex` were the culprit. Here is what the working registry looked like:

[![Original working registry]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/OriginalWorkingRegistry.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/OriginalWorkingRegistry.png)

And the registry of the non-working app:

[![Broken registry]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/BrokenRegistry.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/BrokenRegistry.png)

There is a registry value `HKLM\Software\Microsoft\Fusion\NativeImagesIndex\v4.0.30319_32\LatestIndex` (set to **ee** in hex):

[![Latest index pointer]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/LatestIndexPointer.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/LatestIndexPointer.png)

Then a corresponding subkey named **indexee**:

[![Latest index]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/LatestIndex.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2012-09-24-fix-net-applications-broken-app-v-security-updates/LatestIndex.png)

Deleting this **indexee** subkey was enough to fix the application. By the way, you can also see the previous index entries were deleted during sequencing so are stored in the sequence in a deleted state, which hides the equivalent real keys from the virtual app. You cannot see these hidden deleted keys in the sequencer, but you can in [AVE](http://www.gridmetric.com/products/ave.html).

I don't fully understand how it works, but the .NET framework compiles .NET applications from MSIL to native machine code in the background via **ngen.exe** and these registry keys are responsible for storing the mappings between the two. Somehow the recent .NET patches don't get on with these settings - perhaps the patches wipe these keys clean on install but are of course unable to do so to the virtual registry.

You are _probably_ perfectly safe to just remove the entire **NativeImagesIndex** key. It's also conceivable that an application could generate this data after launch and store this information in the PKG files, then a .NET update could break the application. If this ever did happen then repairing the application should help.