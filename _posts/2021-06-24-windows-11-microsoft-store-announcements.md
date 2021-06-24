---
title: 'Windows 11 Microsoft Store Announcements'
slug: windows-11-microsoft-store-announcements
date: '2021-06-24 00:00:00'
layout: single
classes: wide
categories:
  - Windows
tags:
  - Windows 11
---

After a series of leaks, Microsoft have officially unveiled Windows 11 earlier today. While most of the reporting has been focussed on the UI changes, there was a huge reveal regarding the Microsoft Store that will prove to be very interesting for those involved with application deployment.

<!--More-->

The Microsoft Store will now supports any kind of packaging technology, including **MSI** and **EXE** based installers. If your app has a silent install command, it can be submitted as shown in the video below:

<video src="https://wus-streaming-video-rt-microsoft-com.akamaized.net/9f8013e5-5255-4d13-94c8-65aea12d86ff/4f2f7345-9a63-46cb-b9c6-e029e6cc_2250.mp4" width="640" height="400" controls preload></video><br>
In addition, web apps can be packaged up as **PWAs** and submitted to the store, and even **Android apps** from the Amazon App Store that run on the new Subsystem for Android.

From watching the video above, there appear to be a few gotchas already:

- Submitted apps must be downloadable from a unique URL per version. There are a few apps that rely on the same URL to always grab the latest version, that would not be suitable here.
- There is no way to input uninstall commands, so it appears that uninstalls are not currently supported.
- There is no detection method, so the engine probably assumes successful installation based on the return code of the installer.
- Due to this it won't be able to detect exactly which version you have installed. So if the app was deployed with an auto-updater, the Store may fail when it tries to deploy a new version that was already installed by other means.
- There is no way to gracefully close down any running versions of the app during upgrade, as offered by Microsoft Endpoint Manager. You will just be relying on the installer which might either kill the process, need a reboot to finish, or outright fail if an old version happens to be running during upgrade.
- Most vendors will probably just upload their apps as-is, without the typical enterprise tweaks such as removing desktop shortcuts, disabling telemetry and disabling built-in auto-updaters.
- It's most likely that these apps will install under the user context, so the user will need admin rights to install most apps, unless they are per-user installers.

Other areas of concern that we'll just have to wait to find out more about:

- Will it be possible to integrate these apps with Store for Business and sync them with Intune? If so then that could cause a problem if the Store contains a mixture of per-user and per-machine apps and Intune won't know under which context to run the installer.
- Could this eventually integrate with Winget? Application vendors would have to use two separate processes for submitting their apps to both systems.
- Unlike the relatively safe world of modern containerised MSIX packages, these installers can execute arbitrary code, so there exists the possibility of malware to sneak in. Anyone could submit a tainted version of a popular application, so I hope Microsoft are on the ball here.

Another thing that has tended to slip under most people's radar is that this new Store and these capabilities will also make it to Windows 10! Great news for those with older devices like me that won't even support Windows 11 (run [this](https://aka.ms/GetPCHealthCheckApp) to find out if your device is supported)!

Overall though, this is very good news for Windows and home users in general. The main reason the Store has such as lack of quality content was that developers were forced to repackage as AppX or MSIX which has proven to be a struggle for many. If the vendors all jump on board it could become the go-to place for many to search for and install their applications. However there doesn't seem to be much thought put towards the needs of the enterprise so far, so it may not have much effect on enterprise software deployment for a while yet.

Learn more at: [https://aka.ms/newstore](https://aka.ms/newstore)