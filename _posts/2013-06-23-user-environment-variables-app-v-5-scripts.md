---
title: User Environment Variables in App-V 5 Scripts
slug: user-environment-variables-in-app-v-5-scripts
date: '2013-06-23 00:23:39'
excerpt: In App-V 5, scripts run as the user inherit the environment variables from the Local System account.
redirect_from: /2013/06/user-environment-variables-app-v-5-scripts/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

This bug is now fixed.
{: .notice--success}

One problem with scripting in App-V 5 is that when you run a script as the user, the process does not inherit the user's environment variables. If you try to reference **%APPDATA%** or **%USERPROFILE%** for example, they will all point to the locations belonging to the local system account. Tim Mangan goes into more detail about this [here](http://www.tmurgent.com/TmBlog/?p=1635) and also has a [free tool](http://www.tmurgent.com/Tools/ScriptLauncher/default.aspx), which among other things sets an environment variable **%EFFECTIVEUSERNAME%** that you can use to help you reference user-related locations within your scripts. Whilst useful, it doesn't fully solve the problem. Say there are policies in place to redirect the documents folder for VDI desktops but not laptops for example; you would not be able to rely upon the user name alone to locate the folder. Using VBScript as an example, there are three common methods for retrieving known folders:

### WScript.Shell.ExpandEnvironmentStrings:

{% highlight visualbasic %}
Set objShell = CreateObject("WScript.Shell")
MsgBox objShell.ExpandEnvironmentStrings("%APPDATA%")
{% endhighlight %}

This will obviously not work since as already mentioned, the environment variables inherited by the script process are that of the local system account and you'll just get 'C:\Windows\system32\config\systemprofile\AppData\Roaming'.

### WScript.Shell.SpecialFolders:

{% highlight visualbasic %}
Set objShell = CreateObject("WScript.Shell")
MsgBox objShell.SpecialFolders("MyDocuments")
{% endhighlight %}

This method can only return a limited number of folders anyway, but for some reason it returns a blank value when run as a script in App-V 5.

### Shell.Application.Namespace:

{% highlight visualbasic %}
Const ssfLOCALAPPDATA = &H1C
Set objShellApp = CreateObject("Shell.Application")
MsgBox objShellApp.NameSpace(ssfLOCALAPPDATA).Self.Path
{% endhighlight %}

This is the most flexible method with the widest list of supported folders. It works outside of the virtual environment even when run as the local system account, but for some reason when run inside App-V as a StartVirtualEnvironment script, Shell.Application.Namespace returns a null object.  The trick I used in the script in my previous post is to read the user's local appdata folder location from the registry:

{% highlight visualbasic %}
Path = objShell.RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Local AppData")
{% endhighlight %}

I know the Shell Folders key is [deprecated](http://blogs.msdn.com/b/oldnewthing/archive/2003/11/03/55532.aspx), but it works here and it's unlikely that anybody would have redirected the local appdata folder in this case. The 'User Shell Folders' key is no good to us here either since the value for Local AppData reads '%USERPROFILE%\AppData\Local', and %USERPROFILE% is set to that of the System account when we are running a script. A possibly more reliable method is to read the environment variables directly from **HKCU\Volatile Environment** in the registry. Under here you will typically be able to read:

* %APPDATA%
* %HOMEDRIVE%
* %HOMEPATH%
* %LOCALAPPDATA%
* %LOGONSERVER%
* %USERDOMAIN%
* %USERDOMAIN_ROAMING%
* %USERNAME%
* %USERPROFILE%

Not all the user environment variables are stored here; **%TEMP%**, **%TMP%**, and any manually created variables will be stored under **HKCU\Environment**. Note that for the **%TEMP%** variable, the registry key will usually read **%USERPROFILE%\AppData\Local\Temp**. I advise that you still grab it from here then manually replace the **%USERPROFILE%** portion with the value pulled from **HKCU\Volatile Environment**, since the temp folder will not always be directly under the local appdata folder, particularly on a terminal server. Another option that should work is to loop through all of these registry keys in turn and set the environment variables as you normally would, then use them as normal!