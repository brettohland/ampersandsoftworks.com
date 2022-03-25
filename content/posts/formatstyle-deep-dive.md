---
title: "FormatStyle Deep Dive"
date: 2022-03-12T09:44:41-07:00
draft: false
tags: [ios15, formatstyle, deepdive, development, swift, swiftui]
---

Apple introduced the new `FormatStyle` protocol with iOS 15. It allows for some truly remarkable things to happen when you're converting your data into localized strings. 

In true Apple fashion though, details about how to use these new features are lightly documented with few examples.

The breadth and depth that this new functionality has been added to Swift is really nice, Apple has added support for it on nearly all data types in Swift. You also have the ability to create custom `FormatStyle` implementations that allow you to arbitrarily convert types using this functionality.

To use this functionality in the past, you would have needed to create a new instance of the various `Formatter` subclasses on offer (`DateFormatter`, `NumberFormatter`, etc), configure it, and then use the instance to output our localized string. This came with the large gotcha that instantiating these formatters were expected, and you needed to know that you had to cache these somewhere in your app for quick reuse.

No more. According to Apple, the system is using these formatters under the hood and they're now handling the creation and cacheing of these objects for you.

As an added bonus, Apple has added built-in support to the `Text` view in SwiftUI to fully support every `FormatStyle` detailed in this deep dive.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

In this post:

- [The Basics](#the-basics)
	- [Sensible Defaults](#sendible-defaults)
- [Using System Provided Styles](#built-in-formatstyle)
	- [Using Custom Locales](#using-custom-locales)
	- [Using Custom Calendars](#using-custom-calendars)
- [Creating Custom FormatStyles](#creating-custom-formatstyles)
	- [Attributed String Output for Custom FormatStyles](#attributedsting-output-for-custom-formatstyles)

<hr>

Every Deep Dive:
- [SwiftUI Integration](/posts/formatstyle/swift-ui/)
- [Outputting AttributedStrings](/posts/formatstyle/style-deep-dives/attributed-strings)
- [Dates](/posts/formatstyle-deep-dive/date-and-formatstyle-and-you/)
	- [Date.FormatStyle](/posts/formatstyle/style-deep-dives/dates/formatstyle/)
	- [Date.FormatStyle.dateTime()](/posts/formatstyle/style-deep-dives/dates/datetime/)
	- [Date.ComponentsFormatStyle](/posts/formatstyle/style-deep-dives/dates/components/)
	- [Date.ISO8601FormatStyle](/posts/formatstyle/style-deep-dives/dates/iso8601/)
	- [Date.IntervalFormatStyle](/posts/formatstyle/style-deep-dives/dates/interval/)
	- [Date.RelativeFormatStyle](/posts/formatstyle/style-deep-dives/dates/relative/)
	- [Date.VerbatimFormatStyle](/posts/formatstyle/style-deep-dives/dates/verbatim/)
- [Measurements.FormatStyle](/posts/formatstyle/style-deep-dives/measurement/)
- [ByteCountFormatStyle](/posts/formatstyle/style-deep-dives/bytecountformatstyle/)
- [ListFormatStyle](/posts/formatstyle/style-deep-dives/listformatstyle/)
- [PersonNameComponents.FormatStyle](/posts/formatstyle/style-deep-dives/personnamecomponents/)
- [Numerical Formatters](/posts/formatstyle/numerical)
	- [Number](/posts/formatstyle/style-deep-dives/numerical/number/)
	- [Currency](/posts/formatstyle/style-deep-dives/numerical/currency/)
	- [Percent](/posts/formatstyle/style-deep-dives/numerical/currency/)

<hr>

# The Basics

You can access this new system in a few ways:

1. Call `.formatted()` on a data type for a sensible, localized default
2. Call `.formatted(_: FormatStyle)` on a data type and pass in a pre-defined or custom FormatStyle to customize your output
3. Call `.format()` on a custom FormatStyle and pass in a data value

## Sensible Defaults

At its most basic, calling `.formatted()` will give you a sensible default that uses your device's current locale and calendar to display the value.

```Swift
// Dates
Date(timeIntervalSinceReferenceDate: 0).formatted() // "12/31/2000, 5:00 PM"

// Measurements
Measurement(value: 20, unit: UnitDuration.minutes).formatted()     // "20 min"
Measurement(value: 300, unit: UnitLength.miles).formatted()        // "300 mi"
Measurement(value: 10, unit: UnitMass.kilograms).formatted()       // "22 lb"
Measurement(value: 100, unit: UnitTemperature.celsius).formatted() // "212°F"

// Numbers
32.formatted()               // "32"
Decimal(20.0).formatted()    // "20"
Float(10.0).formatted()      // "10"
Int(2).formatted()           // "2"
Double(100.0003).formatted() // "100.0003"

// Names
PersonNameComponents(givenName: "Johnny", familyName: "Appleseed").formatted() // "Johnny Appleseed"

// Lists
["Alba", "Bruce", "Carol", "Billson"].formatted() // "Alba, Bruce, Carol, and Billson"

// TimeInterval
let referenceDay = Date(timeIntervalSinceReferenceDate: 0)
(referenceDay ..< referenceDay.addingTimeInterval(200)).formatted() // "12/31/00, 5:00 – 5:03 PM"

```

> Note: My system is using the "en_US" locale, and the Gregorian calendar.

In general, these are useful to quickly convert your values into strings.

<hr>

# Built-In Styles

For every data type that's supported by the new system, Apple has provided ways to customize your string output in many different ways. The most granular customizations will use the device's locale and calendar, while a smaller subset will let you set them specifically.

Here are the deep-dives for each of the types, and their various customization options.

- [Dates](/posts/formatstyle-deep-dive/date-and-formatstyle-and-you/)
	- [Date.FormatStyle](/posts/formatstyle/style-deep-dives/dates/formatstyle/)
	- [Date.FormatStyle.dateTime()](/posts/formatstyle/style-deep-dives/dates/datetime/)
	- [Date.ComponentsFormatStyle](/posts/formatstyle/style-deep-dives/dates/components/)
	- [Date.ISO8601FormatStyle](/posts/formatstyle/style-deep-dives/dates/iso8601/)
	- [Date.IntervalFormatStyle](/posts/formatstyle/style-deep-dives/dates/interval/)
	- [Date.RelativeFormatStyle](/posts/formatstyle/style-deep-dives/dates/relative/)
	- [Date.VerbatimFormatStyle](/posts/formatstyle/style-deep-dives/dates/verbatim/)
- [Measurements.FormatStyle](/posts/formatstyle/style-deep-dives/measurement/)
- [ByteCountFormatStyle](/posts/formatstyle/style-deep-dives/bytecountformatstyle/)
- [ListFormatStyle](/posts/formatstyle/style-deep-dives/listformatstyle/)
- [PersonNameComponents.FormatStyle](/posts/formatstyle/style-deep-dives/personnamecomponents/)
- [Numerical Formatters](/posts/formatstyle/numerical)
	- [Number](/posts/formatstyle/style-deep-dives/numerical/number/)
	- [Currency](/posts/formatstyle/style-deep-dives/numerical/currency/)
	- [Percent](/posts/formatstyle/style-deep-dives/numerical/currency/)
- [SwiftUI Integration](/posts/formatstyle/swift-ui/)

<hr>

## Using Custom Locales

Any object or struct that conforms to the `FormatStyle` protocol inherits the `.locale()` instance method that lets you set the locale for an individual `.formatted()` call:

```Swift
let thePast = Calendar(identifier: .gregorian).date(byAdding: .day, value: -14, to: Date())!

thePast.formatted(.relative(presentation: .numeric)) // "2 weeks ago"

let franceLocale = Locale(identifier: "fr_FR")

thePast.formatted(.relative(presentation: .numeric).locale(franceLocale)) // "il y a 2 semaines"

```

## Using Custom Calendars

If you're needing to set the calendar for display, you're going to need to initialize a new instance of your chosen `FormatStyle`. In all cases, the built-in styles have the ability to customize various aspects of the formatter, including the calendar.

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

<hr>

# Creating Custom FormatStyles

The `FormatStyle` protocol is very broad, it's defined as the following:

```Swift
/// A type that can convert a given data type into a representation.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public protocol FormatStyle : Decodable, Encodable, Hashable {

    /// The type of data to format.
    associatedtype FormatInput

    /// The type of the formatted data.
    associatedtype FormatOutput

    /// Creates a `FormatOutput` instance from `value`.
    func format(_ value: Self.FormatInput) -> Self.FormatOutput

    /// If the format allows selecting a locale, returns a copy of this format with the new locale set. Default implementation returns an unmodified self.
    func locale(_ locale: Locale) -> Self
}
```

In practice, you define your input and output types, and implement the formatting within the `format(_ value:)` method.

```Swift
struct ToYen: FormatStyle {
    typealias FormatInput = Int
    typealias FormatOutput = String

    func format(_ value: Int) -> String {
        Decimal(value * 100).formatted(.currency(code: "jpy"))
    }
}

30.formatted(ToYen()) // "¥3,000"
```

You can follow Apple's lead, and further extend the `FormatStyle` to allow you to quickly and easily call your new style:

```Swift
extension FormatStyle where Self == ToYen {
    static var toYen: ToYen { .init() }
}

30.formatted(.toYen) // "¥3,000"
```

## AttributedSting Output for Custom FormatStyles

You can easily add `AttributedString` support to custom `FormatStyle` implementations by creating a new `FormatStyle` who's `FormatOutput` type is `AttributedString` and not `String`.

[See more details in the Attributed String Deep Dive](/posts/formatstyle/style-deep-dives/attributed-strings/#adding-attirbutedstring-output-to-custom-format-styles) 

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>
