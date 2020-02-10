---
title: Are Your App-V Components Up To Date?
slug: are-your-app-v-components-up-to-date
excerpt: Where to obtain the latest hotfixes for App-V.
date: '2011-11-30 00:00:00'
redirect_from: /2011/11/are-your-app-v-components-up-to-date/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Hotfix
---

**This information is now out of date.** Please refer to these Microsoft links which are kept (mostly) up to date:
<br><br>
[Current list of App-V 4.5 and 4.6 file versions](http://support.microsoft.com/kb/2585266)
<br>
[Current list of App-V 5.0 file versions](http://support.microsoft.com/kb/2900621)
{: .notice--danger}

Whilst compiling my guide to building an App-V lab, I started gathering up the latest hotfixes currently available. These fix some pretty critical issues yet there are many out there who aren't aware of their existence, so I thought this warranted a post of it's own. The patches are cumulative, but not each patch release covers all of the components. In the end there are three separate downloads you need to apply an dI suggest you use them all.

## Server

* [Hotfix 2 for App-V v4.5 SP2 (KB2507096)](http://support.microsoft.com/kb/2507096)
    * [Download](http://hotfixv4.microsoft.com/Microsoft%20Application%20Virtualization%204.5/sp2/2507096/4.5.3.20031/free/429878_intl_i386_zip.exe)
        * AppV45SP2-MGMT-KB2507096-x86.msp

## Sequencer

This one is a complete installer rather than an MSP patch. No need to install the RTM version beforehand. In fact the updated version will prompt you to uninstall the old one first!

* [Hotfix 3 for App-V v4.6 SP1 (KB2571168)](http://support.microsoft.com/kb/2571168")
    * [Download](http://hotfixv4.microsoft.com/Microsoft%20Application%20Virtualization%204.6/sp1/2571168/4.6.1.30091/free/435467_intl_i386_zip.exe)
        * AppV4.6SP1-SEQ-KB2571168-x86.exe
        * AppV4.6SP1-SEQ-KB2571168-x64.exe

## Client

* [Hotfix6 for App-V v4.6 SP1 (KB2693779)](http://support.microsoft.com/kb/2693779 "Hotfix 6 for App-V v4.6 SP1 (KB2693779)")
    * [Download](http://hotfixv4.microsoft.com/Microsoft%20Application%20Virtualization%204.6/sp1/2693779/4.6.1.30121/free/447045_intl_i386_zip.exe)
        * AppV4.6SP1-RDS-KB2693779-x86.msp
        * AppV4.6SP1-RDS-KB2693779-x64.msp
        * AppV4.6SP1-WD-KB2693779-x86.msp
        * AppV4.6SP1-WD-KB2693779-x64.msp

Aaron Parker also maintains a nifty table listing the latest versions available [here](http://blog.stealthpuppy.com/virtualisation/app-v-faq-5-what-are-the-current-versions-of-app-v).