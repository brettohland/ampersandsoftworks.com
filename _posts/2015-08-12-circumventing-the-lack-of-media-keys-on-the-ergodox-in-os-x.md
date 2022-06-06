---
layout: post
title: Circumventing the Lack of Media Keys on the Ergodox
description: Using scripting to do things that should be easier.
date: 2015-08-12T15:19:26+00:00
draft: false
tags: ["Keyboards", "ErgoDox", "DIY"]
---

Massdrop is both a blessing and a curse. They've brought the Ergodox as close to the mainstream as they probably can (and you could say the [Ergodox EZ is bringing it the rest of the way](https://www.indiegogo.com/projects/ergodox-ez-an-incredible-mechanical-keyboard#/story)).

**Blessing**, because their [assembly instructions](https://keyboard-configurator.massdrop.com/ext/ergodox/assembly.php) and [layout configurator](https://keyboard-configurator.massdrop.com/ext/ergodox) have become the de-facto standards that everyone uses and follows.

**Curse**, because their [configurator is using old versions of the firmware](https://github.com/benblazak/ergodox-firmware/blob/master/readme.md) and there are pages dedicated to [addendums to their assembly instructions](http://studioidefix.com/2014/08/14/ergodox-soldering/).

Unless you want to [run a variant firmware](https://github.com/brettohland/tmk_keyboard) or make changes to the Massdrop standard, you aren't going to get media keys.

While I am a software dev by trade, the idea forking and branching an open source firmware (written in C) to make my own custom layout is not how I would currently like to spend my time. Add in the fact that there are literally hundreds upon hundreds of forks to both the TMK and Massdrop firmwares that have all sorts of different features, I just don't have the time to sift through and find the starting point I need.

So OS X level tweaking is the name of the game. My goals are fairly simple:

1. Play/Pause support.
1. Next Track Support
1. Screensaver hotkey*.

My tool of choice for these kinds of system wide hotkeys is Alfred. It's an extensible app launcher that I install on every mac I own. Even as Apple's Spotlight as added similar features, I continue to support and use it.

While you can most definitely control your music playback using Alfred and text shortcuts, there's nothing quite like hitting one key instead of one chord + a word.

To start, I needed to figure out where to add my keys. 

This is the layout that I ended up with ([download here](https://keyboard-configurator.massdrop.com/ext/ergodox/?referer=QSH9JM&hash=a3e2f279cb855d082134743f06792f53)):

![](/images/2015/Aug/layer0.png)

If you're a OS X user, you know that there is very little use for Function keys within various applications. Unlike Windows which binds things like refresh and rename to them, you can essentially set your keyboard to simply use Function keys as their special keys and never worry about it (Brightness, Mission Control, etc.).

I decided to piggyback on F7-F9 as my new keys.

Within Alfred, I simply created a new Workflow and assigned those keys to have the functionality I needed ([download here](https://www.dropbox.com/s/27jbehd9hg3um03/Ergodox%20bundle.alfredworkflow?dl=0)):

![](/images/2015/Aug/Workflow.png)

Simple. Now I have my functionality I need and I didn't have to put on my programming hat. Not saying that I won't in the future, but at least now I created a band-aid.

\* So why do I need a screensaver hotkey? [Goating](http://blog.codinghorror.com/dont-forget-to-lock-your-computer/), that's why. My co-workers are mean.