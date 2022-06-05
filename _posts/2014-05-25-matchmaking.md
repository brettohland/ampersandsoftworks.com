---
layout: post
title: "Matchmaking"
description: Thought on matchmaking in mobile games
date: 2014-05-25T02:49:27+00:00
draft: false
tags: ["thoughts"]
---

I've been thinking [a lot](http://hyperboleandahalf.blogspot.ca/2010/04/alot-is-better-than-you-at-everything.html) about matchmaking.

## An Example of Greatness

One of the better implementations of this is in the iOS game [Space Team](http://www.sleepingbeastgames.com/spaceteam/). Each step of the matchmaking process reinforces that you and your trusty group of friends/frienemies/co-workers need to work together… as a SpaceTeam.

![](/images/2014/May/spaceteam1.png)

Now, if I was dissecting the gameplay mechanics I would go into detail about how genius I think having a rotating knob as the start button. Simply: It's a great way to prime on the fact that you'll be using skeuomorphic controls.

![](/images/2014/May/spaceteam2.png)

Inevitably, there's always going to be at least one person who's [first](http://d2tq98mqfjyz2l.cloudfront.net/image_cache/1351284397483631.jpg). That person gets shown a "Searching for nearby signals" screen (This also shows you the weird alien that has been randomly generated for this play-through).

"Okay", you think. "This looks like I'm waiting on some other people here. I know (because I'm sitting in a group of people playing SpaceTeam) that I need to wait for at least one other of these people to join before we can play".

![](/images/2014/May/spaceteam3-1.png)

"Oh nice, here they are."
"Great, let's get started. I think I'll press this giant button."

![](/images/2014/May/spaceteam4-1.png)

"Oh! I only show the transmit-y thing when I hold down the button I guess that I need to hold it until they also hold it and the game knows we're both ready."

![](/images/2014/May/spaceteam5-1.png)

The interesting thing about this whole experience is that it's extremely discoverable. You understand that it's a lobby, you understand that one of the crew members must represent yourself, you understand that everyone needs to press and hold the [giant ass-button](http://xkcd.com/37/) in order to start the game off.

It also helps that the groups of people who play this game are all in a room (usually tipsy, in my experience) and can yell at each other to "HOLD THE READY BUTTON ALREADY I NEED TO CATH A BUS IN 20 MINUTES" (also in my own experience).

SpaceTeamwork!

It's a simple representation of the important tasks that need completion:

- We need to get all of the devices talking to each other.
- We need to limit the number of devices in a session.
- We need to get everyone to commit to playing.
- We need to know who's currently playing

You get a graphical representation of the devices being open for communication, you get shown who's already in the lobby, you can discover who you are by pressing the button and seeing which avatar responds, and you can ask around the table to see who everyone else is.

## So Now What?

I've been toying around with the idea of multi-peer networking for the Hot & Cold app.

The app is going to be a glorified, expensive and overly complicated game of Hide and Go Seek. I'd like the person using the hiding device to be shown how far the Seek device is. 

I could easily get this functionality by simply making both devices transmit as iBeacons (sharing the same UUID but with different major or minor values). Each would broadcast, each would receive and everything could/should work.

The issue comes down to the fact that with this simple implementation you could have an infinite number of Seek devices and an infinite number of Hide devices. If multiple Hide devices are broadcasting their beacons then finding individuals using the Seek devices gets nearly impossible.

Not an idea situation. So, easiest solution: Get a matchmaking service in place before we start our game of Hide and Go Seek.

My initial idea was to simply ape the SpaceTeam method of creating a lobby: locking it down after another person joins, randomly generate a major and minor number for both devices to use as identifiers, and then let them press and hold a button to signify when ready. Having people in the same physical location is a definite bonus here.

This is probably going to be my next dev step after verifying/writing the iBeacon setup in my prototype apps. It's quick and dirty, get's me writing against the multi-peer APIs and gets the app closer to my [minimum viable](http://haha-business.com/business.jpg) prototype.

If I want to expand this out a bit more I can envision a system where the matchmaking service pairs you up either randomly or with a selected person in a larger group of devices in multi-peer range. This might just add a lot of complexity for not a lot of gain for this project, we'll have to see.