---
title: App-V and .NET Framework Native Images
slug: app-v-net-framework-native-images
excerpt: What are .NET native images, and how they impact performance and can sometimes break your virtualised apps.
date: '2016-08-02 14:57:21'
redirect_from: /2016/08/app-v-net-framework-native-images/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

Assemblies written using the .NET Framework aren't compiled directly to machine code. The exes and dlls are like a halfway house between written code and pure machine code, and are compiled 'just-in time' by the .NET Framework as required. This enables them to run on any processor type rather than needing separate binaries for 32-bit and 64-bit.

The .NET Framework has a background service that compiles some of these assemblies to pure machine code (referred to as 'native images') to increase performance. By default it usually just processes the components belonging to the .NET Framework, but application installers can also add some of their own components to the queue. Myself and Tim Mangan have referenced this in the past, here's a few related posts:

[{{ site.url }}{{ site.baseurl }}{% post_url 2012-09-24-fix-net-applications-broken-app-v-security-updates %}]({% post_url 2012-09-24-fix-net-applications-broken-app-v-security-updates %})

[http://www.tmurgent.com/TmBlog/?p=2175](http://www.tmurgent.com/TmBlog/?p=2175)

[http://www.tmurgent.com/TmBlog/?p=2350](http://www.tmurgent.com/TmBlog/?p=2350)

The main points of those articles are:

* Native images captured in the sequence are used
* Application crashes can occur if a .NET Framework update on the client renders these native images invalid (do not sequence with an unpatched .NET 4.0!)
* Application crashes could also occur if monitoring is stopped before the compilation process has completed

I came across an issue recently where a sequenced application was crashing. Opening the package showed that it had captured lots of native images belonging to the .NET Framework, and there were also messages in the event log that appeared to be warning about mismatched versions of .NET components. It turns out the application required both .NET 3.5 (which wasn't installed by default on the Windows 8 sequencer) and 4.6 (which wasn't installed either). Both of these were installed before sequencing, but then the monitoring process picked up various native images of core .NET components coming from the background compilation process, which I can only assume were causing conflicts on the client.

My recommendations are as follows. Create a simple batch file that runs the following commands (the 2nd one is only required on x64):

{% highlight biml %}
C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe executequeueditems
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe executequeueditems
{% endhighlight %}

These commands force the compilation of the current queue to speed things along. You should run this on your sequencer whenever you install a new version of the .NET Framework or apply Windows Updates. You can even add it to the startup folder under the start menu on your sequencer to ensure it is run before you start sequencing. It's also a good idea to run this after installing the application, just before stopping the monitoring process. After re-sequencing with these practices in place, the application crashes were cured!