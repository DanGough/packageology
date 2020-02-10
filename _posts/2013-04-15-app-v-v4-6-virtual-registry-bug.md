---
title: App-V v4.6 Virtual Registry Bug
slug: app-v-v4-6-virtual-registry-bug
excerpt: An App-V 4.6 bug where having a user-specific path under HKLM breaks the virtual registry.
date: '2013-04-15 21:44:25'
redirect_from: /2013/04/app-v-v4-6-virtual-registry-bug/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I came across a strange issue today whilst sequencing [Oracle Developer Suite 10g](http://www.oracle.com/technetwork/developer-tools/developer-suite/downloads/index.html). Sequencing appeared to work at first but some of the shortcuts were not working correctly. Upon opening regedit in the bubble to troubleshoot I found that most of my registry settings had disappeared! Here is what the registry was supposed to look like:

[![Real Registry]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/RegistryReal.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/RegistryReal.png)

And here is what I saw from inside the virtual environment:

[![Virtual Registry]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/RegistryVirtual.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/RegistryVirtual.png)

It appeared that the App-V client had helpfully thrown out all of my settings and subkeys except for one suspicious key with a path to a user variable, sitting in the HKLM registry. Thanks! Whilst no developer in their right mind would normally store user specific settings under HKLM, this is Oracle we are talking about here, so common sense does not apply. I experimented by removing this **REPORTS_TMP** key in the sequencer, and all of the missing values came back! If I put any user specific variables in, the same would happen, **%CSIDL_APPDATA%**, **%CSIDL_DESKTOPDIRECTORY%**, etc - but variables such as **%CSIDL_PROGRAM_FILES%** worked fine.

So, this is weird, but I had a workaround - delete the problematic key in the sequencer and add `<REGISTRY>` tags in the OSD files to bring the setting back. But I did a quick test on my own environment, fully patched to **v4.6 SP2 Hotfix 1** to see if I could replicate it. I created a new sequence containing just the following registry keys:

{% highlight ini%}
[HKEY_LOCAL_MACHINE\Software\Wow6432Node\TEST32]
"Normal String 1"="Hello"
"Normal String 2"="World!"
"User Folder 1"="C:\\Users\\testadmin\\AppData\\Local\\Temp"
"User Folder 2"="C:\\Users\\testadmin\\AppData\\Roaming"

[HKEY_LOCAL_MACHINE\Software\TEST64]
"Normal String 1"="Hello"
"Normal String 2"="World!"
"User Folder 1"="C:\\Users\\testadmin\\AppData\\Local\\Temp"
"User Folder 2"="C:\\Users\\testadmin\\AppData\\Roaming"

[HKEY_CURRENT_USER\Software\TEST]
"Normal String 1"="Hello"
"Normal String 2"="World!"
"User Folder 1"="C:\\Users\\testadmin\\AppData\\Local\\Temp"
"User Folder 2"="C:\\Users\\testadmin\\AppData\\Roaming"
{% endhighlight%}

And also a couple of desktop shortcuts pointing to `%CSIDL_SYSTEM%\regedt32.exe` (32-bit regedit) and `%SFT_SYSTEM32_X64%\regedt32.exe` (64-bit regedit) to help troubleshoot. Here are the keys in the sequencer:

[![Sequencer]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/Sequencer.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/Sequencer.png)

After importing into the client, the HKCU registry settings are displaying properly:

[![HKCU Results]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/HKCU.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/HKCU.png)

But both 32-bit and 64-bit portions of the HKLM keys were only displaying the keys containing user-related variables:

[![Test32 Results]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/Test32Results.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/Test32Results.png)

[![Test64 Results]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/Test64Results.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-04-15-app-v-v4-6-virtual-registry-bug/Test64Results.png)

So, bear this in mind - if you're troubleshooting and are not seeing much in the HKLM registry except for some user directories, look for this. Delete the keys from the sequence and add them either by `<REGISTRY>` tags if you don't mind them being reset on each launch, or by using a pre-launch script if you think that the users may wish to change the values themselves when using the application.