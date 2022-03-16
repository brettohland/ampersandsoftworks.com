---
title: "Date & FormatStyle & You"
date: 2022-03-11T06:53:13-07:00
draft: false
url: /posts/formatstyle-deep-dive/date-and-formatstyle-and-you/
aliases: [/posts/date-and-formatstyle-and-you/]
tags: [ios15, formatstyle, deepdive, development, swift, swiftui]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

Apple provides seven different `FormatStyle` variants that covers an impressive array of use cases for date formatting. 

At it's most basic, calling the `.formatted()` on any `Date` object will show you a basic representation: 

```Swift
Date(timeIntervalSinceReferenceDate: 0).formatted() // "12/31/2000, 5:00 PM"
```

> Sidenote: The default is identical to calling `.formatted(date: .numeric, time: .shortened)`

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

## [Date.FormatStyle](/posts/formatstyle/style-deep-dives/dates/formatstyle/)

Allows us to customize the DateStyle, TimeStyle, Locale and Calendar to display the date in fixed ways. Apple provides a shortcut to this struct when you use the `.formatted(date: time:)` method on the Date object..

```Swift
twosday.formatted(date: .complete, time: .complete) // "Tuesday, February 22, 2022, 2:22:22 AM MST"
```

[See more details here](/posts/formatstyle/style-deep-dives/dates/formatstyle/)

<hr>

## [Date.FormatStyle.dateTime()](/posts/formatstyle/style-deep-dives/dates/datetime/)

Allows you to specify the exact date components you would like to output. Furthermore, these components can be individually configured for maximum flexability.

```Swift
twosday.formatted(.dateTime.year().month().day().hour().minute().second()) // "Feb 22, 2022, 2:22:22 AM"
````

[See more details here](/posts/formatstyle/style-deep-dives/dates/datetime/)

<hr>

## [Date.ISO8601FormatStyle](/posts/formatstyle/style-deep-dives/dates/iso8601/)

Allows you to create strings that conform to the ISO 8601 date standard by calling `.formatted(.iso8601)` on any date object.  You can further customize a few options on the output, as well as the ability to set the locale, calendar, and time zone.

```Swift
isoFormat.format(twosday) // "2022-02-22T09:22:22.000Z"
```

[See more details here](/posts/formatstyle/style-deep-dives/dates/iso8601/)

<hr>

## [Date.ComponentsFormatStyle](/posts/formatstyle/style-deep-dives/dates/components/)

Allows you to show the number of years, months, weeks, days, hours, minutes, and seconds that have passed between a range of Date objects. It's customizable as to what units you show, and can further be customized with the locale and calendar.

```Swift
// "21 yrs, 1 mth, 3 wks, 9 hr, 1,342 sec"
secondRange.formatted(.components(style: .abbreviated, fields: [.day, .month, .year, .hour, .second, .week]))
```

[See more details here](/posts/formatstyle/style-deep-dives/dates/components/)

<hr>

## [Date.IntervalFormatStyle](/posts/formatstyle/style-deep-dives/dates/interval/)

Given a range of Date objects, you can display simply the earliest and latest dates as a string by calling the `.formatted(.interval)` method on a Date object. You can further customize the locale, calendar, and time zone of the display.

```Swift
range.formatted(.interval) // "12/31/69, 5:00 PM – 12/31/00, 5:47 PM"
```

[See more details here](/posts/formatstyle/style-deep-dives/dates/interval/)

<hr>

## [Date.RelativeFormatStyle](/posts/formatstyle/style-deep-dives/dates/relative/)

When called on a date, it outputs a plain language string of the distance between that date and now e.g. "2 weeks ago" by calling the `.formatted(.relative(presentation: unitsStyle:))` extension on `FormatStyle`.

```Swift
thePast.formatted(.relative(presentation: .numeric)) // "2 weeks ago"
````

[See more details here](/posts/formatstyle/style-deep-dives/dates/relative/)

<hr>

## [Date.VerbatimFormatStyle](/posts/formatstyle/style-deep-dives/dates/verbatim/)

The only FormatStyle that isn't localized. The `Date.VerbatimFormatStyle` lets you specify the individual components you'd like to display, as well as the calendar and time zone.

[See more details here](/posts/formatstyle/style-deep-dives/dates/verbatim/)

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>