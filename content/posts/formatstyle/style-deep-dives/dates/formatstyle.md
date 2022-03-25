---
title: "Date.FormatStyle"
date: 2022-03-13T10:58:56-06:00
draft: false
aliases: [/posts/date-formatstyle/]
tags: [ios15, formatstyle, deepdive, development, swift, swiftui]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

Apple provides a convenience `.formatted` method on `Date` objects that allows you to customize the date and time styling within a few fixed enum values.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

## DateStyle & TimeStyle

The fixed enum vales available are:

``` Swift
.formatted(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle)
```

**DateStyle** ([Apple Documentation](https://developer.apple.com/documentation/foundation/date/formatstyle/datestyle))

- `.abbreviated` Abbreviates the month: `"Feb 22, 2022"`
- `.complete` Includes the long form of the weekday: `"Tuesday, February 22, 2022"`
- `.long`: Full month, omits weekday: `"February 22, 2022"`
- `.numeric` Numbers only `"2/22/2022"`
- `.omitted` Omits from display

**TimeStyle** ([Apple Documentation](https://developer.apple.com/documentation/foundation/date/formatstyle/timestyle))
- `.complete` The complete time with time zone: `"2:22:22 AM MST"`
- `.shortened` Hours and minutes only: `"2:22 AM"`
- `.standard` Hours, minutes, seconds, no time zone: `"2:22:22 AM"`
- `.omitted` Omits from display

You can mix and match the DateStyle and TimeStyle in any way that you'd like:

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

// MARK: DateStyle
twosday.formatted(date: .abbreviated, time: .omitted)   // "Feb 22, 2022"
twosday.formatted(date: .complete, time: .omitted)      // "Tuesday, February 22, 2022"
twosday.formatted(date: .long, time: .omitted)          // "February 22, 2022"
twosday.formatted(date: .numeric, time: .omitted)       // "2/22/2022"

// MARK: TimeStyle
twosday.formatted(date: .omitted, time: .complete)      // "2:22:22 AM MST"
twosday.formatted(date: .omitted, time: .shortened)     // "2:22 AM"
twosday.formatted(date: .omitted, time: .standard)      // "2:22:22 AM"

// MARK: - DateStyle & TimeStyle
twosday.formatted(date: .abbreviated, time: .complete)  // "Feb 22, 2022, 2:22:22 AM MST"
twosday.formatted(date: .abbreviated, time: .shortened) // "Feb 22, 2022, 2:22 AM"
twosday.formatted(date: .abbreviated, time: .standard)  // "Feb 22, 2022, 2:22:22 AM"
twosday.formatted(date: .complete, time: .complete)     // "Tuesday, February 22, 2022, 2:22:22 AM MST"
twosday.formatted(date: .complete, time: .shortened)    // "Tuesday, February 22, 2022, 2:22 AM"
twosday.formatted(date: .complete, time: .standard)     // "Tuesday, February 22, 2022, 2:22:22 AM"
twosday.formatted(date: .long, time: .complete)         // "February 22, 2022, 2:22:22 AM MST"
twosday.formatted(date: .long, time: .shortened)        // "February 22, 2022, 2:22 AM"
twosday.formatted(date: .long, time: .standard)         // "February 22, 2022, 2:22:22 AM"
twosday.formatted(date: .numeric, time: .complete)      // "2/22/2022, 2:22:22 AM MST"
twosday.formatted(date: .numeric, time: .shortened)     // "2/22/2022, 2:22 AM"
twosday.formatted(date: .numeric, time: .standard)      // "2/22/2022, 2:22:22 AM"
```

> Note: There's no option to call the `.locale()` method here, as this convenience method was added to the `Date` object, and isn't using a `FormatStyle` instance. To customize the Locale, see below.

<hr>

# Using `Date.FormatStyle` Directly

In order to customize the locale, calendar, time zone, and capitalization of the String output. You can initialize and store an instance of the `Date.FormatStyle` struct:

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
let frenchHebrew = Date.FormatStyle(
    date: .complete,
    time: .complete,
    locale: Locale(identifier: "fr_FR"),
    calendar: Calendar(identifier: .hebrew),
    timeZone: TimeZone(secondsFromGMT: 0)!,
    capitalizationContext: .standalone
)

twosday.formatted(frenchHebrew) // "Mardi 22 février 2022 ap. J.-C. 9:22:22 UTC"
frenchHebrew.format(twosday) // "Mardi 22 février 2022 ap. J.-C. 9:22:22 UTC"
```

You can either pass this new custom style into the `.formatted()` method on the date object _OR_ pass the date object into the style using the `.format()` method.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>