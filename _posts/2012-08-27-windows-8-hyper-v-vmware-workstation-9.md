---
title: Windows 8 Hyper-V vs VMWare Workstation 9
slug: windows-8-hyper-v-vs-vmware-workstation-9
excerpt: Discussion and benchmarks on Hyper-V vs VMware Workstation for packagers.
date: '2012-08-27 23:47:18'
redirect_from: /2012/08/windows-8-hyper-v-vmware-workstation-9/
layout: single
classes: wide
categories:
  - Other
tags:
  - Hyper-V
  - VMWare
---

I recently upgraded my main desktop PC at home to the RTM version of Windows 8 and re-installed VMWare Workstation. All seemed well until I fired up a 4th VM and I began getting strange errors:

> The operation on file ****.vmdk failed.

After looking this error up it seems that it can occur not just with disk corruption but also when the host PC is running low on memory. My machine has 8GB RAM, VMWare was configured to use a maximum of 6GB and each VM had only 1GB assigned each, so I shouldn't have been getting any issues there! Luckily, VMWare Workstation 9 was released a few hours after I got this problem, and installing that seemed to fix it!

Anyway, after all this I remembered that Windows 8 now comes with **Hyper-V**, so I decided to give it a try to see if it could replace VMWare Workstation for my needs. After just installing a basic copy of Windows 7 inside a Hyper-V virtual machine, I noticed that it was ridiculously quick to start up and shutdown. I timed it at **9 seconds** to restart the machine from the login screen and back again, compared with around **18 seconds** in VMWare Workstation!

Intrigued by this, I decided to delve a little deeper using the PassMark peformance testing tool. In the summary below, Hyper-V RDC is where I connected to the VM via remote desktop, and VMC is where I used the Virtual Machine Connection window from the main Hyper-V management console. The test machine has a Core i7 860 with 8GB RAM and a 256GB Crucial M4 SATA-III SSD. Each virtual machine was set to use one processor, 1GB RAM, with a screen resolution of 1024x768.

[![Summary of results]({{ site.url }}{{ site.baseurl }}/assets/images/2012-08-27-windows-8-hyper-v-vmware-workstation-9/SUMMARY.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2012-08-27-windows-8-hyper-v-vmware-workstation-9/SUMMARY.png)

* CPU results don't vary much, with VMWare Workstation having a slight edge, but bear in mind I didn't perform multiple tests and average the results here so it could be insignificant.
* Hyper-V has better 2D graphics performance, except of course when using remote desktop which is to be expected.
* VMWare Workstation outperforms Hyper-V on the memory tests.
* Hyper-V *slays* VMWare Workstation when it comes to disk performance!

Here are the various test results in more detail:

[![2D results]({{ site.url }}{{ site.baseurl }}/assets/images/2012-08-27-windows-8-hyper-v-vmware-workstation-9/2D.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2012-08-27-windows-8-hyper-v-vmware-workstation-9/2D.png)

[![Memory results]({{ site.url }}{{ site.baseurl }}/assets/images/2012-08-27-windows-8-hyper-v-vmware-workstation-9/MEM.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2012-08-27-windows-8-hyper-v-vmware-workstation-9/MEM.png)

[![Disk results]({{ site.url }}{{ site.baseurl }}/assets/images/2012-08-27-windows-8-hyper-v-vmware-workstation-9/DISK.png)]({{ site.url }}{{ site.baseurl }}/assets/images/2012-08-27-windows-8-hyper-v-vmware-workstation-9/DISK.png)

This extra disk speed really comes in useful for the kinds of tasks I use a VM for - i.e. repackaging and sequencing applications, and building test environments. Hyper-V is what's known as a [Type 1 Hypervisor](http://en.wikipedia.org/wiki/Hypervisor), whilst VMWare Workstation is Type 2. Therefore Hyper-V should in theory have better performance when it comes to interfacing with the hardware. However, they are both writing to virtual disks via the host OS, so I wouldn't have thought that would explain the massive difference in disk performance. Perhaps VMWare just have a bit of catching up to do when it comes to optimising for the latest generation of SATA-III SSDs. Also it should be noted that I was using the brand new VHDX format for the virtual disk in Hyper-V. Well that's performance out of the way, but what about usability and features? I'll summarise them here:

* VMWare Workstation
    * Pros
        * The most popular desktop virtualisation software (in my experience) - good for sharing images with others.
        * All in-one window with tabs for each VM.
        * Guest VMs can automatically change resolution when resizing application window.
        * Drag & Drop, shared clipboard and USB device pass-through support between host and VM (although it's a bit iffy at times).
        * Better networking features - built in DHCP servers, NAT, etc
        * 3D hardware acceleration support.
        * Ability to create linked clones to preserve disk space.
        * Runs on machines that do not have SLAT capable CPUs.
    * Cons
        * Is not free (£169.50 in the UK).
        * Inferior disk performance.
        * If you want to share a VM so that another machine can connect directly to it through their copy of VMWare Workstation, you have to convert it to a shared machine first. However you cannot convert machines that have powered on snapshots or have linked clones created from them.
* Windows 8 Hyper-V
    * Pros
        * Comes free with Windows 8 Pro!
        * Superior disk performance (and 2D graphics as long as not using remote desktop).
        * Any other machine with the Hyper-V console installed (you can install it on Windows 7 also) can connect and manage the VMs (although this can be tricky to set up in non-domain environments, especially on Windows 8 as we'll see later).
        * Dynamic memory allocation - specify a min and max memory limit and Hyper-V will adjust each VM on the fly depending on workload. This will potentially allow you to run more VMs simultaneously than you could in VMWare.
        * Live Migration - you can move a VM from one disk to another *whilst it is still running*. For example, you could fire up a machine from a network share or external drive, then start copying it to your local drive, allowing you to get to work quicker.
    * Cons
        * Requires a CPU that supports SLAT. This includes most modern CPUs such as the Intel Core series (e.g. i3, i5, i7), but older processors will not be supported.
        * No 3D hardware acceleration. The PassMark 3D tests would not even run. Hyper-V on Windows Server 2012 includes RemoteFX to share the GPU with the VMs, but it seems Microsoft decided not to include it in the client OS.
        * No drag & drop, shared clipboard functionality, or USB device pass-through from the Hyper-V console. You can however get the clipboard and USB functionality back if you connect via remote desktop, at the cost of graphics performance.
        * No automatic desktop resizing or tabbed interface. However, you can connect via remote desktop and use [RDCMan](http://www.microsoft.com/en-us/download/details.aspx?id=21101 "Remote Desktop Connection Manager") to get this functionality (although you have to disconnect/reconnect for the resolution to adjust).
        * Although you can use differencing disks to create multiple VMs with minimal disk space, it's not as good as the linked clone functionality in VMWare, which lets you quickly create clones and still be able to use the original machine afterwards.
        * Virtual switch editor not as good as VMWare's virtual networking - you only have the choice of internal/external/private. Unlike VMWare, internal and private have no built in DHCP so you'll have to create your own DHCP server. There is no NAT option which allows VMs to be isolated from the outside network yet still get internet access (**EDIT:** There is now in Windows 10!).

Another point worthy of mention is that you cannot run VMWare Workstation when you have the Hyper-V Platform feature installed on Windows 8 (the Hyper-V Management Tools are allowed though). If you have both installed and want to fire up VMWare, you'll have to disable Hyper-V and reboot the machine first.

Back to something I mentioned earlier - remote access. I tried to configure my laptop with just the Hyper-V management tools installed to connect to the Hyper-V service on my desktop PC - both machines are in a Workgroup and using the new Microsoft accounts, a typical home setup. This should be a simple task, but unfortunately there's lots of configuration required, and I still had to resort to a bit of a hack to get it to work in Windows 8. You can use the tool [HVRemote](http://archive.msdn.microsoft.com/HVRemote) to configure the client and server, although it has not been updated for Windows 8. I followed the instructions on that page, but still had to manually add my user account to the Hyper-V Administrators group. Also, even though I am using the same Microsoft account and password on both Windows 8 machines, it would not authenticate when trying to connect. I had to create a local user on each machine, and run the Hyper-V console via the RunAs command on my client to get this to work. If anybody else can get it to work without this workaround please let me know!

In summary, If you already have a VMWare Workstation license, you may wish to continue using it - but it you don't, and you don't require 3D graphics acceleration, there is a compelling case to just use the Hyper-V instance that comes bundled with your shiny new OS instead!

**UPDATE: Real-world usage test** I decided to run a quick real-word usage scenario to compare how the two performed before making a decision which one to stick with. I tested how long it would take to copy the installation files for Office 2010 x86 to the desktop and install it:

* VMWare Workstation
    * Copy to desktop via drag'n'drop: **15s**
    * Install: **4m15s**
* Windows 8 Hyper-V
    * Copy to desktop via copy'n'paste in remote desktop: **1m33s**
    * Copy to desktop by accessing network share to local host: **8s**
    * Install: **4m45s**

Some more interesting results here then:

* Using copy'n'paste to transfer files via remote desktop (host and VM running on the same machine) is painfully slow.
* VMWare installed the application quicker than Hyper-V, despite Hyper-V outperforming it on the disk benchmarks.

These tests have proved that for me, it is not worth the hassle switching to Hyper-V at this time. If it supported 3D acceleration, automatic desktop resizing, drag'n'drop, shared clipboard, NAT and DHCP support in virtual networking, then Microsoft would have a contender, but I will be sticking with VMWare Workstation for now.