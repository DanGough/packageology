---
title: Issue With App-V 5 and Java Mission Control
slug: issue-app-v-5-java-mission-control
excerpt: Eclipse-based apps have issues with virtualised user profile folders...
date: '2014-08-05 20:24:10'
redirect_from: /2014/08/issue-app-v-5-java-mission-control/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Java
---

I recently encountered a strange error when trying to sequence the Java JDK. It has a shortcut named Mission Control, which produced the following error message when trying to launch on the client:

[![JDK Mission Control Error]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-05-issue-app-v-5-java-mission-control/JDK-Mission-Control-Error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-05-issue-app-v-5-java-mission-control/JDK-Mission-Control-Error.png)

> Invalid Configuration Location - The configuration area at 'C:\Users\testadmin\.eclipse\810663534\configuration' is not writable. Please choose a writeable location using the '-configuration' command line option.

This folder is present in the VFS and should be writeable. I tried various tricks such as enabling full VFS write permissions and setting the PVAD to this location, but to no avail. I first thought it might be something to do with the folder name starting with a dot - Windows doesn't really like this, for instance it won't let you create such a folder through Explorer.

Busting out Procmon however showed that the application is trying to create and delete a .dll file in this folder to see if it's writable; and this file extension is read-only in the VFS (see [here](http://www.virtualvibes.co.uk/cow-and-its-exclusions-in-app-v-5-0/ "CoW and its Exclusions in App-V 5.0") for more info on which file types are blocked). Here is the Procmon trace:

[![JDK Mission Control - without local folder]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-05-issue-app-v-5-java-mission-control/JDK-Mission-Control-without-local-folder.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-05-issue-app-v-5-java-mission-control/JDK-Mission-Control-without-local-folder.png)

Since this folder is in the VFS, I would not expect to see the first few PATH NOT FOUND entries, so perhaps there is something else going on here that's forcing it to look at the real file system instead of the VFS. The app works however if I create the folder on the local file system:

[![JDK Mission Control - with local folder]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-05-issue-app-v-5-java-mission-control/JDK-Mission-Control-with-local-folder.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-05-issue-app-v-5-java-mission-control/JDK-Mission-Control-with-local-folder.png)

So, the simplest solution to this is **to not launch the Java Mission Control shortcut during sequencing!** This way the folder never gets created or captured, and it will create the folder on the local file system automatically when launched on the client.

This issue is not just limited to the Java JDK. I have seen a [forum post](http://social.technet.microsoft.com/Forums/en-US/52ef02fc-91f2-4466-89a1-86c142b5da6a/eclipse-indigo-37012?forum=mdopappv "Eclipse Indigo 3.7.0.12") where the same issue affects Eclipse, and I also happened to run into the exact same issue on two other applications in the same week. The error message is identical, and they all appear to have some code based on a modified version of Eclipse.

