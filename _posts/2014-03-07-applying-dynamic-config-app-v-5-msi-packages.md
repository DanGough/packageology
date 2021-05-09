﻿---
title: Applying Dynamic Config To App-V 5 MSI Packages
slug: applying-dynamic-config-to-app-v-5-msi-packages
excerpt: An MST to modify the MSI packages generated by the App-V sequencer so that they make use of the DeploymentConfig.xml files.
date: '2014-03-07 00:00:35'
redirect_from: /2014/03/applying-dynamic-config-app-v-5-msi-packages/
layout: single
classes: wide
categories:
  - App-V
tags:
  - App-V
---

**There is an updated version of this MST available from [this post]({% post_url 2016-08-14-fix-app-v-sequencer-generated-msi-packages %})**
{: .notice--warning}

The App-V sequencer produces an MSI package by default as part of its output. This is a wrapper that runs the necessary commands to publish and remove the virtual application. I first assumed that these would usually just be used for test purposes since most places would deploy the App-V native infrastructure or use SCCM, but it turns out a few customers I am working with are using these in a live environment, particularly those using Intune, which does not handle App-V packages natively.

A big limitation of these MSI packages however, is that they ignore the DeploymentConfig.xml files (the UserConfig.xml file is irrelevant since the MSI publishes the app globally to all users). This means that if you want to modify any package settings, or add some package scripts, then you need a separate process to import these custom configurations and re-publish the applications with Powershell commands. Most people I have encountered have opted to forget the App-V deployment and stick with a traditional MSI if such scripting is required, rather than face the hassle of managing this situation.

To solve this, I have created a generic MST transform that can be used when installing the MSI to automatically import the DeploymentConfig.xml file, and also optionally enable/disable package scripts. To use this, you would install like so:

`msiexec /i MyApp.msi /qn TRANSFORMS=ApplyDeploymentConfig.mst`

There are a couple of optional properties supported too. In the example above, it will assume that the DeploymentConfig.xml matches the default naming convention. If you have a custom file name however, you can supply it via the **DEPLOYMENTCONFIG** property:

`msiexec /i MyApp.msi /qn TRANSFORMS=ApplyDeploymentConfig.mst DEPLOYMENTCONFIG="C:\MyAppConfig.xml"`

Or:

`msiexec /i MyApp.msi /qn TRANSFORMS=ApplyDeploymentConfig.mst DEPLOYMENTCONFIG="MyAppConfig.xml"`

If no path is specified for the xml file, it assumes the same directory as the MSI package. Because you may typically supply a custom config file in order to use App-V scripting, you can also enable (or disable) package scripts with the **ENABLEPACKAGESCRIPTS** property. To enable scripts:

`msiexec /i MyApp.msi /qn TRANSFORMS=ApplyDeploymentConfig.mst ENABLEPACKAGESCRIPTS=1`

Or to disable scripts:

`msiexec /i MyApp.msi /qn TRANSFORMS=ApplyDeploymentConfig.mst ENABLEPACKAGESCRIPTS=0`

If this property is not supplied then the settings will not be modified.

**[Click here to download the transform](/Downloads/ApplyDeploymentConfig.zip)**

I have designed it to work with both 32-bit and 64-bit clients, but have only tested it on 64-bit. Leave comments below if you find any issues!