---
title: "Date.ComponentsFormatStyle"
date: 2022-03-13T15:42:49-06:00
draft: false
aliases: [/posts/date-componentformatstyle/]
tags: [ios15, formatstyle, deepdive, development, swift, swiftui]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

This formatter gives you a localized string representation of the how much time has passed between the two dates. You can specify the units to display.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

```Swift
let testRange = Date(timeIntervalSince1970: 0)..<Date(timeIntervalSinceReferenceDate: 0)

testRange.formatted(.components(style: .abbreviated, fields: [.day])) 			// "11,323 days"
testRange.formatted(.components(style: .narrow, fields: [.day])) 				// "11,323days"
testRange.formatted(.components(style: .wide, fields: [.day])) 					// "11,323 days"
testRange.formatted(.components(style: .spellOut, fields: [.day])) 				// "eleven thousand three hundred twenty-three days"
testRange.formatted(.components(style: .condensedAbbreviated, fields: [.day]))  // "11,323d"
```

You have a few options available to you for the `fields:` parameter:

- day
- hour
- minute
- month
- second
- week
- year

You should include all of the `Field` types that you would like to possibly display. I say "possibly" here because there's no guarantee that the system will choose to show every field you specify. The documentation is non-existant online, but the header file says the following:

> ///   - fields: The fields to be included in the output string. Chosen automatically based on the interval being formatted if unspecified. Fields with 0 value are dropped.

Which explains the following:

```Swift
testRange.formatted(.components(style: .condensedAbbreviated, fields: [.day, .month, .year, .hour, .second, .week])) // "31y"
```

Since the difference between the days are exactly 31 years, we only see that unit displayed.

```Swift
let appleReferenceDay = Date(timeIntervalSinceReferenceDate: 0)
let twosday = Calendar(identifier: .gregorian).date(from: twosdayDateComponents)!
let secondRange = appleReferenceDay..<twosday

// "21 yrs, 1 mth, 3 wks, 9 hr, 1,342 sec"
secondRange.formatted(.components(style: .abbreviated, fields: [.day, .month, .year, .hour, .second, .week]))

// "21yrs 1mth 3wks 9hr 1,342sec"
secondRange.formatted(.components(style: .narrow, fields: [.day, .month, .year, .hour, .second, .week]))

// "21 years, 1 month, 3 weeks, 9 hours, 1,342 seconds"
secondRange.formatted(.components(style: .wide, fields: [.day, .month, .year, .hour, .second, .week]))

// "twenty-one years, one month, three weeks, nine hours, one thousand three hundred forty-two seconds"
secondRange.formatted(.components(style: .spellOut, fields: [.day, .month, .year, .hour, .second, .week]))

// "21y 1mo 3w 9h 1,342s"
secondRange.formatted(.components(style: .condensedAbbreviated, fields: [.day, .month, .year, .hour, .second, .week]))
```

Customizing the locale is as easy as adding the `.locale()` method at the end of the `.components` call:

```Swift
let franceLocale = Locale(identifier: "fr_FR")
// "vingt-et-un ans, un mois, trois semaines, neuf heures et mille trois cent quarante-deux secondes"
secondRange.formatted(.components(style: .spellOut, fields: [.day, .month, .year, .hour, .second, .week]).locale(franceLocale))
```

<hr>

## Further Customization

You can initialize and store an instance of the style for even further customization:

```Swift
let componentsFormat = Date.ComponentsFormatStyle(
    style: .wide,
    locale: Locale(identifier: "fr_FR"),
    calendar: Calendar(identifier: .gregorian),
    fields: [
        .day,
        .month,
        .year,
        .hour,
        .second,
        .week,
    ]
)

componentsFormat.format(secondRange)    // "21 ans, 1 mois, 3 semaines, 9 heures et 1 342 secondes"
secondRange.formatted(componentsFormat) // "21 ans, 1 mois, 3 semaines, 9 heures et 1 342 secondes"
```

And finally, combine it with a custom format style, and you get:

```Swift
struct InFrench: FormatStyle {
    typealias FormatInput = Range<Date>
    typealias FormatOutput = String

    static let componentsFormat = Date.ComponentsFormatStyle(
        style: .wide,
        locale: Locale(identifier: "fr_FR"),
        calendar: Calendar(identifier: .gregorian),
        fields: [
            .day,
            .month,
            .year,
            .hour,
            .second,
            .week,
        ]
    )

    func format(_ value: Range<Date>) -> String {
        InFrench.componentsFormat.format(value)
    }
}

extension FormatStyle where Self == InFrench {
    static var inFrench: InFrench { .init() }
}

secondRange.formatted(.inFrench) // "21 ans, 1 mois, 3 semaines, 9 heures et 1 342 secondes"
```

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>