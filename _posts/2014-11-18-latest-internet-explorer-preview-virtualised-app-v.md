---
title: The latest Internet Explorer preview is virtualised with App-V!
slug: the-latest-internet-explorer-preview-is-virtualised-with-app-v
excerpt: If you download the latest IE preview from the Internet Explorer Developer Channel, you will find it is packaged with App-V and bundles in a version of the App-V client!
date: '2014-11-18 16:03:48'
redirect_from: /2014/11/latest-internet-explorer-preview-virtualised-app-v/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

This may be intersting to those that have longed for Microsoft to provide a solution to virtualising IE in App-V. If you download the latest IE preview from the [Internet Explorer Developer Channel](http://msdn.microsoft.com/en-us/library/ie/dn722334(v=vs.85).aspx), you will find it is packaged with App-V and bundles in a version of the App-V client!

In fact, it fails to install if you have the App-V client already installed (although you can extract the IEDC.appv file and publish it to a regular App-V client, the only other pre-req is to have IE11 installed).

[![IEinAppV2]({{ site.url }}{{ site.baseurl }}/assets/images/2014-11-18-latest-internet-explorer-preview-virtualised-app-v/IEinAppV2.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-11-18-latest-internet-explorer-preview-virtualised-app-v/IEinAppV2.png)

I'm told that Microsoft have no plans to release IE in App-V format for production use however!