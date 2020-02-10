---
title: New App-V Hotfixes Available
slug: new-app-v-hotfixes-available
excerpt: Details of the March 2018 Servicing Release for MDOP.
date: '2018-03-10 20:46:39'
redirect_from: /2018/03/app-v-hotfixes/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Hotfix
---

Microsoft have released patches for the App-V client built into Windows 10 build 1703 and 1709, as well as one for App-V 5.1 (Hotfix 11):

* App-V 5.1: [https://support.microsoft.com/en-gb/help/4074878/march-2018-servicing-release-for-microsoft-desktop-optimization-pack](https://support.microsoft.com/en-gb/help/4074878/march-2018-servicing-release-for-microsoft-desktop-optimization-pack)
* Windows 10 1703: [https://support.microsoft.com/en-gb/help/4077528/windows-10-update-kb4077528](https://support.microsoft.com/en-gb/help/4077528/windows-10-update-kb4077528)
* Windows 10 1709: [https://support.microsoft.com/en-gb/help/4074588/windows-10-update-kb4074588](https://support.microsoft.com/en-gb/help/4074588/windows-10-update-kb4074588)

The major headline for the Windows 10 patches is reverting the registry system from the new container-based system (CREG) back to the old virtual registry system (VREG). This should resolve a range of reported issues that crept in with 1703. All 3 patches also contain a fix to prevent registry corruption under HKCU when using connection groups, so it's recommended to update as soon as possible!