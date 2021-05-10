---
title: 'Nevergreen: My first Powershell module'
slug: nevergreen-my-first-powershell-module
date: '2021-05-10 00:00:00'
layout: single
classes: wide
categories:
  - Powershell
tags:
  - Powershell
---

Nevergreen is a Powershell module that returns the latest version and download links for various Windows applications. It can be used as an alternative to Aaron Parker's (and others) excellent [Evergreen](https://stealthpuppy.com/Evergreen/index.html) module.

<!--More-->
Evergreen uses API queries to obtain its data whereas this module is more focussed on web scraping. This is inherently more prone to breaking when websites are changed, hence the name! The Evergreen project wants to avoid web scraping wherever possible, so this is a home for all those other apps where there is no other option. Expect frequent breakages - if you do come across issues, contact me or create an issue on Github, or if you're feeling up to it, fix it yourself and create a pull request!

This has been designed to complement, rather than compete with Evergreen - it uses a similar syntax so that you can use both modules together in your own automated application packaging / deployment / image creation workflows!

## Installation
To install the module from the Powershell Gallery:
{% highlight powershell %}
Install-Module -Name Nevergreen
{% endhighlight %}

## Usage
List all supported apps:
{% highlight powershell %}
Find-NevergreenApp
{% endhighlight %}

List all Adobe and Microsoft apps (accepts arrays and uses a RegEx match):
{% highlight powershell %}
Find-NevergreenApp -Name Adobe,Microsoft
{% endhighlight %}

Get version and download links for Microsoft Power BI Desktop (all platforms):
{% highlight powershell %}
Get-NevergreenApp -Name MicrosoftPowerBIDesktop
{% endhighlight %}

Get version and download links for Microsoft Power BI Desktop (64-bit only):
{% highlight powershell %}
Get-NevergreenApp -Name MicrosoftPowerBIDesktop | Where-Object {$_.Architecture -eq 'x64'}
{% endhighlight %}

Combine both commands to get all results!
{% highlight powershell %}
Find-NevergreenApp | Get-NevergreenApp
{% endhighlight %}


[View the module on the Powershell Gallery](https://www.powershellgallery.com/packages/Nevergreen)

[View the repository on Github](https://github.com/DanGough/Nevergreen)
