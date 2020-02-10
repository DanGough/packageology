---
title: App-V 5.0 and TerminateChildProcesses
slug: app-v-5-0-and-terminatechildprocesses
excerpt: A guide to terminating child processes in App-V 5, along with a few bugs to avoid.
date: '2014-03-19 19:58:47'
redirect_from: /2014/03/app-v-5-0-terminatechildprocesses/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

You know, I think somebody on the product team at Microsoft must have looked at the old 4.6 setting 'TERMINATECHILDREN' and thought: 

> You know what, I think we ought to rename that. It sounds a little evil, especially in all caps like that. How about TerminateChildProcesses? Oh, and while we're at it, let's do what we can to stop it working like it used to. Save the children!

I've found a few bugs with the new TerminateChildProcesses functionality in App-V 5.0...

## Detection Of Lingering Child Processes

In App-V 4.6, if you launch your applications in the 'streaming optimisation' phase, the sequencer hangs around to make sure that all child processes are closed before continuing. If you close your app but this is still hanging around due to lingering child processes, you press the Stop button to force it to close:

[![4.6 sequencer]({{ site.url }}{{ site.baseurl }}/assets/images/2014-03-19-app-v-5-0-terminatechildprocesses/4.6.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-03-19-app-v-5-0-terminatechildprocesses/4.6.png)

App-V 5.0 works slightly differently in that it will just tell you if any child processes are found when you hit next to finish the streaming phase:

[![5.0 sequencer]({{ site.url }}{{ site.baseurl }}/assets/images/2014-03-19-app-v-5-0-terminatechildprocesses/5.0.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-03-19-app-v-5-0-terminatechildprocesses/5.0.png)

However I have found that I rarely see the above message, and often have to force it to pop up by leaving my specific application open when I press next if I know I want the TerminateChildProcesses setting applied to that app. *And I have just figured out why!*

In 4.6, the 'configure' phase (which runs prior to the 'streaming optimisation' phase shown above) spins up a mini virtual environment, like a cut-down App-V client. When you press next to complete the phase, this virtual environment is disposed of along with any processes that were created within it, including task manager and any explorer windows that were opened.

In 5.0, the application is executed as a regular native application. This makes sequencing much faster, however when you go past this phase, any lingering child processes are left running. Then these problematic processes are not detected as new processes because they were already running when entering the 'streaming optimisation' phase, hence the dialog above will not appear!

If Microsoft are listening, I would recommend that the sequencer do a diff between running processes at the start of the sequencing process and the end of the streaming optimisation phase. Another added benefit of moving the detection to this earlier phase, is that it adds child process detection for those of us that don't perform streaming optimisation (which will be more commonplace now that [fault streaming has been said to be more efficient!](http://www.tmurgent.com/TMBlog/?p=1946 "Streaming Theory - "Should you Launch?")).

There are a couple of things you can do to avoid this if it is important to you:

1. Before the streaming optimisation phase, open the task manager, and kill any processes that look like they are related to your application.
2. Alternatively, don't launch your app from the installer, start menu, or configuration phase. Instead, configure your app *only* in the streaming optimisation phase. All file/registry changes will be captured, however bear in mind that you will no longer capture any new shortcuts or file associations if your app happens to register them on first launch.

## Internal Manifest vs DeploymentConfig.xml

The 5.0 sequencer correctly adds the required `<TerminateChildProcess>` tags to both the manifest file inside the .appv package, and the external DeploymentConfig.xml. In fact it will add multiple identical entries for the same app if you launch it and accept the dialog more than once (another bug!):

{% highlight xml %}
<TerminateChildProcesses>
  <Application Path="[{ProgramFilesCommonX86}]\Adobe\Adobe Drive CS4\ConnectUI\Adobe Drive CS4.exe" />
  <Application Path="[{ProgramFilesCommonX86}]\Adobe\Adobe Drive CS4\ConnectUI\Adobe Drive CS4.exe" />
</TerminateChildProcesses>
{% endhighlight %}

The main problem however, is that the App-V client *totally ignores* the setting in the internal manifest file and will only listen to the setting in DeploymentConfig.xml, which may not have been imported. These config files are only imported automatically if using SCCM integration, so if using the App-V Management Server there will be an extra step required to import the config. If you are using the MSI package to deploy, help is at hand with [this transform I created earlier]({% post_url 2014-03-07-applying-dynamic-config-app-v-5-msi-packages %} "Applying Dynamic Config To App-V 5 MSI Packages").