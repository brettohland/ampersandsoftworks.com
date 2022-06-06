---
layout: post
title: "Hot/Cold - Oh Look: A Repo."
date: 2014-04-13T14:20:07+00:00
draft: false
tags: ["multipeer", "hotcold"]
---

![](/images/2014/Apr/Aliens-Motion-Tracker.png)

I decided this morning that there's really nothing wrong in posting the source of the app up on GitHub for the time being. Really, it's in the middle of heavy development and I've never really developed anything in the open before. What's the point of keeping a dev blog if I can't reference chunks of code?

[The repo has been created](https://github.com/brettohland/HotCold/)

Another thing that might be interesting is that I think I'll be linking directly to specific commits in order to give a bit of historical context to certain posts. Not sure if I'll keep doing this but it seems like an interesting idea.

[It's that awkward first set of check-ins](https://github.com/brettohland/HotCold/tree/91d668b25616b0668f14d7ceb3264a4364d94d0b)

[Mattt over at NSHipster had a great post on Multi-peer connectivity](http://nshipster.com/multipeer-connectivity/) that really make me interested in making this application communicate both ways. The `seeker` would only get **"HOT"** or **"COLD"** verbal commands but the Hider could get a distance measurement.

Taking it the next step you could even have multiple Seekers looking for one Hider and all of their distance measurements could be displayed (Or just show the  motion tracker from the movie Alien to really freak them out).
