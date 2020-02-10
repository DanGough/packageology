---
title: Creating a Shortcut to an Exe in Another Package in a Connection Group
slug: creating-shortcut-to-exe-in-another-package-in-connection-group
excerpt: There are a few use cases where you might want to create a connection group that involves calling an executable from one package from a shortcut belonging to another package.
date: '2015-07-23 21:57:52'
redirect_from: /2015/07/creating-shortcut-exe-package-connection-group/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

There are a few use cases where you might want to create a connection group that involves calling an executable from one package from a shortcut belonging to another package. For example you could have an application with a bunch of shortcuts that call the same exe with different parameters to connect to different servers. Back in App-V 4.x, you might have employed one of the following methods:

* Use one package with multiple custom OSD files and deploy each one to its own AD group.
    * We have UserConfig.xml files in App-V 5, but they do not offer the same level of flexibility. Each XML file can contain its own set of custom shortcuts; but the major drawback is that if a user belongs to more than one of the groups, the client does not know which UserConfig to apply so it applies none, instead using whatever the default settings are.
* Create a bunch of shortcut packages that DSC link to the main application.
    * We could in theory do this with connection groups, but as this article demonstrates, the resulting shortcut does not work without resorting to workarounds.

In this example below, I will be using a very simple application, the terminal emulator [PuTTY](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html). I have created a sequence with putty.exe installed to C:\Program Files (x86)\PuTTY; I also have a custom shortcut that launches PuTTY with a parameter to connect to a server, which I want placed in a standalone package. The custom shortcut path is:

`"C:\Program Files (x86)\PuTTY\putty.exe" telnet://nyancat.dakko.us`

When this works this is what we should expect to see!

[![Nyancat]({{ site.url }}{{ site.baseurl }}/assets/images/2015-07-23-creating-shortcut-exe-package-connection-group/Nyancat.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2015-07-23-creating-shortcut-exe-package-connection-group/Nyancat.png)

This shortcut was sequenced by simply selecting 'Add-On or Plug-In', expanding the PuTTY package, then creating the shortcut whilst monitoring. After publishing the package to the client, the shortcut has changed to show one of the following paths, depending on if it was published to the user or the machine: 

`%LOCALAPPDATA%\Microsoft\AppV\Client\Integration\<PackageID>\Root\VFS\ProgramFilesX86\PuTTY\PuTTY.exe telnet://nyancat.dakko.us`

`%ALLUSERSPROFILE%\Microsoft\AppV\Client\Integration\<PackageID>\Root\VFS\ProgramFilesX86\PuTTY\PuTTY.exe telnet://nyancat.dakko.us`

The PackageID is from the shortcut package, which does not contain the exe, so the shortcuts are now pointing to a non-existent file. Putting both packages in a Connection Group does not update the shortcut either. When you launch it you will see the error below:

[![Missing Shortcut]({{ site.url }}{{ site.baseurl }}/assets/images/2015-07-23-creating-shortcut-exe-package-connection-group/Missing-Shortcut.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2015-07-23-creating-shortcut-exe-package-connection-group/Missing-Shortcut.png)

So how can we get this to work in a Connection Group? To stop the App-V client from changing the path, we need to point the shortcut to an exe that already exists at publish time. There are two working solutions that I know of:

### 1. Recreate the App-V client paths on the sequencer and point the shortcut there instead.

There are three potential paths we could select, each with a unique drawback:

* `%LOCALAPPDATA%\Microsoft\AppV\Client\Integration\<PackageID>` This path is only valid if the app is published to the user.
* `%ALLUSERSPROFILE%\Microsoft\AppV\Client\Integration\<PackageID>` This path is only valid if the app is published globally.
* `%PROGRAMDATA%\App-V\<PackageID>\<VersionID>` This path works for either publishing method, but the path is now dependent on the VersionID, so it's more likely to change in future. Unless you are 100% sure that the app is only to be published either per-user or per-machine, this is the way to go.

To create the package, before you start sequencing, recreate the exact same path that you see on the client, on the sequencer. Then whilst monitoring, create the shortcut pointing to this path, e.g:

`C:\ProgramData\App-V\<PackageID>\<VersionID>\Root\VFS\ProgramFilesX86\PuTTY\putty.exe telnet://nyancat.dakko.us`

This method has some advantages and disadvantages:

* If your shortcut package is a pure shortcut with no other files or registry entries required (as in this example), you don't even need a Connection Group! The shortcut will launch PuTTY in its own virtual environment and with the necessary parameter to connect to the server.
* The package containing the target exe must be published before the shortcut package, otherwise the shortcut will be created with a blank target path. If they are published in the wrong order, this can be remedied by repairing the shortcut package.
* The shortcut package is dependent on the PackageID and perhaps the VersionID of the target package. If you had a lot of shortcuts, that's a lot of work to update them if the target package is resequenced with a new version.

### 2. Use CMD.exe or a script to launch the application directly from Program Files

If you point your shortcut to some other middleman, such as cmd.exe, once it is up and running in the virtual environment it can see the original install path within the virtual file system. You could use a script to do this, but the simplest method is to just call cmd.exe directly like this:

`C:\Windows\System32\cmd.exe /c START "" "C:\Program Files (x86)\PuTTY\putty.exe" telnet://nyancat.dakko.us`

The double quotes are necessary after the START command to supply a blank window title if there are spaces in the paths that follow, this is just a peculiarity of cmd.exe. You should also change the icon of the shortcut to match the original exe, and you may also have to set the working directory to the application folder if the application requires it. Crafting the shortcut in this way means it always needs to be put in a connection group. But there are no dependencies on the package GUIDs or installation order, making this the recommended method!