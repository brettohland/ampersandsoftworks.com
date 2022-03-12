---
title: "Formatstyle Relative Dates"
date: 2022-03-12T09:36:33-07:00
draft: false
tags: [ios15, formatstyle, deepdive]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

Displaying relative dates in a localized fashion is fiendishly complex when you sit and think about it. Apple providing it to us developers in such a simple package is a lifeline.

[Read the full deep dive on Date.DateStyle](/posts/date-and-formatstyle-and-you)

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e#file-relative-dates-swift)

[Apple Docs for RelativeFormatStyle](https://developer.apple.com/documentation/foundation/date/relativeformatstyle)

```Swift
let thePast = Calendar(identifier: .gregorian).date(byAdding: .day, value: -14, to: Date())!

// MARK: - Without Units
thePast.formatted(.relative(presentation: .numeric)) // "2 weeks ago"
thePast.formatted(.relative(presentation: .named))   // "2 weeks ago"

// MARK: - Including Units
thePast.formatted(.relative(presentation: .numeric, unitsStyle: .abbreviated)) // "2 wk. ago"
thePast.formatted(.relative(presentation: .numeric, unitsStyle: .narrow))      // "2 wk. ago"
thePast.formatted(.relative(presentation: .numeric, unitsStyle: .spellOut))    // "two weeks ago"
thePast.formatted(.relative(presentation: .numeric, unitsStyle: .wide))        // "2 weeks ago"
thePast.formatted(.relative(presentation: .named, unitsStyle: .abbreviated))   // "2 wk. ago"
thePast.formatted(.relative(presentation: .named, unitsStyle: .narrow))        // "2 wk. ago"
thePast.formatted(.relative(presentation: .named, unitsStyle: .spellOut))      // "two weeks ago"
thePast.formatted(.relative(presentation: .named, unitsStyle: .wide))          // "2 weeks ago"
```

By creating an instance of `Date.RelativeFormatStyle`, you can additionally customize the locale, calendar and capitalization context of the style.

```Swift
// MARK: - Custom RelativeFormatStyle
let relativeInFrench = Date.RelativeFormatStyle(
    presentation: .named,
    unitsStyle: .spellOut,
    locale: Locale(identifier: "fr_FR"),
    calendar: Calendar(identifier: .gregorian),
    capitalizationContext: .beginningOfSentence
)

thePast.formatted(relativeInFrench) // "Il y a deux semaines"
relativeInFrench.format(thePast) // "Il y a deux semaines"
```

And finally, you can wrap the custom RelativeFormatStyle in a FormatStyle extension for easier access:

```Swift
struct InFrench: FormatStyle {
    typealias FormatInput = Date
    typealias FormatOutput = String

    static let relativeInFrench = Date.RelativeFormatStyle(
        presentation: .named,
        unitsStyle: .spellOut,
        locale: Locale(identifier: "fr_FR"),
        calendar: Calendar(identifier: .gregorian),
        capitalizationContext: .beginningOfSentence
    )

    func format(_ value: Date) -> String {
        InFrench.relativeInFrench.format(value)
    }
}

extension FormatStyle where Self == InFrench {
    static var inFrench: InFrench { .init() }
}

thePast.formatted(.inFrench) // "Il y a deux semaines"
```

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e#file-relative-dates-swift)