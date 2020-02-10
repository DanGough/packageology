---
title: Using __COMPAT_LAYER when troubleshooting App-V with Regedit
slug: using-compat-layer-when-troubleshooting-app-v
excerpt: Using the __COMPAT_LAYER environment variable to prevent regedit asking for admin rights.
date: '2012-05-02 11:27:41'
redirect_from: /2012/05/__compat_layer-troubleshooting-app-v-regedit/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

Have you ever tried to launch regedit inside of the App-V bubble for some trouble-shooting only to find that you can't see registry entries that should be there in your sequence? Chances are a UAC prompt popped up and regedit ended up being launch outside of the virtual environment.

To prevent this, you can use the `__COMPAT_LAYER` environment variable. This is something which is often set inside the OSD file to stop an app from requesting admin rights. So, launch a CMD prompt in the bubble with this command:

`sfttray /exe cmd "My app 1.0"`

Or use a tool such as [ACDC](http://www.loginconsultants.com/index.php?option=com_docman&task=doc_details&gid=69&Itemid=149) to save yourself some typing. Once the prompt has appeared, type the following:

`set __COMPAT_LAYER=RunAsInvoker`<br>
`regedit`

Now regedit will be able to show you the entries you could not see before. Alternatively, if you just want to do a quick check and you know the location, you can use the reg command:

`reg query HKLM\Software\MyApp`

This works for tools other than regedit too, for example odbcad32.exe used to manage ODBC settings.

Standard users can launch regedit.exe and odbcad32.exe directly in the bubble without any issues because these applications have their execution level set to `highestAvailable`, meaning they will only try to elevate if run by a user with admin rights. So, if you are running as an admin user, from a non-elevated command prompt, you must set the variable above to launch any apps that require elevation. Alternatively just make sure you run ACDC or your CMD prompt (or whatever else you use to launch sfttray) elevated in the first place so that they can launch these apps without issue.