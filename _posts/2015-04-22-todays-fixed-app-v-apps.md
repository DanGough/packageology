---
title: Today's Fixed App-V Apps!
slug: todays-fixed-app-v-apps
excerpt: Fixing a virtualised Access 2007 that was unable to export to Excel, and an in-house app that was unable to connect to a SQL server.
date: '2015-04-22 11:14:07'
redirect_from: /2015/04/todays-fixed-app-v-apps/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I spend most of my days sequencing and packaging applications, and fixing broken packages. This is just a quick post to detail two App-V 5 apps I've fixed today, perhaps the information may be of use if you encounter similar issues on the front line!

## Access 2007

This customer had Office 2007 on the base and Access 2007 deployed via App-V so that they could control who had 'access' to it. All worked fine until you tried to export some data to Excel, where Excel would refuse to load with an 'out of memory' error. It turns out that Excel just flat out refused to open inside the virtual environment of this package. I suspected that it was because this Access package had been sequenced on a clean machine, making various Office folders and registry keys set to override. Resequencing with Office 2007 already on the base resolved the issue.

## Random In-House App

This in-house line of business application was located on a network share, and the App-V package was simply used to create a shortcut pointing to the exe on the network share. For some reason, it refused to connect to its database when run inside the virtual environment. Since the App-V package contained no files or registry entries, I decided to start my troubleshooting by disabling these virtual subsystems in the package config files. I started with the registry:

{% highlight ini %}
<Registry Enabled="false">
{% endhighlight %}

Hey presto, that worked, but I'm not going to pretend to know the reason why! But sometimes you just have to accept you've fixed it and move on, there's plenty more broken apps needing my attention!