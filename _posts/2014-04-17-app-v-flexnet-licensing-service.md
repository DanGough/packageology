---
title: App-V and the Flexnet Licensing Service
slug: app-v-flexnet-licensing-service
date: '2014-04-17 17:10:19'
excerpt: If an application uses the Flexnet Licensing Service, it can be at first appear to work in App-V, however you can run into problems.
redirect_from: /2014/03/app-v-flexnet-licensing-service/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Flexnet
---

If an application uses the **Flexnet Licensing Service**, it can be sequenced and will at first appear to work fine in App-V. However, if you have more than one instance of this service on the machine you can run into problems:

* A Flexnet service may fail to start if the process is already running, which can cause the application that tried to start it to hang or crash.
* An application can talk to the wrong instance of the service, which can produce errors saying that the application is not licensed.
* Alternatively, an application can throw an error if the Flexnet service it comminicates with is an older version than expected.

These errors can vary depending on which application is started first. The Flexnet service is typically started manually by the calling application, then stopped when that application is closed. Whilst it is open, all other Flexnet applications will use that instance of the service. Here's an example of the problem - I have virtualised **Adobe Photoshop CS4** with its own embedded copy of the Flexnet service, and have installed **Tableau Desktop 8.1** locally, which also installs the service. Both applications work independently, but if I start Photoshop first, then Tableau, problems occur. Tableau hangs on load whilst it is waiting for the service to start; it then gives up waiting and talks to it anyway, only to find that it is the incorrect version:

[![Tableau error]({{ site.url }}{{ site.baseurl }}/assets/images/2014-04-17-app-v-flexnet-licensing-service/Tableau-error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-04-17-app-v-flexnet-licensing-service/Tableau-error.png)

And if I try to start the local Flexnet service manually, I see this:

[![Error starting Flexnet service]({{ site.url }}{{ site.baseurl }}/assets/images/2014-04-17-app-v-flexnet-licensing-service/Error-starting-Flexnet-service.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-04-17-app-v-flexnet-licensing-service/Error-starting-Flexnet-service.png)

Since these problems might not be picked up until its too late, when the apps are already published to users, I always recommend banning Flexnet from every single virtual package and instead *deploy it locally as an MSI*.

There are both 32-bit and 64-bit versions of this service, and both should use the highest version available and be regularly updated whenever a newer version is discovered. It's probably even worth installing them on your base sequencer image. If you install these services on the sequencer **before** monitoring, the service will never be picked up in the package. Unless the application you are sequencing contains a newer version, in which case the executable will be updated - in which case you should stop, update the Flexnet MSI package, then start again.

The latest versions I have found are **11.13.1.0** for 64-bit, and **11.16.0.0** for 32-bit. They are built with Installshield, each contains just the single licensing service executable and uses the MsiLockPermissionsEx table to grant the Users group rights to start and stop the service. Because of this it depends on Windows Installer 5.0, so will only work on Windows 7 / Server 2008 R2 an upwards. ISM files are provided if you want to rebuild them yourself. If you come across newer versions, let me know and I can rebuild them and share!

***[Click here to download the packages.]({{ site.url }}{{ site.baseurl }}/downloads/FLEXnet.zip)***