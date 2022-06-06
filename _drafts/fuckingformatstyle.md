---
layout: post
title: fucking format style, it's dot com.
description: Post-mortem on the creation of the site.
---

There's one aspect of being an iOS developer that I find frustrating, and that's spotty or missing documentation of first-party APIs.

When an API is announced or tied with a major OS release, you'll generally get some slides in a WWDC session about it and possibly an example project. If you're lucky, you might get some header documentation to help out in Xcode. And most likely, you're going to end up with nothing.

As time goes on, as the APIs mature or age, technical writers or developers inside of Apple will fill out the documentation. But in the mean time you're going to be making trips to Stack Overflow or posting and hoping that Quinn responds to your question on the Apple Developer forums.

This is the exact situation I was in with the Format Style protocol.

I had a unicorn project: My team was tasked with a ground-up rewrite of an internal scheduling app, and because we controlled the hardware we could target the latest iOS. So we dove in with a brand new project using iOS 15, SwiftUI, SceneDelegates, the works.

Because we were targeting the latest iOS, I ended up discovering the `.formatted()` on a data object. This lead me down the tumbling path of finding the `FormatStyle` protocol, and the various styles included with iOS 15.

Almost immediately, the lack of documentation reared it head at me and I quickly discovered that the easiest thing that I could do to discover what this API could do was to experiment in an Xcode Playground. Very quickly, this playground contained more information inside of it than any reference or documentation on the internet. In particular, I only really discovered what the Verbatim date style could do from one post on the Swift mailing list, and I didn't even know that the Person Name Components style existed.

Framing it as a reason to write up something on this blog, wrote up my experiences with some of the Date format styles and posted it online. The next thing that I knew, I was deep in Foundation's headers reading the public accessors on some truly obscure styles, and writing hundreds of lines of code with examples.

But even that wasn't enough.

I had a lot of great feedback about the series from other devs, and a lot of folks seemed to appreciate someone actually documenting what the system could do. But there were still holes in what I had discovered. There was even a bizarre crash in the `ByteCountFormatStyle` that even Apple has no idea about (feedback FB10031442). So about a month later, I scrapped a series of posts expanding on the origina deep-dive and launched a single serving site. https://fuckingformatstyle.com.





Being an iOS developer is always an interesting time. If you already have an app in the store, you generally want wait on requiring the latest OS until the majority of your users have installed it.

On top of this, there's the fact that Apple's track record of documentation is… spotty to say the least.




I ran into the `FormatStyle` protocol recently while developing an internal app for a client. The project is a unicorn, it's a new app that's targeting the latest version of the os (currently iOS 15).

I discovered the `FormatStyle` protocol, and was quite impressed by just how easy it was to quickly convert data into strings for display. All without having to deal with the shortcomings of the various (NS)Formatter subclasses.

I also quickly discovered that the documentation Apple provides is lacking in just about every way. Many of the included format styles are missing any formalized documentation on apple.com, some have header comments, while even more have none.

I set out to fix that.

Originally, this information was posted here as a series of posts, but I've since moved it to it's own site:
