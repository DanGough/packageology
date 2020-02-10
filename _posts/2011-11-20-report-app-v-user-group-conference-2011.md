---
title: 'Report: App-V User Group Conference 2011'
slug: report-app-v-user-group-conference-2011
excerpt: A report back from the European App-V User Group Conference 2011 held in Amsterdam.
date: '2011-11-20 12:00:06'
redirect_from: /2011/11/report-app-v-user-group-conference-2011/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

I recently got back from this great event at Microsoft HQ in the Netherlands. The whole thing was sponsored by [Login Consultants](http://www.loginconsultants.com), who amazingly hosted the whole thing for free including refreshments, which is a great service to the community. It was more popular than expected and due to high demand the 100 capacity was reached within a couple of weeks after registration opened.

The day kicked off with [Ruben Spruijt](http://twitter.com/rspruijt) (from [PQR](http://www.pqr.com)), who went into detail discussing how App-V affects performance in a VDI environment. There were some very interesting results, some of which unpublished but will all soon be available to read at [Project VRC](http://www.projectvrc.com). You may also be interested to read Ruben's contributions to [virtuall.nl](http://www.virtuall.nl) which include various 'smackdowns' comparing application virtualisation, desktop virtualisation, and user environment management products from different vendors.

After that was an advanced App-V troubleshooting guide from two Microsoft support engineers Madelinde Walraven and Sebastien Gernert. I picked up some good tips from them and found out about a whole bunch of extra App-V log files which are disabled by default. They were also happy to talk to anybody afterwards about any issues they were having. I'll be posting about mine on here at some point!

Next came a demo of SCCM 2012 from [Ment van der Plas](http://twitter.com/mentvanderplas) (author of [softgridblog.com](http://www.softgridblog.com)) which was very interesting to see. There are some great features in there to make life easier for software deployment; for instance there is a new application catalog where MSI packages, App-V sequences and remote applications can all be controlled from one place. It's also now possible to provide pre-reqs for App-V deployments which is handy if you have to split a driver out into a separate package.

Then [Nicke Källén](http://twitter.com/znackattack) (from [Viridis IT](http://www.viridisit.se/eng/blog)) gave us a session on 'Heavy Duty Sequencing'. Nicke is a bit of an App-V ninja with several special moves to defeat App-V limitations. Next time I encounter an app that I'm having trouble sequencing, I'll be in touch, sensei.

[Jurjen van Leeuwen](http://twitter.com/Leodesk_IT) (from [Leodesk](http://leodesk.com)) then gave us a tour of the forthcoming Server App-V, which enables you to virtualise IIS web applications and other services. I'll be interested to see where this is headed and if it takes off.

[Falko Gräfe](https://twitter.com/kirk_tn) (from [Login Consultants](http://www.loginconsultants.com)) then went deep into DSC linking showing how it doesn't always work in the way you'd expect. If DSC is giving you headaches I suggest reading [Tim Mangan's whitepaper](www.tmurgent.com/WhitePapers/AppV_DSC_Transparency.pdf) on the subject. He also showed us every sequencer's nightmare, an 'application cloud' consisting of over 20 apps linked together in various directions, forming a diagram that I nicknamed the 'web of despair'.

[Rodney Medina](http://twitter.com/Rodney_Medina) (CTO of [Immidio](http://immidio.com)) came in at the last minute to replace [Aaron Parker](http://twitter.com/#!/stealthpuppy) (who unfortunately could not attend) who was originally going to discuss the definitive guide to sequencing Office 2010. Since he wanted to say more than three words ("Don't do it!"), Rodney decided not to talk about the same topic and instead gave a very interesting presentation on the role of user-state virtualisation and how it fits in with App-V.

Finally to round things off, all 8 MVPs took centre stage to bust the top 10 myths regarding App-V. Here's a photo of this along with the back of my balding head:

<a href="http://t.co/jCRSJPk4" target="_blank">![App-V User Group final session]({{ site.url }}{{ site.baseurl }}/assets/images/2011-11-20-report-app-v-user-group-conference-2011/AppVUG.jpg)</a>

Overall it was a brilliant day out and I'm very glad I went along. Next year's event will be held at the Sheraton Hotel near Schipol Airport with a much larger capacity - keep an eye on [appvug.com](http://appvug.com) for details!


