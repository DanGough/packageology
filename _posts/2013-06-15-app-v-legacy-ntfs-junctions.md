---
title: App-V and Legacy NTFS Junctions
slug: app-v-and-legacy-ntfs-junctions
excerpt: Apps that write to the old XP-style user profile locations are not redirected properly in App-V.
date: '2013-06-15 17:18:13'
redirect_from: /2013/06/app-v-legacy-ntfs-junctions/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I was having problems recently sequencing an application named **SolarWinds Toolset**; it appeared to be ignoring the data stored under **C:\ProgramData** captured during sequencing and instead reading/writing files to this location outside of the virtual environment. A bit of Procmon analysis showed that the application was trying to read from **C:\ProgramData\Application Data**.

On Windows Vista and 7, this is not an actual folder but an **NTFS junction**; a reparse point so that (badly written) legacy apps designed for Windows XP can be redirected to write to the correct location. NTFS junctions are similar to file/folder shortcuts that you may see on your desktop, but they are put in place all over Windows 7 to aid application compatibility after Microsoft changed the folder structure since Vista. You can easily view just how many of these there are on your system by running the following command:

`dir /s /al c:\`

Applications are supposed to query Windows APIs to determine exactly where the per-user and per-machine app data locations are. But often developers use alternate methods, such as **%ALLUSERSPROFILE%\Application Data** and **%USERPROFILE%\Application Data**. On XP these folders would equate to **C:\Documents and Settings\All Users\Application Data** and **C:\Documents and Settings\USERNAME\Application Data**.

After changing the folder structure since Vista, NTFS junctions are used to redirect attempt to write to these locations to the correct place. For example, say an application tries to write to: **%ALLUSERSPROFILE%\Application Data** on Windows 7, which actually would prefer you to store per-machine appdata to **C:\ProgramData**. To achieve this, **%ALLUSERSPROFILE%** is set to **C:\ProgramData**, and in there is an NTFS junction shortcut **Application Data** under there, which also points to **C:\ProgramData**. All of this redirection goes on transparently behind the scenes and it all works wonderfully. Except if you try to run this application inside App-V!

You can try the following test for yourself on either App-V 4 or 5. Here is a simple batch file that tries to read and write to these junction points:

{% highlight batchfile%}
@echo off

echo Program data:
type "%ALLUSERSPROFILE%\Application Data\Test\config.txt"

echo User data:
type "%USERPROFILE%\Application Data\Test\config.txt"

echo.
echo Updating data files...
echo.

IF NOT EXIST "%ALLUSERSPROFILE%\Application Data\Test\config.txt" (
md "%ALLUSERSPROFILE%\Application Data\Test"
echo This file stores program data >"%ALLUSERSPROFILE%\Application Data\Test\config.txt" )

IF NOT EXIST "%USERPROFILE%\Application Data\Test\config.txt" (
md "%USERPROFILE%\Application Data\Test"
echo This file stores user data >"%USERPROFILE%\Application Data\Test\config.txt" )

echo Program data:
type "%ALLUSERSPROFILE%\Application Data\Test\config.txt"

echo User data:
type "%USERPROFILE%\Application Data\Test\config.txt"

pause
{% endhighlight %}

This simply does the following:

1. Tries to read 2 config files using the **%ALLUSERSPROFILE%\Application Data** and **%USERPROFILE%\Application Data** locations.
2. If they do not exist they are created.
3. Then it tries to read the config files again.

This mimics simple application behaviour where it will try to read its config files and create default ones if none exist. Running this locally, we see this on the first run as expected:

[![First run]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-15-app-v-legacy-ntfs-junctions/firstrun.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-15-app-v-legacy-ntfs-junctions/firstrun.png)

Then on each successive run the script can find the files both times:

[![Second run]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-15-app-v-legacy-ntfs-junctions/secondrun.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-15-app-v-legacy-ntfs-junctions/secondrun.png)

Now, create an App-V package containing this batch file along with a shortcut to it, and run it at least once during capture. On App-V 5, you will also have to craft your shortcut to run `cmd.exe /c <path to batch file>`, since shortcuts directly to batch files run outside of the virtual environment by default (see [here]({% post_url 2013-06-03-launching-reg-bat-cmd-vbs-files-app-v-5 %}) for a previous post detailing this).

Because of the redirection via those NTFS junctions, the files would end up captured in the package under **%PROGRAMDATA%\Test** and **%APPDATA%\Test**. However, when you run the resulting published virtual shortcut, it won't be able to find the files and will create them *outside of the virtual environment*. It appears that the VFS redirection only intercepts calls directly to %PROGRAMDATA% and %APPDATA% locations, but ignores any attempts to access those legacy paths.

The potential undesired impacts of this are:

* If you configure an application during sequencing, it may not be able to find the configuration on client launch. This could either cause the application to crash, or for it to recreate default settings files.
* If you have two different version of the same product, they could both end up writing their config outside of the virtual environment and therefore conflict with each other.
* For multi-user systems or terminal servers, one user can change the application configuration under %PROGRAMDATA% which would also affect other users.

I have found a workaround for this problem. On your sequencer, *before monitoring*, delete any of the affected NTFS junctions (you will need to enable the viewing of hidden and system files in Explorer) and recreate them as real folders. Then in the example above, the files are stored under real 'Application Data' folders instead of being redirected, and will be readable from first launch within the virtual environment.