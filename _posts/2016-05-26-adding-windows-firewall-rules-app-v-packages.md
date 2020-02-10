---
title: Adding Windows Firewall Rules to App-V Packages
slug: adding-windows-firewall-rules-to-app-v-packages
excerpt: How to add Windows Firewall rules to App-V packages via App-V scripts.
date: '2016-05-26 19:00:59'
redirect_from: /2016/05/adding-windows-firewall-rules-app-v-packages/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

You may have noticed Windows Firewall prompts appearing when launching virtualised applications:

[![Firewall Prompt]({{ site.url }}{{ site.baseurl }}/assets/images/2016-05-26-adding-windows-firewall-rules-app-v-packages/prompt.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2016-05-26-adding-windows-firewall-rules-app-v-packages/prompt.png)

This is because App-V does not support detecting or applying firewall rule changes. You could of course apply these rules via group policy, but this becomes difficult since the rule needs to contain the full path including the package and version GUIDs. We can however apply them with a script!

On your sequencer, open the advanced firewall settings by running `wf.msc` and find the rules that were added by the application. If the installer did not add them, then launching the application and dismissing the dialog as shown above will create a rule for you. You may have both inbound and outbound rules to deal with. As mentioned in this [article](https://support.microsoft.com/en-gb/kb/947709), you should use the `netsh advfirewall firewall` command rather than the deprecated `netsh firewall` command. The full syntax for this command can be found [here](https://technet.microsoft.com/en-us/library/dd734783(v=ws.10).aspx).

You should take care to ensure that the rules you set up adhere to any security policies in your organisation (e.g. you may want to only allow an app to communicate if connected to the domain network) so don't necessarily copy the examples provided here exactly. The basic form I am using here for an outbound rule (use dir=in for inbound) is:

`netsh.exe advfirewall firewall add rule name="RULE NAME" dir=out action=allow program="PATH TO EXE.exe" enable=yes`

And to remove:

`netsh.exe advfirewall firewall delete rule name="RULE NAME" program="PATH TO EXE.exe"`

This particular application adds two rules so I am going to use the new Scriptrunner.exe method that requires App-V 5.1. For more info on how to do this refer to the following links:

[https://blogs.technet.microsoft.com/sbucci/2015/09/14/app-v-5-1-scriptrunner](https://blogs.technet.microsoft.com/sbucci/2015/09/14/app-v-5-1-scriptrunner)

[https://technet.microsoft.com/en-us/itpro/mdop/appv-v5/about-app-v-51-dynamic-configuration](https://technet.microsoft.com/en-us/itpro/mdop/appv-v5/about-app-v-51-dynamic-configuration)

I am also going to use another feature added in 5.1, which is the ability to place the script inside the internal AppXManifest.xml so that we don't have to rely upon the external DeploymentConfig.xml file. I used Tim Mangan's excellent [App-V Manifest Editor](http://www.tmurgent.com/TmBlog/?p=2381) tool to make this easier. This results in the following snippet added to AppXManifest.xml:

{% highlight xml %}
<appv:MachineScripts>
  <appv:AddPackage>
    <appv:Path>Scriptrunner.exe</appv:Path>
    <appv:Arguments>-appvscript netsh.exe advfirewall firewall add rule name="Rule 1" dir=out action=allow program="[{ProgramFilesX86}]\MyApp\MyApp.exe" enable=yes 
-appvscript netsh.exe advfirewall firewall add rule name="Rule 2" dir=out action=allow program="[{AppVPackageRoot}]\MyApp.exe" enable=yes</appv:Arguments>
  </appv:AddPackage>
  <appv:RemovePackage>
    <appv:Path>Scriptrunner.exe</appv:Path>
    <appv:Arguments>-appvscript netsh.exe advfirewall firewall delete rule name="Rule 1" program="[{ProgramFilesX86}]\MyApp\MyApp.exe" 
-appvscript netsh.exe advfirewall firewall delete rule name="Rule 2" program="[{AppVPackageRoot}]\MyApp.exe"</appv:Arguments>
  </appv:RemovePackage>
</appv:MachineScripts>
{% endhighlight %}

And since SCCM automatically imports the DynamicConfig.xml, the script should go in there too, otherwise the contents of this file could override what's provided in the manifest:

{% highlight xml %}
<MachineScripts>
  <AddPackage>
    <Path>Scriptrunner.exe</Path>
    <Arguments>-appvscript netsh.exe advfirewall firewall add rule name="Rule 1" dir=out action=allow program="[{ProgramFilesX86}]\MyApp\MyApp.exe" enable=yes 
-appvscript netsh.exe advfirewall firewall add rule name="Rule 2" dir=out action=allow program="[{AppVPackageRoot]\MyApp.exe" enable=yes</Arguments>
  </AddPackage>
  <RemovePackage>
    <Path>Scriptrunner.exe</Path>
    <Arguments>-appvscript netsh.exe advfirewall firewall delete rule name="Rule 1" program="[{ProgramFilesX86}]\MyApp\MyApp.exe" 
-appvscript netsh.exe advfirewall firewall delete rule name="Rule 2" program="[{AppVPackageRoot]\MyApp.exe"</Arguments>
  </RemovePackage>
</MachineScripts>
{% endhighlight %}

I've opted to use AddPackage and RemovePackage here rather than PublishPackage and UnpublishPackage, as this is the only way you can get a script to run as local system when using user publishing. Now after adding that package you should be able to see your rules added in the firewall settings on the App-V client. If you used an App-V variable as above like `[{ProgramFilesX86}]` or `[{AppvPackageRoot}]` when defining your exe path, it should be converted to the full virtual path under `C:\ProgramData\App-V`!