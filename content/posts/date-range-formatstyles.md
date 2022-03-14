---
title: "Date Range Formatstyles"
date: 2022-03-12T15:24:17-07:00
draft: false
tags: [ios15, formatstyle, deepdive]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

Swift ranges that contain dates have two different options of formatters: `Date.ComponentsFormatStyle` and `Date.IntervalFormatStyle`.

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e)

<hr>

# Date.IntervalFormatStyle

The `Date.IntervalFormatStyle` displays the the lower and upper bounds of the date range.

```Swift
let range = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSinceReferenceDate: 2837)

range.formatted(.interval) // "12/31/69, 5:00 PM – 12/31/00, 5:47 PM"
```

The initializer on the Date.IntervalFormatStyle allows you to customize the date and time format, as well as the locale, calendar, and time zone:

```Swift
let interval = Date.IntervalFormatStyle(
    date: .abbreviated,
    time: .shortened,
    locale: Locale(identifier: "en_US"),
    calendar: Calendar(identifier: .gregorian),
    timeZone: TimeZone(secondsFromGMT: 0)!
)

interval.format(range)    // "Jan 1, 1970, 12:00 AM – Jan 1, 2001, 12:47 AM"
range.formatted(interval) // "Jan 1, 1970, 12:00 AM – Jan 1, 2001, 12:47 AM"
```

To create a fully custom extension onto FormatStyle:

```Swift
struct NarrowIntervalStyle: FormatStyle {
    typealias FormatInput = Range<Date>
    typealias FormatOutput = String

    static let interval = Date.IntervalFormatStyle(
        date: .abbreviated,
        time: .shortened,
        locale: Locale(identifier: "en_US"),
        calendar: Calendar(identifier: .gregorian),
        timeZone: TimeZone(secondsFromGMT: 0)!
    )

    func format(_ value: Range<Date>) -> String {
        NarrowIntervalStyle.interval.format(value)
    }
}

extension FormatStyle where Self == NarrowIntervalStyle {
    static var narrowInterval: NarrowIntervalStyle { .init() }
}

range.formatted(.narrowInterval)
````
