---
title: A Couple Of App-V 4.6 Environment Variable Bugs
slug: a-couple-of-app-v-4-6-environment-variable-bugs
excerpt: A few bugs in how the App-V 4.6 client handles environment variables.
date: '2012-09-02 08:15:06'
redirect_from: /2012/09/hat-trick-app-v-4-6-sp1-environment-variable-bugs/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I've discovered the following bugs in how App-V 4.6 SP1 (and the SP2 beta) client handles environment variables. Try creating a simple sequence that consists of the following:

* A shortcut on the desktop to **C:\Windows\System32\cmd.exe**
* An empty folder **C:\Program Files\Test**
* Append **C:\Program Files\Test** and **C:\PROGRA~1\Test** to the end of the system **PATH** environment variable

Then install and run this on your App-V client machine to bring up the command prompt.  Type the `set` command, then examine the contents of the `PATH` variable and you should notice the following:

* Short paths are parsed by the sequencer to variables that the App-V client does not understand:
    * At the very end of your PATH variable you will see `C:\Program Files\Test;%SFT_PROGRAM_FILES_x64~%\Test;`
    * The OSD file actually contains `%SFT_PROGRAM_FILES_X64%\Test;%SFT_PROGRAM_FILES_X64~%\Test;`
    * The App-V client is configured to parse the short path name into a variable with a **~** at the end - look at the Parse Items tab of the sequencer settings to verify
    * The App-V client can succesfully expand `%SFT_PROGRAM_FILES_X64%`, but not `%SFT_PROGRAM_FILES_X64~%`
    * This can result in broken environment variables, particularly for Java based apps, e.g. Sybase Open Client
    * If you were to put the value `C:\PROGRA~1` into a registry key, it would be stored as `%SFT_PROGRAM_FILES_X64~%` and expanded correctly - it's just environment variables that do not work
    * The only solution is to remove the ~ from the variable names which will use the long path names instead. However, certain apps that do not get on with spaces might not like this so you may have to install to a 8.3 compatible folder instead, e.g. Q:\MYAPP or C:\APPS.

* As well as placing our additional variables at the end of the path statement, the App-V client has placed the actual path on disk at the **beginning** of the path statement:
    * Your PATH variable will look like this when you check it: `Q:\TEST\VFS\SFT_PROGRAM_FILES_X64\Test;%PATH%;C:\Program Files\Test;%SFT_PROGRAM_FILES_x64~%\Test;`
    * In rare scenarios (it has happened to me once) this alteration of the desired path order can break an application.  If for example you have more than one version of the Oracle client installed, this could change the search order that an application will find various Oracle dlls and load a different version than intended.
    * The fix is to pre-empt it by putting this decoded path in the environment variable in the OSD file.  For example instead of putting `%PATH%;%SFT_PROGRAM_FILES_x64~%\Test;` put `%PATH%;Q:\TEST\VFS\SFT_PROGRAM_FILES_X64\Test;`. The path will no longer be decoded and placed at the beginning since we've done the job already.