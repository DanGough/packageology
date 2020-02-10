---
title: Fixing File Permissions in App-V 5
slug: fixing-file-permissions-in-app-v-5
excerpt: How to grant your App-V 5 app to have full write permissions within the VFS.
date: '2013-06-22 15:11:09'
redirect_from: /2013/06/file-permissions-app-v-5/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

**UPDATE: Microsoft have now resolved these permissions issues in App-V 5.0 SP2 HF4:**
<br>
[http://support.microsoft.com/kb/2956985](http://support.microsoft.com/kb/2956985)
<br><br>
*There is still no solution if you need to write any of the restricted filetypes in the VFS however as discussed here:*
[http://www.virtualvibes.co.uk/cow-and-its-exclusions-in-app-v-5-0](http://www.virtualvibes.co.uk/cow-and-its-exclusions-in-app-v-5-0)
{: .notice--info}

Back in App-V 4, there was a very useful checkbox labelled **'Enforce Security Descriptors'**, which was checked by default. By default, it would prevent a standard user (or an admin user running without elevation) from writing to locations as C:\ProgramData, C:\Program Files and C:\Windows in the same way as a regular application. Since unticking this box would effectively make App-V ignore all of these permissions and allow users to write to these locations, it quickly became part many people's standards and templates to leave it unchecked. The benefits are that you spend less time debugging permission based issues for poorly written apps that try to write to these folders, and there are no drawbacks since all changes are redirected to the user's PKG file, leaving the system unharmed.

Now we have App-V 5 and things work rather differently and the 'Enforce Security Descriptors' checkbox is gone and standard users cannot write to any of the normally protected locations. The only exception is your Primary Virtual Application Directory chosen during sequencing time, which is fully writeable (except for certain file extensions such as .exe and .dll).

So far we have been given absolutely _no way_ by Microsoft how to fix this problem. Apparently Microsoft believe that most applications now adhere to their guidelines and do not try to write to such locations, and also that nobody is still using legacy apps these days. I found a [Technet forum post](http://social.technet.microsoft.com/Forums/en-US/865cfc31-12ee-4ea9-b630-16c05d711f54/appv-5-sequence-package-and-set-security-to-folder) discussing the problem and how to work around it, but none of the suggestions worked. Any permission changes to where the application files are stored under C:\ProgramData\AppV are ignored inside the virtual environment. You also cannot change the permissions from inside the bubble as a standard user. After investigation, I discovered that the ACLs for these folders are not simply inherited at runtime, they are copied and stored in the user profile, where they can be changed.

App-V 5 splits the user's sandbox for each application between two locations - folders that typically roam, such as **%APPDATA%**, get stored under **%APPDATA%\Microsoft\AppV\Client\VFS**. Any changes to non-roaming locations, such as **Program Files** are written to **%LOCALAPPDATA%\Microsoft\AppV\Client\VFS**. It is under _here_ that the App-V client creates all of the common restricted VFS folders that we are interested in, and it does this when the virtual environment for a particular application is launched for the first time. The folders are also emptied and the default permissions re-applied when the application is repaired.

[![LocalAppData VFS]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-22-file-permissions-app-v-5/LocalAppDataVFS.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-22-file-permissions-app-v-5/LocalAppDataVFS.png)

Example default permissions:

[![Permissions before]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-22-file-permissions-app-v-5/permissionsbefore.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-22-file-permissions-app-v-5/permissionsbefore.png)

If you change the permissions on those folders to grant the Users group modify permissions, standard users can then write to those locations in the virtual environment. One important thing to note is that you will need to ensure that the folder you want to write to is in the VFS of your package in the first place. There are a few points to be aware of before trying to solve this with a script to modify the permissions:

* The owner of each subfolder is set to the Administrators group and the Users group does not have full control; so standard users cannot adjust the permissions directly.
* They can however delete and recreate the folders, and the new folders will then inherit full write permissions.
* The folders do not exist at add / publish time to it's not possible to change them with a script running as local system. It may be possible to add them from scratch, but since a repair resets the folders, it's better to solve this with a script run within **StartVirtualEnvironment**.
* However when the virtual environment initialises, it creates these folders and applies those permissions to the VE before running any StartVirtualEnvironment scripts. Once the VE is running, changes to the permissions from the outside take no effect until the VE is shutdown and restarted. Therefore an application will not see any of the changes applied until it is launched a second time.

I have put together a script (designed to be run outside of the VE at StartVirtualEnvironment) that does the following:

* Checks to see if one of the VFS subfolders (APPV_ROOTS) has write access. The `-guid` switch is used to provide the package GUID.
* If it does, assume script has already run or is not required, and quit.
* If access is denied, the entire GUID subfolder is renamed, copied back to it's original name, then the old copy deleted.
* If the `-warn` switch is supplied, a popup box appears to warn the user that the permissions have been set, suggesting that they close and restart the application.
* If the `-error` switch is supplied the behaviour is similar to the above with a different message, and the script exits with an error code, which can be trapped by setting RollbackOnError=True in the xml where you define the script. Use this if the application will not work at all without the permissions being in place to prevent it launching the first time around. Unfortunately the App-V client displays some further nasty error messages when a script returns an error, I don't know if it's possible to suppress these yet.
* The `-name` parameter can be used to supply a friendly package name to show on the message box popups. If the user launched lots of apps at once or put them in their startup folder, they might not know where the error is coming from otherwise.

[Click here to download the script.]({{ site.url }}{{ site.baseurl }}/downloads/VFSCACLS.zip)

VFSCACLS.vbs v1.0.2:

{% highlight visualbasic %}
' Written by Dan Gough © 2013 Aceapp Solutions

Option Explicit
On Error Resume Next

Dim objShell, objFSO, args, i, bWarnOnChange, bErrorOnChange, PackageGUID, PackageName, VFSPath, objTempFile

bWarnOnChange = False
bErrorOnChange = False

Set args = Wscript.Arguments
If args.Count = 0 Then
	WScript.Echo "USAGE:" & vbCrLf & vbCrLf & "VFSCACLS.vbs -guid <PackageGUID> [-name <ApplicationName>] [-warn] [-error]" & vbCrLf & vbCrLf & _
	"-guid : Package GUID." & vbCrLf & vbCrLf &_
	"-name : Text to show on title bar of any popup message boxes displayed when using -warn or -error." & vbCrLf & vbCrLf &_
	"-warn : Shows a warning message to the user that they may need to restart the application if changes have been made." & vbCrLf & vbCrLf &_
	"-error : As above but also exits with an error code of 1 so that this can trigger a script rollback and prevent the app from being launched."
Else
	For i = 0 To args.Count - 1
  		If LCase(args(i)) = "-warn" Or LCase(args(i)) = "/warn" Then bWarnOnChange = True
  		If LCase(args(i)) = "-error" Or LCase(args(i)) = "/error" Then bErrorOnChange = True 
  		If LCase(args(i)) = "-guid" Or LCase(args(i)) = "/guid" Then 
  			If i < args.Count -1 Then
  				If Len(args(i+1)) = 36 Then PackageGUID = args(i+1)
  			End If
  		End If
  		If LCase(args(i)) = "-name" Or LCase(args(i)) = "/name" Then 
  			If i < args.Count -1 Then PackageName = args(i+1)
  		End If
	Next
End If

If PackageGUID = Empty Then
	WScript.Echo "ERROR: No package GUID specified or invalid value."
	WScript.Quit(1)
End If

Set objShell = WScript.CreateObject("WScript.Shell")
Set objFSO = WScript.CreateObject("Scripting.FileSystemObject")

VFSPath = objShell.RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Local AppData") & "\Microsoft\AppV\Client\VFS\" & PackageGUID
If Err.Number <> 0 Then
	WScript.Echo "ERROR: Unable to read registry key HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\Local AppData"
	WScript.Quit(2)
End If

If Not objFSO.FolderExists (VFSPath) Then
	WScript.Echo "ERROR: Unable to locate folder VFSPath"
	WScript.Quit(3)
End If

Set objTempFile = objFSO.CreateTextFile(VFSPath & "\APPV_ROOTS\_VFSCACLCS_TempFile.txt", True)
If Err.Number <> 0 Then
	objFSO.MoveFolder VFSPath, VFSPath & "_old"
	objFSO.CopyFolder VFSPath & "_old", VFSPath
	objFSO.DeleteFolder VFSPath & "_old", True
	If bWarnOnChange Then
		MsgBox "Folder permissions have been updated.  It is recommended that you close and restart the application.", 48, PackageName
	End If
	If bErrorOnChange Then
		MsgBox "Folder permissions have been updated.  Please ignore any errors that may follow and launch the application again.", 64, PackageName
		WScript.Quit(4)
	End If
Else
	objTempFile.Close
	objFSO.DeleteFile VFSPath & "\APPV_ROOTS\_VFSCACLCS_TempFile.txt", True
End If
{% endhighlight %}

You can add this script to the default Scripts directory from the Package Files tab of the sequencer. Then add the following to **DeploymentConfig.xml**:

{% highlight xml %}
<UserScripts>
	<StartVirtualEnvironment RunInVirtualEnvironment="false">
	<Path>wscript.exe</Path>
	<Arguments>VFSCACLS.vbs -guid XXX -name "My App" -warn</Arguments>
	<Wait RollbackOnError="false"/>
	</StartVirtualEnvironment>
</UserScripts>
{% endhighlight %}

The only mandatory parameter is `-guid`, which you can find from the very top of the xml file. If you want to make the script error on first launch to prevent the app from loading until the permissions are ready, simply change `-warn` to `-error` and set `RollbackOnError="true"`. After running this, all folder permissions inherit from the user's local appdata folder, which give System, Administrators and the owner (but not the entire Users group) write access:

[![Permissions after]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-22-file-permissions-app-v-5/permissionsafter.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2013-06-22-file-permissions-app-v-5/permissionsafter.png)

So please share this around and comment below if you've found it useful or have any issues or ideas for improvements!

