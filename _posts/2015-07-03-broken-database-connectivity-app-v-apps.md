---
title: Broken Database Connectivity in App-V Apps
slug: broken-database-connectivity-in-app-v-apps
excerpt: A fix for App-V apps that are unable to connect to a SQL server by adding the Services\WinSock2 key to PassThroughPaths.
date: '2015-07-03 21:17:56'
redirect_from: /2015/07/broken-database-connectivity-app-v-apps/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

In my [previous post]({% post_url 2015-04-22-todays-fixed-app-v-apps %}), I described an issue with an in-house developed app that was unable to connect to it's database when running inside App-V. A few weeks later, different client, different app (Trojan CASPAR), and I encounter the issue again:

[![Error]({{ site.url }}{{ site.baseurl }}/assets/images/2015-07-03-broken-database-connectivity-app-v-apps/Error.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2015-07-03-broken-database-connectivity-app-v-apps/Error.png)

> SQL Database Logon Error<br>Form: FrmUserLogin<br>Procedure: Open database<br>Error Code: -2147467259<br>Description: [DBNETLIB][ConnectionOpen (Initialize()()).]General network error. Check your network documentation.

I fixed it previously by disabling the entire virtual registry at the package level; but this was not an option this time as there were vital registry entries in this package. And unfortunately I didn't have any 'network documentation' to check. So, I busted out Procmon, but could not find anything that jumped out at me. Then I decided to give [SpyStudio](http://www.nektra.com/products/spystudio-api-monitor/download/) a whirl (which by the way is now available free of charge for the full version). The great thing about this app is that it lets you do two captures and compare them; so I did one with the app running natively, and one with the app running inside the bubble.

Straight away I could see a big block of different behaviour in green so I checked there first. The broken app was making numerous call to **HKLM\System\CurrentControlSet\Services\WinSock2\Parameters:**

[![SpyStudio]({{ site.url }}{{ site.baseurl }}/assets/images/2015-07-03-broken-database-connectivity-app-v-apps/SpyStudio.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2015-07-03-broken-database-connectivity-app-v-apps/SpyStudio.png)

The package did not contain any registry entries under this location, so I decided to add a passthrough path so that the App-V client directs all reads and writes to this key directly to the real registry, bypassing the virtual registry entirely. Under**HKLM\Software\Microsoft\AppV\<wbr>Subsystem\VirtualRegistry** is a multi-sz value **PassThroughPaths** that lists all the keys that bypass the virtual registry. I added this WinSock2 key here, closed and restarted the app, and it could then connect without a hitch!

So, next step is to automate applying this key via an App-V script. I stuck with vbscript for this since I already had a script in my toolbox to do the job for handling multi-sz registry key. Save this as AddWinSock.vbs under the Scripts folder of the App-V package:

{% highlight visualbasic %}
Const HKCU = &H80000001
Const HKLM = &H80000002

Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")

AppendRegMultiSzLine HKLM, "SOFTWARE\Microsoft\AppV\Subsystem\VirtualRegistry", "PassThroughPaths", "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\WinSock2"

Sub AppendRegMultiSzLine(iHive, sKeyPath, sValueName, sLine)

	If oReg.GetMultiStringValue(iHive, sKeyPath, sValueName, aValues) <> 0 Then

		oReg.SetMultiStringValue iHive, sKeyPath, sValueName, Array(sLine)

	Else

		bWriteValue = True

		For Each sValue In aValues
			If UCase(sValue) = UCase(sLine) Then
				bWriteValue = False
			End If
		Next

		If bWriteValue Then
			ReDim Preserve aValues(UBound(aValues) + 1)
			aValues(UBound(aValues)) = sLine
			oReg.SetMultiStringValue iHive, sKeyPath, sValueName, aValues
		End If

	End If

End Sub

Sub RemoveRegMultiSzLine(iHive, sKeyPath, sValueName, sLine)

	If oReg.GetMultiStringValue(iHive, sKeyPath, sValueName, aValues) <> 0 Then Exit Sub

	bWriteValue = False
	i = 0

	For Each sValue In aValues
		If UCase(sValue) = UCase(sLine) Then
			bWriteValue = True
		Else
			ReDim Preserve aNewValues(i)
			aNewValues(i) = sValue
			i = i + 1
		End If
	Next

	If bWriteValue Then
		oReg.SetMultiStringValue iHive, sKeyPath, sValueName, aNewValues
	End If

End Sub
{% endhighlight %}

Then I added this to DeploymentConfig.xml under an AddPackage trigger:

{% highlight xml %}
<MachineScripts>
  <AddPackage>
    <Path>wscript.exe</Path>
    <Arguments>AddWinSock.vbs</Arguments>
    <Wait RollbackOnError="true" Timeout="30"/>
  </AddPackage>
</MachineScripts>
{% endhighlight %}

I did not add a RemovePackage equivalent to undo the change just in case there ended up being multiple apps requiring this fix then removing one could break the others. But if you want to implement it, the function to do so it right there in the vbscript. Changing this key affects all packages on the client however. So, unless you can find a package that contains and requires entries under the WinSock2 key, which I have not yet come across, then this should be safe to apply - but of course use this at your own risk!