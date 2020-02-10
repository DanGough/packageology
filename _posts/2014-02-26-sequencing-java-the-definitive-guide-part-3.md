---
title: Sequencing Java - The Definitive Guide Part 3
slug: sequencing-java-the-definitive-guide-part-3
excerpt: Part 2 of the Java sequencing guide - Restricting access to insecure Java versions.
date: '2014-02-26 17:56:52'
redirect_from: /2014/02/sequencing-java-definitive-guide-part-3-restricting-access-insecure-java-versions/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
  - Java
---

Back in [Part 1]({% post_url 2014-02-05-sequencing-java-the-definitive-guide-part-1 %}), we established the reasons for virtualising Java along with best practices for doing so, and in [Part 2]({% post_url 2014-02-06-sequencing-java-the-definitive-guide-part-2 %}), we went over how the new features of App-V 5.0 SP2 can cause problems with this solution.

The next step is to create either a DSC link or Connection Group between your application and the Java package. Typically the 'application' will be just an Internet Explorer shortcut pointing to specific URL. There is a problem with this approach however. The user will typically not be aware of what is going on under the hood, they just know that for this website to work, they need to use this special start menu shortcut, as it won't work by just typing the URL into their browser. Once the browser has been launched in the virtual environment with an insecure Java version (aren't they all?), there is nothing preventing the user from continuing to use the session for their day-to-day browsing, where they might be unlucky enough to suffer at the hand of one of many exploits in the wild.

You can't rely on the basic isolation that App-V provides as a security blanket either, as there are plenty of ways to break out of the sandbox. This post describes a solution to lock down the virtualised instance of Java so that it can only be loaded by specific sites. There are a few different ways to pull this off, but the simplest solution I came up with was to configure the internet settings to put every site into **Restricted Sites** by default, then configure a domain whitelist to allow specific URLs to be assigned an alternate zone, such as **Internet**, **Intranet**, or **Trusted Sites**. There are four locations in the registry that can store these settings, and they have a hierarchy as follows:

1. HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings
2. HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings
3. HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings
4. HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings

Since HKLM\Software\Policies overrides all of the other locations, this is where we should place our configuration settings. All of these locations are ignored by default in App-V 5, so the registry settings on the client need to be reconfigured for this to work. Also, in App-V these settings are ignored if placed in any DSC link child packages, so they must be placed in the main package. See my previous post [Overriding Group Policy Settings With App-V]({% post_url 2014-02-05-overriding-group-policy-settings-app-v %}) for further information about this. There are four default zones configured in Internet Explorer and each is assigned a number:

* 0 - My Computer
* 1 - Local Intranet
* 2 - Trusted Sites
* 3 - Internet
* 4 - Restricted Sites

To configure all URLs to default to Restricted Sites, the following registry keys can be set:

{% highlight ini %}
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\ProtocolDefaults]
"http"=dword:00000004
"https"=dword:00000004
"ftp"=dword:00000004
"file"=dword:00000004
"shell"=dword:00000004
{% endhighlight %}

There may be other protocols you wish to lock down, but these are all the defaults. This however does not seem to apply when HTML files are loaded from the local machine, so to optionally harden the My Computer zone to block the Java plugin, the following key can be set (see [this page](http://support.microsoft.com/kb/182569 "Internet Explorer security zones registry entries for advanced users") for further information):

{% highlight ini %}
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0]
"1200"=dword:00000003 (disables all ActiveX controls loaded via the object tag)
"1C00"=dword:00000000 (disables loading of Java via the applet tag)
{% endhighlight %}

Then, to place the domain **javatester.org** in the **Internet** zone, where it will be able to load Java, the following registry key can be set:
 
{% highlight ini %}
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\javatester.org]
"*"=dword:00000003
{% endhighlight %}

The asterisk denotes all protocols, and the number 3 equates to the **Internet** zone as described previously. All of these internet settings registry keys should be marked as **merge**, except for the **Domains** key listed above, which should be set to **override**. This is because we don't want to override the entire Internet Settings key since it might contain vital settings such as proxy configuration. We do however want full control of the contents of the Domains key since the domain policy applied to clients might already contain some entries to direct certain URLs to Trusted Sites for example.

# Sequencing Recipe For IE Shortcuts

It is recommended to create these sequences on a 32-bit machine if possible to increase their portability. Although I recommend steering clear of App-V 5.0 SP2 for now for creating the Java packages, it is fine to use it for generating these shortcut packages.

## Pre-Sequencing Steps

If sequencing on a clean machine, many of the registry keys under HKLM\Software\Policies will not exist, so creating them prior to sequencing will help ensure that they get marked as merge by default rather than override. Set the following registry keys:

{% highlight ini %}
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\ProtocolDefaults]

[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0]
{% endhighlight %}

## Monitoring Steps

### Create The Shortcut

Create a shortcut to Internet Explorer. Unless the site has a specific requirement to use a 64-bit Java plugin with the 64-bit version of Internet Explorer, ensure to use the 32-bit version of Internet Explorer from Program Files (x86) on a 64-bit Windows machine. Edit the shortcut target to add the `-noframemerging` parameter followed by your URL. This switch forces Internet Explorer to create a new process, rather than pass the request to an instance of the browser that could already be running outside of the bubble. For example, on 64-bit Windows:

`"C:\Program Files (x86)\Internet Explorer\iexplore.exe" -noframemerging http://javatester.org`

Or on 32-bit Windows:

`"C:\Program Files\Internet Explorer\iexplore.exe" -noframemerging http://javatester.org`

Change the default icon if desired. You can either change it to the IE page icon as shown below:

[![IE icons]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/IE-icons.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/IE-icons.png)

Or, if your desired web site uses a favicon, e.g:

[![favicon]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/favicon.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/favicon.png)

You can find this in %LOCALAPPDATA%\Microsoft\Windows\Temporary Internet Files:

[![temporary internet files]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/temporary-internet-files.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/temporary-internet-files.png)

However, you cannot browse to this location from the Change Icon dialog box so just copy it to the %TEMP% folder first (so that it does not get picked up as a file during monitoring). Do not launch Internet Explorer during the sequencing process.  It is not necessary to create feature blocks to optimise streaming as the package will be tiny in size and launching will only capture unnecessary registry settings.

### Applying The Policy Settings

Apply the following registry keys, adjusting the domain name and the required zone number as necessary:

{% highlight ini %}
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\javatester.org]
"*"=dword:00000003

[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\ProtocolDefaults]
"http"=dword:00000004
"https"=dword:00000004
"ftp"=dword:00000004
"file"=dword:00000004
"shell"=dword:00000004

[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0]
"1200"=dword:00000003
"1C00"=dword:00000000
{% endhighlight %}

## Post-Monitoring Steps

Again, do not launch Internet Explorer during the customise / streaming phases.

Create a mandatory DSC link to the required Java package if using App-V 4.6.

Check the override/merge status of the HKLM\Software\Policies keys. These should be correct if the pre-sequencing step was followed and the application was sequenced on a clean machine with no group policies applied. In general, it is recommended that all the policy keys are set to merge except for the **Domains** subkey.

**You can download all of the required reg files and some pre-configured Internet Explorer shortcuts [here]({{ site.url }}{{ site.baseurl }}/downloads/Java-Lockdown.zip).**

# Demonstration

To give these packages a spin, I created them with App-V 5, and created a connection group using Tim Mangan's excellent [App-V Manage](https://www.tmurgent.com/appV/en/resources/AppV_Manage/221-appv-manage-introduction) tool:

[![App-V Manage Connection Group]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/App-V-Manage-Connection-Group.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/App-V-Manage-Connection-Group.png)

Then by launching my specially crafted shortcut, Internet Explorer opens, loading my virtualised version of Java. Notice the site is in the Internet Zone:

[![IE - Internet Zone example]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/IE-Internet-Zone-example.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/IE-Internet-Zone-example.png)

If I then try to use the same browser instance to navigate to a different website, notice that it automatically gets put into Restricted Sites and the Java plugin is unable to load:

[![IE - Restricted Sites example]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/IE-Restricted-Sites-example.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-02-26-sequencing-java-the-definitive-guide-part-3/IE-Restricted-Sites-example.png)