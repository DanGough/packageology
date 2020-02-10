---
title: IE11 Freezes on First Launch in App-V
slug: ie11-freezes-on-first-launch-in-app-v
excerpt: The first launch of IE11 for a user will fail if it's run insidethe virtual environment. Here's how to solve that.
date: '2016-08-02 16:14:10'
redirect_from: /2016/08/ie11-freezes-launch-app-v/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

This is an issue that has been known to many since Internet Explorer 11 was released, discussed on various forums, but never to my knowledge distilled into a blog post. I hit this issue in an unexpected way recently so thought it was high time it was shared!

Basically, when IE11 is launched for the first time for each user, the initial setup needs to happen *outside* of a virtual environment, otherwise it freezes/crashes. The unusual way I came across this was that I had sequenced AutoCAD Civil 3D 2017, which worked fine on all machines except the new Windows 10 clients. It turned out that the application shows a splash screen that hosts an IE window, which was locking up the application. We did not see this on the other clients as they had already launched IE in the past. IE had never been launched on the Windows 10 clients because the the default browser was Edge!

One workaround for this is to use Active Setup to launch Internet Explorer once per user per machine. Paste this into a .reg file if you want to try this method:

{% highlight ini %}
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\LaunchInternetExplorer]
@="Launch Internet Explorer"
"Version"="1,0,0"
"StubPath"="C:\\Windows\\System32\\cmd.exe /c START \"\" \"C:\\Program Files (x86)\\Internet Explorer\\iexplore.exe\""</pre>
{% endhighlight %}

If you happen to have IE in a Connection Group via RunVirtual, then you will need some kind of script to open IE before creating the RunVirtual keys. I'll leave that one to you!

### UPDATE:

You can also fix this issue by adding the following empty registry key within the package!

{% highlight ini %}
[HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\LowRegistry]
{% endhighlight %}