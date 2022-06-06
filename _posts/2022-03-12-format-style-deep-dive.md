---
layout: post
title: FormatSyle Deep Dive
description: "Apple failed to document it, so I built a whole site for it: fuckingformatstyle.com"
date: 2022-03-12T09:44:41-07:00
tags: [ios15, formatstyle, development, swift, swiftui]
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

This deep-dive became so complex that I broke it out into its own site:

### [fuckingformatstyle.com](fuckingformatstyle.com)

or

### [goshdarnformatstyle.com](goshdarnformatstyle.com)

---

It's a single page, and includes much more detail than the previous posts.

## There's a quiz

In all of my research, the biggest hurdle I ran into was not knowing what I could even do with with these format styles.

[I built a quiz to help you discover exactly what you would want to do.](https://fuckingformatstyle.com/#how-do-i-even-know-where-to-start)

## There's an FAQ

[Encompassing the most common questions others have asked, and more.](https://fuckingformatstyle.com/#faq)

## Everything Else

I've attempted to break things out into their respective sections, for even easier use.

* [Minimum Requirements](https://fuckingformatstyle.com/#minimum-requirements)
* [The Basics](https://fuckingformatstyle.com/#the-basics)
* [Number Styles](https://fuckingformatstyle.com/#number-style)
    * [Percent Style](https://fuckingformatstyle.com/#percent-style)
    * [Currency Style](https://fuckingformatstyle.com/#currency-style)
* [Single Date Styles](https://fuckingformatstyle.com/#date-and-time-single-date)
    * [Date and Time Style](https://fuckingformatstyle.com/#date-and-time-single-date)
    * [dateTime Style](https://fuckingformatstyle.com/#datetime-compositing-single-date)
    * [ISO 8601 Style](https://fuckingformatstyle.com/#iso-8601-date-style-single-date)
    * [Relative Date Style](https://fuckingformatstyle.com/#relative-date-style-single-date)
    * [Verbatim Style](https://fuckingformatstyle.com/#verbatim-date-style-single-date)
* [Date Range Styles](https://fuckingformatstyle.com/#interval-date-style-date-range)
    * [Interval Style](https://fuckingformatstyle.com/#interval-date-style-date-range)
    * [Components Style](https://fuckingformatstyle.com/#datetime-compositing-single-date)
* [Measurement Style](https://fuckingformatstyle.com/#measurement-style)
* [List Style](https://fuckingformatstyle.com/#list-style)
* [Person Name Style](https://fuckingformatstyle.com/#person-name-component-style)
* [Byte Count Style](https://fuckingformatstyle.com/#byte-count-style)
* [Custom FormatStyle](https://fuckingformatstyle.com/#custom-format-style)
* [SwiftUI Integration](https://fuckingformatstyle.com/#swiftui-integration)
* [AttributedString Output](https://fuckingformatstyle.com/#attributed-string-output)

## Downloads

- [Xcode Playground](https://github.com/brettohland/FormatStylesDeepDive)
- [Everything as a Gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)