---
title: Sequencing Java - The Definitive Guide Part 2
slug: sequencing-java-the-definitive-guide-part-2
excerpt: Part 2 of the Java sequencing guide - Problems with App-V 5.0 SP2.
date: '2014-02-06 09:19:44'
redirect_from: /2014/02/sequencing-java-definitive-guide-part-2/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Java
---

In [Part 1]({% post_url 2014-02-05-sequencing-java-the-definitive-guide-part-1 %}), I discussed the reasons for virtualising Java along with some of the common problems, with a recipe to ensure the virtual Java instance is suitable isolated from any local installations. This part discusses how the new App-V 5.0 SP2 functionality negatively impacts the usage of virtualised Java plugins in a typical enterprise environment.

As of SP2, App-V 5.0 handles Browser Helper Objects and ActiveX controls differently - if the package is published globally (i.e. per machine) rather than per user, these components are locally integrated so that the native Explorer and Internet Explorer processes can see them without having to launch these processes inside the virtual environment. On the one hand, this is great new functionality, meaning you can now virtualise your primary instances of Adobe Reader, Flash Player, etc. On the other hand, there is no obvious way of disabling this functionality on a per-package basis. One of the selling points of a virtualisation solution is that you can deploy applications without fear of messing up anything that is locally installed. By beginning to integrate components locally, App-V is beginning to cross over into the dark side!

This new functionality works for the relatively simple ActiveX controls mentioned above, but for some reason it does not work with Java possibly due to its more complex launch process, where in addition to having multiple CLSIDs registered for the plugin, there is an additional Browser Helper Object 'SSV Helper'. As far as I can gather, this is responsible for stepping in to deliver the highest available plugin version unless a specific version is requested (hence the acronym Secure Static Versioning). However, after virtualising Java 6 and publishing globally to a machine that has Java 7 installed (which is a typical usage case), then the Browser Helper Object from v6 ends up overriding the locally installed version:

[![Java 6 SSV Helper Add-on]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-06-sequencing-java-the-definitive-guide-part-2/BHO.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-06-sequencing-java-the-definitive-guide-part-2/BHO.png)

Ignoring App-V for a moment, if you install Java 6 on top of Java 7, you often see a UAC prompt upon the next launch of the Internet Explorer due to ssvagent.exe wanting to run (I assume it is trying to update settings to re-register Java 7 as the default plugin). Exactly the same thing happens when layering the virtualised Java 6 on top of the local Java 7. This is what is shown after attepting to launch the local Internet Explorer

 [![Java UAC Prompt]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-06-sequencing-java-the-definitive-guide-part-2/UAC1.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-06-sequencing-java-the-definitive-guide-part-2/UAC1.png)
 
 This is a really annoying one, because if the user does not have admin rights, that prompt will appear every time they open a new browser tab until an admin comes along and authorises it. In addition another new security prompt appears, but this one can be got rid of via the checkbox:
 
 [![Internet Explorer Security Prompt]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-06-sequencing-java-the-definitive-guide-part-2/Security-Prompt.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-06-sequencing-java-the-definitive-guide-part-2/Security-Prompt.png)
 
 The proper solution to this would be to modify DeploymentConfig.xml to disable the subsystems related to ActiveX controls and Browser Helper Objects, but unfortunately I have not yet been able to figure out how to do this. I've tried using the tag element names from the internal manifest and putting them in the config file, but it failed to import every time due to invalid XML. Either I am doing something wrong, or the new elements have not yet been added to the config.xml schema! The current workarounds for this are:

* **Ensure all Java packages are deployed per-user** rather than per-machine / globally published. This way the problematic components will not be integrated locally. Bear in mind that if you are deploying via the MSI produced by the sequencer, that this publishes the app globally.
* If this is not feasible then **sequence the Java plugins using App-V 5.0 SP1**.
* **Reinstall the local Java version** each time after publishing a virtual instance.
* Alternatively, these new App-V 5.0 SP2 features can be switched off - but this is a last resort as it affects all packages on the system. This setting disable Shell Extensions, Browser Helper Objects, and Active X controls, and must be set before publishing the application:

{% highlight ini %}
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\Client\Virtualization]
"EnableDynamicVirtualization"=dword:00000000
{% endhighlight %}

* Similar to above, there is another setting that controls which processes are able to integrate with these new dynamic virtualisation features. If you want to keep the shell extensions working in Explorer, and just disable the Internet Explorer stuff, you should be able to do this by removing iexplore.exe from the following multi-string value:

{% highlight ini %}
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppV\Client\Virtualization]
"ProcessesUsingVirtualComponents"= REG_MULTI_SZ...
{% endhighlight %}

If you're feeling experimental, some additional (and brutal) workarounds I have thought up but not yet tested are:

* Running a PublishPackage script to launch the command **<Java Install Dir>\bin\ssvagent.exe -new -high**. This should prevent the UAC prompt by running the command pre-emptively.
* Running a script to temporarily switch the EnableDynamicVirtualization setting off then on again after importing the package.
* Running a PublishPackage script to reinstall the local Java to overwrite any unwanted settings coming from the App-V package.
* Replacing the manifest in the virtualised ssvagent.exe to change the requested execution level to asInvoker. This way it would not show a UAC prompt, and could either fail gracefully or horribly when it finds it's unable to do what it wants to do.
* Delete the SSV Browser Helper Object from the virtual package. The keys appear to be located under **HKLM\SOFTWARE\Microsoft\Windows\Explorer\Browser Helper Objects**. This should stop it being integrated locally, but the downside is that it will not be available within the virtual environment either, where it may be needed - in fact a virtualised Java 6 might even then start using the SSV Helper from a local Java 7 installation which could have unwanted effects.

### Additional Issues Using App-V 5.0 SP2 Alongside 4.6.x

An additional issue has come about, regarding using App-V 5.0 SP2 & 4.6 on the same machine. Basically, if you had any 4.6 sequences with shortcuts to Internet Explorer, installing 5.0 SP2 breaks them. This is due to the new dynamic virtualisation features, it appears that App-V 5.0 steps in where it isn't wanted and Internet Explorer no longer lanuches in the 4.6 virtual environment. The original post in German from Sebastian Gernert can be found [here](http://blogs.msdn.com/b/sgern/archive/2014/02/04/10496630.aspx), and a translated page [here](http://www.microsofttranslator.com/bv.aspx?from=de&to=en&a=http://blogs.msdn.com/b/sgern/archive/2014/02/04/10496630.aspx).

[Click here to continue to Part 3!]({% post_url 2014-02-26-sequencing-java-the-definitive-guide-part-3 %})