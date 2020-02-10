---
title: Supressing UAC Prompts In App-V 5 With __COMPAT_LAYER
slug: supressing-uac-prompts-in-appv5-with-compat-layer
excerpt: How to use the __COMPAT_LAYER environment variable to stop apps requesting admin rights in App-V 5.
date: '2014-08-06 15:40:00'
redirect_from: /2014/08/supressing-uac-prompts-in-appv5-with-compat-layer/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

Back in App-V 4.x and earlier, the client could not quite cope with any apps that required admin rights. Since Vista, applications should have an embedded or external manifest file that defines the requested execution level, either:

* **asInvoker** - Run with limited user rights unless specifically elevated or called from an already elevated process
* **highestAvailable** - Request admin rights if the user is an admin, otherwise run without them
* **requireAdministrator** - Request admin rights; application will not launch unless they are granted

If either of the last two were specified, the app would fail to launch as the sfttray.exe launch process was not compatible with UAC. The [common fix](http://blogs.technet.com/b/virtualworld/archive/2010/04/13/the-requested-operation-requires-elevation-2c-000002e4.aspx) was to add an environment variable to the package `__COMPAT_LAYER=RunAsInvoker` (note the **double underscores** at the beginning!). This would then instruct Windows to override the requested execution level with '**asInvoker**' for all applications in that virtual environment. By the way, there are a few ways of checking the value used by an executable:

* Use [Sysinternals SigCheck](http://technet.microsoft.com/en-gb/sysinternals/bb897441.aspx) tool with the -m switch to dump the internal manifest
* Use [Sysinternals Process Explorer](http://technet.microsoft.com/en-us/sysinternals/bb896653.aspx) to view the strings contained within any running process
* Use a resource editor such as [Resource Hacker](http://www.angusj.com/resourcehacker) to view the manifest directly

External manifest files are also possible, although Windows is configured by default so that the internal ones take precedence. This issue of not being able to launch these applications no longer exists in App-V 5 since it has been written from the ground up to work with UAC. If a sequenced application requires admin rights, it will also request admin rights when deployed on the client.

I was sequencing an application in App-V 5 that specified the 'requireAdministrator' setting - it only needed this so that it was able to write to a certain area of the HKLM registry for licensing purposes. Since the App-V sandbox allows full write access to the registry (and also optionally the file system as of 5.0 SP2 Hotfix 4), admin rights were not actually needed, so I was looking for the best way to suppress this UAC prompt to allow standard users to launch the application. Here are the options:

* **AppSense / Avecto (and others)** - There are dedicated privilege escalation suites out there to dynamically grant admin rights to various processes without the user requiring a full admin account. The client I was working with did not have any of these available so this was not an option.
* **Replace the internal manifest** - I know this is possible using certain Microsoft tools mt.exe and mage.exe, but have never gone so far to attempt it. I have recently discovered that my trusty old Resource Hacker tool can be used to edit the internal manifest directly! This method could cause issues if the binaries are signed however as it would invalidate the digital signature.
* **Add an external manifest** - This is not the preferred solution as you also need to reconfigure Windows to prefer the external manifest, which poses additional risks.
* **Add a local registry shim** - When you view the properties of an exe you can enable certain shims such as 'Windows XP SP3' or 'Run As Administrator'. These are stored in the registry and use the exact same naming format the __COMPAT_LAYER variable - so although the property form has no option for it, you can specify RunAsInvoker here too. The only caveat is that these registry keys need to be set outside the virtual environment, perhaps by a script.
* **Application Compatibility Toolkit** - Rather than manage shims by directly manipulating registry, ACT can used to select the exe(s) and shim(s), and export to a database file which can be reimported on each client.
* **Add the __COMPAT_LAYER=RunAsInvoker environment variable to the virtual application** - Our old friend; however, I could not get this to work. At first, anyway!

So I attempted to add this environment variable to my package to suppress the UAC prompt, by running the following command from an elevated command prompt during monitoring:

`setx __COMPAT_LAYER RunAsInvoker /m`

But it did not work. If I launched a command prompt in the bubble though, I could see the environment variable was set, and if I launched the exe from there, it obeyed the setting and launched without UAC! Using Process Monitor, I could see that when the application was launched from the start menu, the process was created without the environment variable; yet when I viewed the same process in Process Explorer, the environment variable was there. I can only assume that the App-V client attaches the virtual environment variables to the process just **after** it launches, which is too late for the __COMPAT_LAYER setting to work its magic

My solution was to alter the shortcut to run cmd.exe as a middleman; this process will be started, the environment variables added, then it will start my application which will inherit the variable from the parent process:

[![shortcut]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-supressing-uac-prompts-in-appv5-with-compat-layer/shortcut.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-supressing-uac-prompts-in-appv5-with-compat-layer/shortcut.png)

You will also need to manually set the icon and ensure the 'Start in' field is set to the application directory. This did the trick! No more UAC prompts and standard users can now launch the application.

This is a bit of a hacky workaround though, and in environments where cmd.exe is blocked for standard users, you will have to resort to an alternative man in the middle such as VBScript or PowerShell. Tim Mangan's [LaunchIt](http://www.tmurgent.com/AppVirt/DownloadLaunchIt.aspx "LaunchIt") tool should in theory be able to do the trick also, or any stub exe that is capable of passing on parameters to launch another application. 

### UPDATE:
Another way to do this is instead of setting the environment variable when monitoring, just set it as part of the cmd shortcut, e.g:

`cmd.exe /c SET __COMPAT_LAYER=RunAsInvoker & START "" "C:\Program Files\MyApp.exe"`