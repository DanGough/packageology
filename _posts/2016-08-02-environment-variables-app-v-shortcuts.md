---
title: Environment Variables in App-V Shortcuts
slug: environment-variables-in-app-v-shortcuts
excerpt: If your app creates an environment variable and uses it as part of the shortcut path or parameters, here is the fix to get that working.
date: '2016-08-02 15:13:28'
redirect_from: /2016/08/environment-variables-app-v-shortcuts/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I fixed an application recently (KeySIGN add-in for AutoCAD) that added three new environment variables and used these as parameters in the shortcut it created. I do not have the exact detail to hand but the form was something like this:

`"C:\Program Files\MyApp\MyApp.exe" "%VAR1%\MyApp.ini" "%VAR2%\Another.ini" "%VAR3%"`

When launching on the client, it complained that it could not find a file, the path of which was specified by one of these variables. The explanation is simple; the sequencer captured the shortcut exactly as it was put down, but when Windows came to launch it on the client, it had no knowledge of these variables, as they only exist within the confines of the virtual environment. There are two main workarounds available for this:

* Modify your shortcut during monitoring to replace the environment variable with its actual contents. In this instance this was not an option, as I had three variables each with long paths and there was not enough room to enter the entire command!
* Modify your shortcut to run cmd.exe as a middleman - when cmd.exe starts it will be able to see the new environment variables and use them to start the application. Here's an example command:

`C:\Windows\System32\cmd.exe /c START "" "C:\Program Files\MyApp\MyApp.exe" "%VAR1%\MyApp.ini" "%VAR2%\Another.ini" "%VAR3%"`

If you're wondering what the `""` is for, if `START` sees spaces in the following command it thinks it is receiving multiple parameters, the first of which being the window title; so we give it an empty one to satisfy it!