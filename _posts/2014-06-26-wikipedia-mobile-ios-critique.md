---
layout: post
title: "Wikipedia Mobile iOS Critique"
description: A deep-dive
date: 2014-06-26T16:40:20+00:00
draft: false
tags: ["critique", "thoughts"]
---

I've used a couple of different iOS Wikipedia readers over the years (most notably [Articles](http://sophiestication.com/articles/) and [Wikipanion](http://www.wikipanion.net/)), but I hadn't spent much time using the official Wikipedia Mobile app.

Doing a small bit of research, it looks like the official app was released in [April of 2012](http://blog.wikimedia.org/2012/04/05/new-wikipedia-app-for-ios-and-an-update-for-our-android-app/) and updated last in April of 2013.  

All around the current Wikipedia Mobile App is well built. It nails the core functionality of finding and reading content but ultimately looks dated and has some odd design choices.

### Overview

Initially, the app itself seems to be a hybrid application.  The functionality is solid but there are non-standard controls scattered throughout (the title bar menus are a dead give-away)

The launch blog post confirmed that the app was built using Cordova and PhoneGap, and 2012 was the height of when hybrid apps were considered the ultimate strategy for cross-platform development.  

LinkedIn was probably the [biggest supporter](http://venturebeat.com/2012/05/02/linkedin-ipad-app-engineering/) of this strategy back in 2012. It came as a big shock when they moved  over to native applications [just a year later](http://venturebeat.com/2013/04/17/linkedin-mobile-web-breakup/) citing issues with running out of memory in-app.

Wikipedia Mobile is in need of a native rewrite. And if job postings are any indication, they're looking to hire some iOS devs to make it happen.

### The App Itself

Since ["Content is King"](http://en.wikipedia.org/wiki/Web_content#Content_is_king) and Wikipedia's content is among the most vast and unique in the world, the current mobile app does this job very well.

Other things done well:

- Search is prominent (although the search box needs more left padding). 
- The content is well presented using Wikipedia's mobile look and feel. 
- Links to related articles are obvious and discoverable and back/forward functionality is obvious.

Some things that could be better:

- The "W" button that's a part of the search box gets accidentally hit many times. It's an unintuative button.
- I would question the inclusion of a language selector in the bottom tab bar. Do people change languages that often?
- The bookmark icon opens up an action sheet to access the nearby, saved pages and history. The iconography is unclear.
- The tab bars are non iOS standard. On iOS the back button is labeled either 'back' or the name of the previous view controller title. In this app, the back button is seemingly labelled with the current view title.
- No gestures are implemented, the iOS standard 'swipe to go back' functionality isn't implemented.
- The app is very obviously iOS 6. The design should be updated to reflect iOS 7 conventions.
- The 'Contact Us' link is broken.

### An Awesome Future

The app needs a re-write to bring it up to modern standards. With the impending release of iOS 8 the app will look more and more dated as time goes by.

The upcoming WKWebView framework in iOS 8 will (finally) allow for full speed rendering of all web content. This could help immensely for large pages.

A interesting idea for the future might be an app aimed specifically at Wikipedia Editors. An app that allows you to view edits on watched pages, includes edit functionality as well as ways of getting involved in discussions could be a great tool.