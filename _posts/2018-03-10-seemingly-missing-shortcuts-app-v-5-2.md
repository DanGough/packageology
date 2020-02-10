---
title: Seemingly Missing Shortcuts in App-V 5.2
slug: seemingly-missing-shortcuts-app-v-5-2
excerpt: The latest sequencer *appears* to miss non-exe shortcuts and multiple shortcuts pointing to the same exe.
date: '2018-03-10 23:04:39'
redirect_from: /2018/03/app-v-hotfixes/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

The App-V '5.2' Sequencer (OK, it's really 10.x rather than 5.2, but that's how people commonly refer to the sequencer bundled with the Windows 10 ADK) detects applications a little differently to 5.1. I'll demonstrate using [VLC](https://www.videolan.org/vlc/download-windows.en-GB.html), since it's freely available, has multiple shortcuts to the same exe, and has shortcuts to non-exe files, all of which make it a great candidate.

So, if you do a basic sequence, App-V 5.1 picks up all 3 VLC shortcuts, as well as some URL and TXT files:

[![App-V 5.1]({{ site.url }}{{ site.baseurl }}/assets/images/2018-03-10-seemingly-missing-shortcuts-app-v-5-2/App-V-5.1-2.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2018-03-10-seemingly-missing-shortcuts-app-v-5-2/App-V-5.1-2.png)

The latest sequencer though appears to just pick up a single shortcut:

[![App-V 5.2]({{ site.url }}{{ site.baseurl }}/assets/images/2018-03-10-seemingly-missing-shortcuts-app-v-5-2/App-V-5.2-2.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2018-03-10-seemingly-missing-shortcuts-app-v-5-2/App-V-5.2-2.png)

However, when this second package is actually published to the client, all shortcuts appear, and they can all be found within the manifest and config files (although the 5.2 sequencer does not create `<Application>` tags for the additional URL and documentation files).

Overall this doesn't have a huge impact - you will just have to be doubly sure to modify all of your shortcuts whilst monitoring, something I have recommended anyway since 5.0 was released due to the sequencer's buggy handling of this aspect.