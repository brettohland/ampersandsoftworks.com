---
title: "Estimote Beacons"
date: 2014-05-09T01:33:09+00:00
draft: false
tags: [ibeacons, development]
---

![](/images/2014/May/P5030551.jpg)

With some free time between projects at my previous job, I pre-ordered a set of Estimote Beacons to get some first-hand experience playing with our magical location aware future.

I ordered the beacons in October (I believe I was in the 2nd round of pre-orders) and they arrived on December 31st. Not too bad considering they were pre-release. The packaging was surprisingly nice, it even included a personalized note (with a corrected spelling mistake) asking for feedback.

Downloading their app I attempted to get the ranging features to work, no matter how many times I force closed, restarted the app, launched the app, cycled bluetooth I could not get the beacons to actually show up in the app. 

What ended up fixing the app was fully cycling the power on the phone. For some reason that seemed to restart whatever iBeacon background process that was needed to make it work. Hopefully that bit of info will help someone out there.

Inside of the Estimote App, you can tap on a beacon in the radar and read off some of the properties. My first bit of a shock was that all three of the beacons arrived reporting less that **30% battery power remaining**. After 5 months one is reporting 9%, one says 6% and one's completely drained.

![](/images/2014/May/P5030550.jpg)

[The Estimote site says](http://estimote.com/):

>Inside each beacon is a non-rechargeable lithium battery that should last up to 2 years depending on beacon configuration. Yes, the Bluetooth is really low energy. You don't have to worry about changing it, **because in two years time you'll probably get your hands on our new much more advanced Beacons**.

So… thanks? Definitely something to follow up with them on.

Otherwise the beacons are quite nice, they're weather sealed and definitely feel like a quality object and the gecko back will indeed stick anywhere.

Since the beacons follow the iBeacon standard you don't really need to install or use their SDK in order to start working with them, if you want to quickly get up and running you simply need the default UUID that each beacon is programmed with. I'll save you some Googling by just saying it's **B9407F30-F5F8-466E-AFF9-25556B57FE6D**. 

So are they worth it? Honestly if I would have known just how easy it was to get an iOS device broadcasting as a beacon I probably wouldn't have bothered picking up a set just to play around with. Unfortunately the battery issues are going to stop me from actually installing, using or recommending them to any fellow developers or clients.