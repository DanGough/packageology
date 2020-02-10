---
title: Beware When Sequencing Access Runtime!
slug: beware-when-sequencing-access-runtime
excerpt: How to disable file associations and app paths from your virtualised app so that it does not conflict with a locally installed one.
date: '2015-04-14 15:30:57'
redirect_from: /2015/04/beware-sequencing-access-runtime/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

Just a quick post to warn of something I encountered today. I had an application that required an older Access 2007 Runtime (Access 2013 was installed locally). The sequencer picked up Access 2007 as an application along with all of its filetype associations, which I duly deleted in the last tab of the sequencer before saving the package. However these filetype associations still exist, and after publishing the application, Office 2013 triggerred a time consuming self-repair when the user double-clicked on an mdb file.

The solution is to disable these FTA's from within the configuration files; I could do this quickly by disabling the entire subsystem as my application did not register any. But if your application has some, you will need to comment out all of the Access related ones, which is no simple task as there are so many! I applied this change to both DeploymentConfig and UserConfig xml files (as I did not know how the app was going to be published):

{% highlight xml %}
<FileTypeAssociations Enabled="false">
{% endhighlight %}

Whilst I was digging around in this file I also noticed an app path was registered. Trying to run msaccess.exe via Explorer's run box tried to launch the virtual Access 2007 runtime rather than my local Access 2013. It would be possible to disable this entire subsystem also:

{% highlight xml %}
<AppPaths Enabled="false">
{% endhighlight %}

However, my application had an app path I wished to keep so I just commented out the ones I did not require:

{% highlight xml %}
<!--Extension Category="AppV.AppPath">
  <AppPath>
    <Name>MSACCESS.EXE</Name>
    <ApplicationPath>[{ProgramFilesX86}{~}]\MICROS~1\Office12\MSACCESS.EXE</ApplicationPath>
    <PATHEnvironmentVariablePrefix>[{ProgramFilesX86}]\Microsoft Office\Office12\</PATHEnvironmentVariablePrefix>
    <ApplicationId>[{ProgramFilesX86}]\Microsoft Office\Office12\MSACCESS.EXE</ApplicationId>
    <CanAcceptUrl>1</CanAcceptUrl>
  </AppPath>
</Extension>
<Extension Category="AppV.AppPath">
  <AppPath>
    <Name>MsoHtmEd.exe</Name>
    <CanAcceptUrl>1</CanAcceptUrl>
  </AppPath>
</Extension-->
{% endhighlight %}

Remember these config files are not used by default when either publishing from the App-V Mangement Server or installing from the MSI so they will need to be specified. If you are using the MSI packages I have a solution to import the config files over [here]({% post_url 2014-03-07-applying-dynamic-config-app-v-5-msi-packages %} "Applying Dynamic Config To App-V 5 MSI Packages").