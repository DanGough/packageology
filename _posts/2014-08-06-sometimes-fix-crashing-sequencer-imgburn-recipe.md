---
title: How To (sometimes) Fix A Crashing Sequencer! ImgBurn Recipe
slug: how-to-sometimes-fix-a-crashing-sequencer
excerpt: How to fix a sequencer crashed caused by badly handled file extension / ProgID registrations.
date: '2014-08-06 13:35:14'
redirect_from: /2014/08/sometimes-fix-crashing-sequencer-imgburn-recipe/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I've come across a couple of apps recently that just do not want to be sequenced, crashing the sequencer in various ways, or even producing a package with an invalid manifest that cannot be imported. The first one was [ImgBurn](http://www.imgburn.com/ "ImgBurn"), a freeware disc image burning tool, and the second was IBM iSeries Access for Windows. I will use ImgBurn to demonstrate the issue, the debugging, and the solution.

## The Problem

So, download and sequence ImgBurn, then attempt to go through to the process where you launch the applications for streaming optimisation, and you will see:

> Exception of type Microsoft.ApplicationVirtualization.Packaging.EncoderTools.EncoderToolsException was thrown

[![ImgBurn - Streaming Error]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Streaming-Error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Streaming-Error.png)

Hmm, not good. If you press OK and try to launch again the sequencer will hang forever. So, revert and try again but skip the streaming phase to go straight to the final package editing phase and you instead get:

> Microsoft Application Virtualization Sequencer has stopped working

[![ImgBurn - Editing Sequence]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Editing-Sequence.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Editing-Sequence.png)

Not much better. So, revert again and this time just hit the option to save the package immediately - this time you will save a package but with an *'Invalid manifest detected'* error:

[![ImgBurn - Invalid Manifest Detected]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Invalid-Manifest-Detected.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Invalid-Manifest-Detected.png)

## Debugging

Now you at least have a package to play with - but it fails to import into the client. The error message is not of much use, it pretty much just tells us that the manifest is invalid like the sequencer already did:

[![ImgBurn - PoSh Import Error]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-PoSh-Import-Error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-PoSh-Import-Error.png)

The Event Log doesn't show anything on the Sequencer or the Client. The hidden debug logs show nothing on the sequencer either, but there is one in particular you want to activate on the client - ManifestLibrary:

[![Event Viewer - Show Debug Log]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/Event-Viewer-Show-Debug-Log.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/Event-Viewer-Show-Debug-Log.png)

[![Event Viewer - Enable ManifestLibrary Debug Log]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/Event-Viewer-Enable-ManifestLibrary-Debug-Log.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/Event-Viewer-Enable-ManifestLibrary-Debug-Log.png)

After this, import the app again and you will see this in the event log:

[![ImgBurn - ManifestLibrary Error]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-ManifestLibrary-Error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-ManifestLibrary-Error.png)

According to this, there is a ProgId entry with a missing name. Rename the .appv file to .zip and examine the AppxManifest.xml file buried within. This is how a file association should look - notice that the file extension is associated with a ProgId, then the ProgId definition follows along with the shell commands. This is the same way the file extensions, ProgIds and commands are usually linked in the registry:

[![ImgBurn - Manifest ccd FTA]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Manifest-ccd-FTA.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Manifest-ccd-FTA.png)

However, the definitions for .img and .iso appear different - there is no name listed for the ProgId:

[![ImgBurn - Manifest img FTA]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Manifest-img-FTA.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Manifest-img-FTA.png)

Looking at regedit back on the sequencer with the app still installed, the .iso and .img extensions are pointing to the ProgId Windows.IsoFile. Also, rather than listing the commands under the ProgIds, ImgBurn takes the non-standard approach of listing the commands directly under the extensions:

[![ImgBurn - Registry iso]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Registry-iso.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Registry-iso.png)

[![ImgBurn - Registry WindowsIsoFile]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Registry-WindowsIsoFile.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Registry-WindowsIsoFile.png)

I am assuming that the sequencer has difficulties when commands are registered directly under the extension key, and that extension key links to an already existing ProgID. So lets fix that by linking the .img and .iso extensions to the already existing but seemingly unused ImgBurn.AssocFile.img and ImgBurn.AssocFile.iso ProgIds:

[![ImgBurn - Registry ImgBurnAssocFileIso]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Registry-ImgBurnAssocFileIso.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2014-08-06-sometimes-fix-crashing-sequencer-imgburn-recipe/ImgBurn-Registry-ImgBurnAssocFileIso.png)

After making this link, the shell command exists twice (and gets picked up twice in the sequencer) so the duplicate commands listed directly under the extension keys should be deleted.

## Solution

To remedy this, add the following registry entries after installing whilst still monitoring:

{% highlight ini %}
[HKEY_CLASSES_ROOT\.img]
@=”ImgBurn.AssocFile.img”

[HKEY_CLASSES_ROOT\.iso]
@=”ImgBurn.AssocFile.iso”
{% endhighlight %}

And delete these keys:

{% highlight ini %}
[-HKEY_CLASSES_ROOT\.img\shell]
[-HKEY_CLASSES_ROOT\.iso\shell]
{% endhighlight %}

Then proceed as normal; the file type associations will be picked up as they should and the application can be launched successfully during the streaming phase, saved and deployed.

## Fixing Other Apps

The solution for IBM iSeries was slightly different; the installer nests two ProgIds, BCH and WS, under a common PCOMW key. The file associations for .bch and .ws then refer to the ProgId in the format PCOMW\BCH and PCOMW\WS.

The AppxManifest.xml schema does not allow backslashes in ProgId names, so this was causing the error, found by exactly the same troubleshooting steps listed for ImgBurn. The fix in this case was to move these ProgIds into their own keys PCOMW.BCH and PCOMW.WS and update the file extension keys to suit, essentially replacing the backslash with a dot.

Hopefully this can apply to other apps out there - let me know via the comments below if you've found any others!