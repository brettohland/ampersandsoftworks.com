---
layout: post
title: FormatSyle Deep Dive
description: "Apple failed to document it, so I built a whole site for it: fuckingformatstyle.com"
date: 2022-03-12T09:44:41-07:00
tags: [ios, formatstyle, development, swift, swiftui, formatstyle]
redirect_from:
  - /posts/formatstyle-deep-dive/
  - /posts/formatstyle/style-deep-dives/dates/relative/
  - /posts/formatstyle-deep-dive/date-and-formatstyle-and-you/
  - /posts/formatstyle/style-deep-dives/attributed-strings/
  - /posts/formatstyle/swift-ui/
  - /posts/formatstyle/style-deep-dives/numerical/number/
  - /posts/formatstyle/style-deep-dives/numerical/percent/
  - /posts/formatstyle/style-deep-dives/numerical/currency/
  - /posts/formatstyle/numerical/
  - /posts/formatstyle/style-deep-dives/personnamecomponents/
  - /posts/formatstyle/style-deep-dives/listformatstyle/
  - /posts/formatstyle/style-deep-dives/bytecountformatstyle/
  - /posts/formatstyle/style-deep-dives/measurement/
  - /posts/formatstyle/style-deep-dives/dates/datetime/
  - /posts/formatstyle/style-deep-dives/dates/components/
  - /posts/formatstyle/style-deep-dives/dates/interval/
  - /posts/formatstyle/style-deep-dives/dates/formatstyle/
  - /posts/formatstyle/style-deep-dives/dates/verbatim/
  - /posts/formatstyle/style-deep-dives/dates/iso8601/


---

Hello there!

What started as a deep dive into Format Styles in iOS 15 and iOS 16 quickly outgrew a series of posts on a blog. In the grande tradition of [cuss including titled informational websites who have a singular goal](http://fuckingsyntaxsite.com). I present to you:

### [fuckingformatstyle.com](https://fuckingformatstyle.com)

or (for those needing less cussing in their life)

### [goshdarnformatstyle.com](https://goshdarnformatstyle.com)

---

It's a single page, and includes much more detail than the previous posts.

## There's a quiz

In all of my research, the biggest hurdle I ran into was not knowing what I could even do with with these format styles.

[I built a quiz to help you discover exactly what you would want to do.](https://fuckingformatstyle.com/#how-do-i-even-know-where-to-start)

## There's an FAQ

[Encompassing the most common questions others have asked, and more.](https://fuckingformatstyle.com/#faq)

## Everything Else

Everything has been organized by their use cases and includes styles available for use in both Xcode 13 and Xcode 14.

* [Minimum Requirements](https://fuckingformatstyle.com/#minimum-requirements)
* [The Basics](https://fuckingformatstyle.com/#the-basics)
* [Numeric Styles](https://fuckingformatstyle.com/numeric-styles)
    * [Number Style](https://fuckingformatstyle.com/numeric-styles/#number-style)
    * [Percent Style](https://fuckingformatstyle.com/numeric-styles/#percent-style)
    * [Currency Style](https://fuckingformatstyle.com/numeric-styles/#currency-style)
* [Single Date Styles](https://fuckingformatstyle.com/date-styles/)
    * [Compositing](https://fuckingformatstyle.com/date-styles/#compositing)
    * [Date and Time Style](https://fuckingformatstyle.com/date-styles/#date-and-time-single-date)
    * [ISO 8601 Style](https://fuckingformatstyle.com/date-styles/#iso-8601-date-style-single-date)
    * [Relative Date Style](https://fuckingformatstyle.com/date-styles/#relative-date-style-single-date)
    * [Verbatim Style](https://fuckingformatstyle.com/date-styles/#verbatim-date-style-single-date) (Updated for Xcode 14)
* [Date Range Styles](https://fuckingformatstyle.com/date-range-styles/)
    * [Interval Style](https://fuckingformatstyle.com/date-range-styles/#interval-date-style-date-range)
    * [Components Style](https://fuckingformatstyle.com/date-range-styles/#components-date-style-date-range)
* [Duration Styles](https://fuckingformatstyle.com/duration-styles/) (New for Xcode 14)
    * [Time Style](https://fuckingformatstyle.com/duration-styles/#time-style) (New for Xcode 14)
    * [Units Style](https://fuckingformatstyle.com/duration-styles/#units-style) (New for Xcode 14)
* [Measurement Style](https://fuckingformatstyle.com/measurement-style/)
* [List Style](https://fuckingformatstyle.com/list-style/)
* [Person Name Style](https://fuckingformatstyle.com/person-name-style/)
* [Byte Count Style](https://fuckingformatstyle.com/byte-count-style/) (Updated for Xcode 14)
* [URL Style](https://fuckingformatstyle.com/url-style/) (New in Xcode 14)
* [Custom FormatStyle](https://fuckingformatstyle.com/custom-styles/)
* [SwiftUI Integration](https://fuckingformatstyle.com/swiftui/)
* [AttributedString Output](https://fuckingformatstyle.com/attributed-string-output/)

## Downloads

- [Xcode Playground](https://github.com/brettohland/FormatStylesDeepDive)
- [Everything as a Gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)