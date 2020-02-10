---
title: Fix For Office 365 / App-V Interaction
slug: fix-office-365-app-v-interaction
excerpt: How to enable Office 365 apps to run in the App-V virtual environment via the AllowJitvInAppvVirtualizedProcess registry key.
date: '2017-10-19 12:59:52'
redirect_from: /2017/10/fix-office-365-app-v-interaction/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Office
---

In my [previous post]({% post_url 2016-08-02-office-365-app-v %}) on this subject, I came to the conclusion that Office 365 apps just wouldn't run in an App-V virtual environment. However there is a fix for this that can be applied to the client registry:

{% highlight ini %}
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ClickToRun\OverRide]
"AllowJitvInAppvVirtualizedProcess"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\ClickToRun\OverRide]
"AllowJitvInAppvVirtualizedProcess"=dword:00000001
{% endhighlight %}

Now, the only official mention of this key anywhere online *used* to be in this knowledge base article:

[https://support.microsoft.com/en-us/help/3159732/-click-to-join-fails-to-invoke-skype-for-business-on-computers-that-us](https://support.microsoft.com/en-us/help/3159732/-click-to-join-fails-to-invoke-skype-for-business-on-computers-that-us)

Even a Google search for 'AllowJitvInAppvVirtualizedProcess' turns up this article, however all reference to it has now been removed. What this means in terms of support I have no idea, so this setting should be added at your own risk; however I have found it to fix multiple issues including:

* Creating shortcuts to Excel as a way to sequence Excel add-ins
* Pasting Visio objects from virtualised Visio into Office 365 Word

I have so far not seen any negative effects from using this setting and am recommending that people use it, with the disclaimer that anybody should contact Microsoft support before doing so!