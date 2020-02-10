---
title: Finding Hard-Coded Paths In App-V Packages
slug: finding-hard-coded-paths-app-v-packages
excerpt: Using the findstr command to look for hard-coded paths in config files within your package.
date: '2012-02-14 20:35:05'
redirect_from: /2012/02/finding-hard-coded-paths-app-v-packages/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

The App-V client sequencer automatically substitute variables for common hard-coded paths in the registry, shortcuts and environment variables - but not when it comes to values hard coded in files, such as .ini or .xml config files. This can cause issues in the following scenarios if these files contain hard-coded paths to files or folders:

* You sequence an application on 32-bit Windows and install it under **C:\Program Files** (or C:\PROGRA~1). When running on 64-bit Windows, it's effective path will be **C:\Program Files (x86)** (or C:\PROGRA~2), and all of a sudden various hard-coded paths are pointing to the wrong location. This applies going from 64-bit to 32-bit also.
* You are DSC-linking to an application that contains config files with hard coded short paths, e.g. **C:\PROGRA~1\MICROS~1**. These short paths may not work when the child app is brought into the virtual environment of the parent (see [here](http://blog.stealthpuppy.com/virtualisation/dynamic-suite-composition-and-short-names) for more information on this).
* You decide to change your mount point letter say from Q: to V: and want to re-use the same sequences.

After I have sequenced an application I like to do a quick check for these hard-coded paths, for which I use a small batch file. Copy the following text (all one one line) to a batch file (e.g. findstr.bat) and place it on the desktop of your sequencer machine:

`findstr.exe /s /i /c:"C:\Program Files\\" /d:%1 *.* >%temp%\findstr.txt && start notepad %temp%\findstr.txt`

You can change the following:

* /c:"C:\Program Files\\" - This is the string you are searching for. One peculiarity is that if it ends in a slash you must use a double backslash as shown.
* *.* - This will search ALL file extensions; you may want to restrict this to a few and use multiple commands to search for each.

Then just simply drag and drop your entire package root folder (e.g. **Q:\MYAPP.001**) onto the batch file; the folder path will be piped in as %1 and notepad will appear showing you the results. Save a copy in case you need to refer to it during later troubleshooting!