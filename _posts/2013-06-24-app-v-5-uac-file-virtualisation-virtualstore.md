---
title: App-V 5 and UAC File Virtualisation
slug: app-v-5-and-uac-file-virtualisation
excerpt: App-V does not handle files or registry entries redirected to the VirtualStore via UAC virtualisation.
date: '2013-06-24 20:05:26'
redirect_from: /2013/06/app-v-5-uac-file-virtualisation-virtualstore/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

In App-V 5 we no longer have PKG files, and changes made by the user are stored hidden away in various folders and registry keys instead. Check out Thamim Karim's articles [here](http://blogs.technet.com/b/virtualvibes/archive/2013/03/28/app-v-5-0-os-integration-part-2-file-system-cache.aspx), [here](http://blogs.technet.com/b/virtualvibes/archive/2013/03/28/app-v-5-0-os-integration-part-3-registry.aspx) and [here](http://blogs.technet.com/b/virtualvibes/archive/2013/04/29/app-v-5-0-os-integration-part-4-state-changes.aspx) for a full explanation of how these locations work. But essentially, file changes are stored in the following locations:

* %APPDATA%\Microsoft\AppV\Client\VFS (for roaming appdata)
* %LOCALAPPDATA%\Microsoft\AppV\Client\VFS (for everything else)

Whilst registry changes are stored here:

* HKCU\Software\Microsoft\AppV\Client\Packages\<PackageId>\REGISTRY
* HKCU\Software\Classes\AppV\Client\Packages\<PackageId>\REGISTRY
* HKLM\SOFTWARE\Microsoft\AppV\Client\Packages\<PackageId>\REGISTRY (when running elevated)

However, this is not always the case. If you are running an app under the following conditions:

* You have UAC enabled
* You are not running the app as administrator
* The app is 32-bit
* The app has no embedded or external manifest to tell it which execution level to use (i.e. asInvoker, highestAvailable, requireAdministrator) - typically all applications pre-Vista, and even some still being made today

Then the app will automatically redirect failed writes to certain system areas such as **C:\Program Files** and **HKLM\Software** to the following locations via a process known as **UAC file virtualisation** (not to be confused with App-V virtualisation):

* %LOCALAPPDATA%\VirtualStore
* HKCU\Software\Classes\VirtualStore

Now, consider that you are sequencing such an application and you have UAC enabled. Instead of launching the application from the sequencer interface, which is running elevated, you run it via its shortcut and configure the application. If it is a badly written legacy app that tries to write to these system areas, Windows silently redirects the write operations to the locations shown above. Files will be excluded from the resulting sequence if you are using the default sequencer configuration to exclude %LOCALAPPDATA%, and registry will be captured under the VirtualStore key:

[![Exclusion Warning]({{ site.url }}{{ site.baseurl }}/assets\images\2013-06-24-app-v-5-uac-file-virtualisation-virtualstore/ExclusionWarning.png)]({{ site.url }}{{ site.baseurl }}/assets\images\2013-06-24-app-v-5-uac-file-virtualisation-virtualstore/ExclusionWarning.png)

[![Captured Virtual Registry]({{ site.url }}{{ site.baseurl }}/assets\images\2013-06-24-app-v-5-uac-file-virtualisation-virtualstore/CapturedVirtualRegistry.png)]({{ site.url }}{{ site.baseurl }}/assets\images\2013-06-24-app-v-5-uac-file-virtualisation-virtualstore/CapturedVirtualRegistry.png)

When you run the application on the client, any files or registry keys written here will not be visible. It seems the UAC virtualisation system only looks in those two locations on the local system and ignores anything in the virtual environment. Now, in another scenario, ignoring what happens during sequencing - what happens when you try to write to these locations when running inside the App-V client?

Standard users will not be able to write to Program Files without resorting to the method I [published recently](http://packageology.com/2013/06/file-permissions-app-v-5/). The difference is that if the app satisfies the UAC virtualisation criteria, writes will be redirected to the **VirtualStore** folder, **outside of the virtual environment:**

[![Local Virtual Store File]({{ site.url }}{{ site.baseurl }}/assets\images\2013-06-24-app-v-5-uac-file-virtualisation-virtualstore/LocalVirtStoreFile.png)]({{ site.url }}{{ site.baseurl }}/assets\images\2013-06-24-app-v-5-uac-file-virtualisation-virtualstore/LocalVirtStoreFile.png)

I consider these bugs, resulting in the following issues:

* The sequencer may not capture all desired files and registry
* When launched, different packages could have conflicting files in the VirtualStore
* When repairing the virtual app, any files in the VirtualStore will not be removed

If you have an application that is suffering from this problem, the workaround is to put a manifest next to the executable configured to use a suitable execution level:

* **requireAdministrator** - use this if your intended users have admin rights and you want to pop up a UAC prompt.
* **asInvoker** - this will not produce a UAC prompt - users will be able to write to HKLM since App-V allows this, but if you want the app to write to protected file system areas you will have to use my [pre-launch script]({% post_url 2013-06-22-file-permissions-app-v-5 %}) method to apply permissions to the VFS.

For example, for an app named **Test.exe**, put this in a text file named **Test.exe.manifest** in the same folder:

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
    <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
        <security>
            <requestedPrivileges>
                <requestedExecutionLevel level="asInvoker" uiAccess="false"/>
            </requestedPrivileges>
        </security>
    </trustInfo>
</assembly>
{% endhighlight %}

These tests were of course done using App-V 5. I haven't tried the same scenarios on App-V 4, but it's possible the same problems exist there also!