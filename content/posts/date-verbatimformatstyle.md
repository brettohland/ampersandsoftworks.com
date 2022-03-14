---
title: "Date.VerbatimFormatStyle"
date: 2022-03-13T09:38:45-06:00
draft: false
tags: [ios15, formatstyle, deepdive]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

The `Date.VerbatimFormatStyle` outputs a date string that bypasses the locale on your device. You use a special format string to composite a date out of parts, and can specify the calendar and time zone for the display.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

> Sidenote: The VerbatimFormatStyle is a strange one. As of this writing, [the apple docs are empty](https://developer.apple.com/documentation/foundation/formatstyle) and the headers contain the following line: "Formats a `Date` using the given format."

> What cracked the code is a [post on the Swift Evolution Forums](https://forums.swift.org/t/new-date-formatstyle-anyway-to-do-24-hour/52994/34) about outputting 24 hour time using the new `FormatStyle`

There's no extension on `FormatStyle` that lets you quickly access a VerbatimFormatStyle instance. You're stuck creating a new instance and Extending `FormatStyle` yourself.

```Swift
let twosdayDateComponents = DateComponents(
    year: 2022,
    month: 2,
    day: 22,
    hour: 2,
    minute: 22,
    second: 22,
    nanosecond: 22
)
let twosday = Calendar(identifier: .gregorian).date(from: twosdayDateComponents)!

let verbatim = Date.VerbatimFormatStyle(
    format: "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .oneBased)):\(minute: .twoDigits)",
    timeZone: TimeZone.current,
    calendar: .current
)
verbatim.format(twosday) // "02:22"
```

The `format` property on the init method is of type `Date.FormatString`, this uses the string interpolation system under the hood. You have access to all of the date `Date.FormatStyle.Symbol` values [used in the `Date.FormatStyle.datTime` style](/posts/date-and-formatstyle-and-you).

- `.day()` The numerical day of the month
- `.dayOfYear()` The numerical day of the year
- `.era()` The era (AD/BC in the gregorian calendar for example)
- `.minute()` The numerical minute
- `.month()` The month as a string
- `.quarter()` The quarter
- `.second()` The Numerical second
- `.timeZone()` The time zone
- `.week()` The numerical week of the month
- `.weekday()`The weekday as a string
- `.year()` The numerical year

Hours are different, there's a special `Date.FormatStyle.Symbol.VerbatimHour` type to represent the hour. It gives you the ability to display a 24 hour clock, instead of a 12 hour clock as well as zero pad the hours.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>