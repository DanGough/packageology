---
title: Automate Your App-V Client / Sequencer Test Builds With Boxstarter!
slug: automate-your-app-v-client-sequencer-test-builds-with-boxstarter
excerpt: How to automate image builds using the power of Boxstarter and Chocolatey.
date: '2015-07-03 22:34:47'
redirect_from: /2015/07/automate-app-v-client-sequencer-test-builds-boxstarter/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Automation
  - Boxstarter
  - Chocolatey
---

I recently decided to rebuild my App-V lab from scratch. I also work on various client sites and often have to whip up an App-V sequencer and test client from scratch, and in the past this has always been a manual process. So this time I decided to automate it! There's a lot of buzz around automation frameworks at the moment - you may have heard of [Chocolatey](https://chocolatey.org/), [Boxstarter](http://boxstarter.org/), [Chef](https://www.chef.io/chef/), [Vagrant](https://www.vagrantup.com/), [Puppet](https://puppetlabs.com/), [DSC](https://technet.microsoft.com/en-gb/library/dn249912.aspx), etc.

I started writing my own script in PowerShell before realising that one of the features I wanted to implement - applying Windows Updates and rebooting with autologon until the process had completed - was already implemented in Boxstarter. Boxstarter is written in Powershell so a lot of my existing code could be ported over too, with some of it replaced with Boxstarter's own built-in functions. This script will be constantly evolving but here is what it does at the moment:

* Prompt the user to ask if the machine is a client or sequencer if it cannot find out from looking at HKLM\SOFTWARE\Microsoft\AppV
* Installs pre-reqs for App-V via Chocolatey:
    * .Net 3.5 & 4.5.2
    * Powershell 4.0
* Enables Microsoft Update
* Applies all Windows Updates except those that need the user to accept a license (e.g. language packs, Skype, Silverlight)
* Disable automatic updates
* Sets execution policy to Unrestricted
* Disables Security Centre and hides task tray icon
* Disable System Restore and deletes any existing restore points
* Optimises the OS for running on an SSD
* Disables computer password change (to prevent falling off the domain when reverting)
* Configures power options to disable screen off and standby timers
* Enables remote desktop
* Sets Explorer options to show file extensions and hidden files
* Sets Windows 8 to boot to desktop, show all apps view by default, etc
* Pins Command Prompt, Powershell, Regedit, Notepad, and Snipping Tool to the taskbar
* Disables Internet Explorer Enhanced Security Configuration (for server OS)
* Disables IE first run prompts and sets home page to blank
* For a Client build:
    * Install App-V Manage, ACE, InstEd, 7-Zip and Sysinternals Suite via Chocolately
    * Pin App-V Manage and ACE to the task bar
* For a Sequencer build:
    * Disable UAC
    * Disable Windows Defender
    * Disable Windows Search
    * Disable over a dozen scheduled tasks
    * Create empty ODBC Data Sources registry keys
* Run ngen.exe to optimise .NET assemblies
* Perform disk cleanup via cleanmgr.exe
* Wipe %TEMP% and C:\Windows\Temp
* Run sdelete.exe to zero unused bytes on disk (allows the VHD to be compacted more efficiently when complete)

Note that this does not actually install any App-V components, since these are not available via any public download locations and I am not authorised to distribute them. But who knows, with Microsoft's adoption of OneGet in Powershell v5, we may be able to install those components that way in the future! Anyhow, it's a good idea to take a snapshot of the clean base configuration before any App-V components are installed, plus not all environments will be running the latest version. There are a few known issues at present:

* Sometimes checking for Windows Updates can return an error on the first attempt - hence running the command twice in a try / catch block as a workaround.
* Disabling Defender on Windows 8 is difficult as the service is locked down, so for now it drives the GUI... which does highlight a flaw in Windows that you can disable the built in antivirus without admin rights! The timings of this may need fine tuning as I have seen it stall once or twice. Perhaps I will just figure out how to do it properly instead.
* UAC still seems to be left enabled when configuring a sequencer build on Windows 7, yet it works on Windows 8.

The great thing about this is that it can be run from a simple URL - which I have plugged into an easily memorable URL shortener. So to run this script on a machine, all you have to do is hit Win + R to get the run box and enter:

`http://tiny.cc/appvboxstarter`

Easy, eh? Of course you may want to customise this for your own needs - just download the [script]({{ site.url }}{{ site.baseurl }}/downloads/appvsetup.txt) as a text file and head over to [Boxstarter.org](http://boxstarter.org/Learn/WebLauncher) to learn how to run your own version from your own URL. You can even run it from a network share or USB key if internet access is an issue on the test VMs. Please comment below if you find any issues or have any other suggestions. I hope you find this useful and it saves you some time, or if not perhaps it will expose you to some cool tools that you might not have heard of before. I used Chocolatey for example to reinstall a bunch of tools on one of my machines after reinstalling the OS!