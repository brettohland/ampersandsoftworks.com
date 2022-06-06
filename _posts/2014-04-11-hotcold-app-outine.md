---
layout: post
title: "App #1: 'Hot/Cold' App Outline"
description: The first and simplest app idea that's been rolling around my brain uses iBeacons.
date: 2014-04-11T03:38:10+00:00
draft: false
tags: ["multipeer", "hotcold"]
---

The first and simplest app idea that's been rolling around my brain uses iBeacons. I attended a couple of sessions at WWDC 2014 about them and have been really interested in playing around with them ever since.

So here's the app idea (it's kind of a joke): You have two iOS devices. One is the 'hide' and one is the 'seek'. The 'seek' device does nothing but yell **HOT! HOT! HOT! COLD! COLD!** as you get closer or further… I didn't say it was a good idea, just that it was *an* idea.

([IAP](http://en.wikipedia.org/wiki/In-app_purchase) idea: Novelty voices?)

Getting the 'seek' app up and running should be pretty trivial, Apple has their [Air Locate](https://developer.apple.com/library/ios/samplecode/AirLocate/Introduction/Intro.html) app that shows just how simple it is to listen for iBeacon signals. The neat thing is that with one UUID there could be multiple people/apps looking for one 'hide' app instance.

On the 'seek' side of things it gets a bit more interesting. The idea for the app would be for two kids to be using them to have a kind of nerdy hide and go seek game. I was thinking that the hide app could say some funny things or give updated information on how far the seek app(s) are away from you. Since iBeacons are supposed to be a one way communication path (broadcast only) that would mean that I would need to look into being both a iBeacon broadcaster as well as an iBeacon receiver. Is that possible? I guess we'll see.

Step one's going to be just getting the application scaffolding up and running and starting with a basic 'one is hide and one is seek' prototype.