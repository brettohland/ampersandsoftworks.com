---
title: "ListFormatStyle"
date: 2022-03-15T22:15:35-06:00
draft: false
tags: [ios15, formatstyle, deepdive]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

The `ListFormatStyle` is an interesting set of building blocks for outputting a string representation of an array of values.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

The `.list()` style has a `type` and `width` parameter which lets customize how the lists are displayed in plain language. Really, it only allows you to choose if the final item is denoted with a localized "and" or a localized "or".

```Swift
let letters = ["a", "b", "c", "d"]

letters.formatted() // "a, b, c, and d"

letters.formatted(.list(type: .and)) // "a, b, c, and d"
letters.formatted(.list(type: .or))  // "a, b, c, or d"

letters.formatted(.list(type: .and, width: .narrow))   // "a, b, c, d"
letters.formatted(.list(type: .and, width: .standard)) // "a, b, c, and d"
letters.formatted(.list(type: .and, width: .short))    // "a, b, c, & d"

letters.formatted(.list(type: .or, width: .narrow))   // "a, b, c, or d"
letters.formatted(.list(type: .or, width: .standard)) // "a, b, c, or d"
letters.formatted(.list(type: .or, width: .short))    // "a, b, c, or d"
```

You can also use the `.locale()` call to set the locale of the string output.

```Swift
let franceLocale = Locale(identifier: "fr_FR")

letters.formatted(.list(type: .and).locale(franceLocale)) // "a, b, c, et d"
letters.formatted(.list(type: .or).locale(franceLocale))  // "a, b, c, ou d"

letters.formatted(.list(type: .and, width: .narrow).locale(franceLocale))   // "a, b, c, d"
letters.formatted(.list(type: .and, width: .standard).locale(franceLocale)) // "a, b, c, et d"
letters.formatted(.list(type: .and, width: .short).locale(franceLocale))    // "a, b, c, et d"

letters.formatted(.list(type: .or, width: .narrow).locale(franceLocale))   // "a, b, c, ou d"
letters.formatted(.list(type: .or, width: .standard).locale(franceLocale)) // "a, b, c, ou d"
letters.formatted(.list(type: .or, width: .short).locale(franceLocale))    // "a, b, c, ou d"
```

The real power of the `ListStyleFormatter` is that you can use other `FormatStyle` functionality to fully customize the output of the data type that is contained in the list.

For example, if you have an array of dates:

```Swift
let importantDates = [
    Date(timeIntervalSinceReferenceDate: 0),
    Date(timeIntervalSince1970: 0)
]

let yearOnlyFormat = Date.FormatStyle.dateTime.year()

importantDates.formatted(.list(memberStyle: yearOnlyFormat, type: .and)) // "2000 and 1969"
importantDates.formatted(.list(memberStyle: yearOnlyFormat, type: .or))  // "2000 or 1969"

importantDates.formatted(.list(memberStyle: yearOnlyFormat, type: .and, width: .standard)) // "2000 and 1969"
importantDates.formatted(.list(memberStyle: yearOnlyFormat, type: .and, width: .narrow))   // "2000, 1969"
importantDates.formatted(.list(memberStyle: yearOnlyFormat, type: .and, width: .short))    // "2000 & 1969"

importantDates.formatted(.list(memberStyle: yearOnlyFormat, type: .or, width: .standard)) // "2000 or 1969"
importantDates.formatted(.list(memberStyle: yearOnlyFormat, type: .or, width: .narrow))   // "2000 or 1969"
importantDates.formatted(.list(memberStyle: yearOnlyFormat, type: .or, width: .short))    // "2000 or 1969"

```

The custom initializer for the ListStyleFormatter requires that you set the type of the member style formatter, as well as the type of data contained in the array.

```Swift
let yearStyle = ListFormatStyle<Date.FormatStyle, Array<Date>>.init(memberStyle: .dateTime.year())
importantDates.formatted(yearStyle)
```

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>