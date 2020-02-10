---
title: 'Resolving Long Application Launch Times in App-V 5 (well, some of them!)'
slug: resolving-long-application-launch-times-app-v-5
excerpt: How to fix App-V apps that take a long time to launch due to scanning the contents of HKCR\CLSID at startup.
date: '2018-11-09 13:08:09'
redirect_from: /2018/11/resolving-long-application-launch-times-app-v-5/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I have seen this issue with a couple of apps now, namely TreeSize and LockLizard. The application takes a crazy long time to launch, completely hogging one of your CPU cores as it does so.

Procmon shows some odd behaviour, the app is seemingly enumerating and scanning all of the keys under HKCR\CLSID or HKCR\Wow6432Node\CLSID:

[![Procmon output]({{ site.url }}{{ site.baseurl }}/assets/images/2018-11-09-resolving-long-application-launch-times-app-v-5/CLSID.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2018-11-09-resolving-long-application-launch-times-app-v-5/CLSID.png)

Setting the CLSID key to override inside the package solves the issue, as then it can only see the very small number of GUIDs captured in your package, which it can enumerate very quickly. The potential downside of course is if your application needs to access any COM classes from the base OS, it may be unable to find them, although I have not encountered any such issues so far!