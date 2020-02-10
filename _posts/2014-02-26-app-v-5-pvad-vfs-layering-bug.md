---
title: App-V 5 PVAD / VFS Layering Bug
slug: app-v-5-pvad-vfs-layering-bug
excerpt: If your VFS is empty, then you won't be able to see the PVAD folder within the bubble...
date: '2014-02-26 18:01:06'
redirect_from: /2014/02/app-v-5-pvad-vfs-layering-bug/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

Whilst testing for various App-V 5 issues, I often make quick little test sequences with one or two files in them to help. When doing so I came across this problem. Now, a recap for those that may not be aware:

* When sequencing you select a **Primary Virtual Application Directory**, otherwise known as the **PVAD**.
* When inside the virtual environment, a file browser dialog, or the DIR command of a CMD prompt will display the folders created in the VFS, but the PVAD will be hidden.
* Although the PVAD may be hidden from view, it is still accessible by either typing the path into a file browser dialog, or with the CD command of a CMD prompt.

In some of the test sequences I made (which were made for the purpose of tracking down a totally different bug), I was unable to access the PVAD via the CD command. After comparing the ones that worked with the ones that didn't, I spotted the difference - all the packages where the App-V client failed to mount the PVAD properly had files installed only to the root, with no files or folders captured in the VFS! It would be rare to see this in the wild, but an application that satisfies the following criteria would be broken by this bug:

* The application tries to read/write assets (such as a config file) to/from the original install path instead of looking at the working directory, exe directory, or using the tokenised path under %ALLUSERSPROFILE%\Microsoft\AppV\Client\Integration\XXX\XXX\Root. An app might behave this way if it is either hard-coded to do so or if it reads the location from a config file.
* The application only puts files down in its root directory, with nothing going to System32, Common Files, etc.
* The application uses a non Windows Installer setup, or the C:\Windows\Installer directory is excluded if using a Windows Installer package.
* The application only creates shortcuts in the root of the Start Menu or Start Menu\Programs folders (.lnk shortcut files are ignored by the sequencer, but if a directory is created, that is picked up and placed into the VFS as an empty folder).

If an app satisfies all of those points, then it will not be able to access the original PVAD path where the app was installed to. It is also possible to trigger this bug by cleaning away 'unnecessary' VFS entries. If you're the sort that likes to ruthlessly clean their packages after capture, **make sure you leave at least one file or empty folder in the VFS!**

To demonstrate this, I found a simple app in my toolbox that satisfies some of these criteria, [Nirsoft IconsExtract](http://www.nirsoft.net/utils/iconsext.html). This is uses a NSIS installer (which therefore leaves no files behind in C:\Windows\Installer) and puts all of its files in the root install folder. By default it creates its shortcuts in a 'Nirsoft IconsExtract' subfolder of the start menu, and this empty folder is the only thing that gets captured in the VFS (since the .lnk files are ignored):

[![IconsExtract (default shortcut) - package contents]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-app-v-5-pvad-vfs-layering-bug/IconsExtract-default-shortcut-package-contents.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-app-v-5-pvad-vfs-layering-bug/IconsExtract-default-shortcut-package-contents.png)

When bringing up a debug CMD prompt in the virtual environment, I can successfully cd into my PVAD 'C:\Program Files (x86)\NirSoft\IconsExtract':

[![PVAD Visible]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-app-v-5-pvad-vfs-layering-bug/PVAD-Visible.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-app-v-5-pvad-vfs-layering-bug/PVAD-Visible.png)

However, if I change the shortcut location on the installer to put the shortcut in the root of the start menu instead, no new files or folders are captured in the VFS other than the built-in Programs folder which seems not to count:

[![IconsExtract (root shortcut) - package contents]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-app-v-5-pvad-vfs-layering-bug/IconsExtract-root-shortcut-package-contents.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-app-v-5-pvad-vfs-layering-bug/IconsExtract-root-shortcut-package-contents.png)

Then when I try the same thing in the CMD prompt, it is unable to find the PVAD:

[![PVAD Invisible]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-app-v-5-pvad-vfs-layering-bug/PVAD-Invisible.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-app-v-5-pvad-vfs-layering-bug/PVAD-Invisible.png)

If I open the first package up for upgrade and clean away the seemingly unnecessary empty folder, I end up with the same problem as the second package, a broken PVAD. This particular application works just fine even with the broken PVAD by the way, but it's likely that somewhere out there is an application affected by this, so hopefully this helps somebody someday!