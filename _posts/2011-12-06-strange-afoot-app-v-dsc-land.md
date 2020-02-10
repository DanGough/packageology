---
title: Strange Things Afoot In App-V DSC Land
slug: strange-things-afoot-in-app-v-dsc-land
excerpt: A demonstration of how files and folders may appear hidden in the VFS yet still accessible.
date: '2011-12-06 22:47:00'
redirect_from: /2011/12/strange-afoot-app-v-dsc-land/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

Dynamic Suite Composition, or DSC for short, was a great addition to App-V, but anybody who's used it extensively will realise that it doesn't always work as expected. Tim Mangan has a [whitepaper](http://www.tmurgent.com/WhitePapers/AppV_DSC_Transparency.pdf) that demonstrates some of these issues, but I've come across another one that's rather odd...

As well of using DSC to link to middleware products, it is often used to link to add-ons or configuration files. For example if an application has a different config file for different regions, you could link the main app to all of them with `MANDATORY=FALSE` so that the application would load up whichever config happened to be deployed to that user. If these child applications are installed to the same folder as the main application, you will have to take care to  ensure that the conflicting folders (and registry keys) are set to **Merge** rather than **Override** to ensure that they don't cause your main application files to be hidden.

For this little experiment, I sequenced an old favourite, Textpad, to its default installation directory of **C:\Program Files\TextPad 5**. I then created another sequence that contained just a single text file **Textfile.txt**, located in this same folder. This folder was marked as Override as I sequenced on a clean machine without Textpad being installed first. Normally you should set this to Merge but I want to demonstrate what happens when you don't! I then DSC linked the main Textpad application to the Textfile sequence. Now, expected results are that the child app would override the contents of the common folder so that we would only be able to see our text file and not the main application. By starting a CMD prompt or Explorer window within the bubble, we can see this to be true:

[![DSC1]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC1.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC1.png)

[![DSC2]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC2.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC2.png)

So, as expected we can only see that single text file. Textpad.exe lives in this folder also, but as it's now being hidden, the app must be broken right? Wrong. It still launches just fine. In fact, if you go to File > Open and take a look around, the exe cannot even see itself:

[![DSC3]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC3.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC3.png)

However, if I type in **README.TXT** into this file dialog, a file that comes with the Textpad application but is now invisible, it loads!

[![DSC4]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC4.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC4.png)

So, after observing this, I went back to my CMD prompt that was running in the bubble. Typing in `readme.txt` came back with an error. However, typing `notepad readme.txt` or `type readme.txt` allows it to be read!

[![DSC5]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC5.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2011-12-06-strange-afoot-app-v-dsc-land/DSC5.png)

So as you can see, override doesn't always strictly override after all.

**UPDATE**: Kalle has demonstrated that this is a bug/feature of the VFS and not just related to DSC:
<br><br>
[http://blog.gridmetric.com/2011/12/20/what-everyone-and-their-mother-should-know-about-vfs-in-app-v-pt-3](http://blog.gridmetric.com/2011/12/20/what-everyone-and-their-mother-should-know-about-vfs-in-app-v-pt-3)
{: .notice--info}