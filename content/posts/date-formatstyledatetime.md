---
title: "Date.FormatStyle.dateTime"
date: 2022-03-13T15:51:05-06:00
draft: false
tags: [ios15, formatstyle, deepdive]
---

## Compositing Using `.dateTime()`

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

Apple provides the `Date.FormatStyle.dateTime()` FormatStyle to allow us to mix and match the individual time units we want to display in our final localized string. Each of these time units can further be customized to allow you to fine-tune every aspect of your display string.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

The available units are:

- `.day()` The numerical day of the month
- `.dayOfYear()` The numerical day of the year
- `.era()` The era (AD/BC in the gregorian calendar for example)
- `.hour()` The numerical hour
- `.minute()` The numerical minute
- `.month()` The month as a string
- `.quarter()` The quarter
- `.second()` The Numerical second
- `.timeZone()` The time zone
- `.week()` The numerical week of the month
- `.weekday()`The weekday as a string
- `.year()` The numerical year

> Sidenote: Each of these time units are actually methods that return a `FormatStyle` instance. Isn't functional chaining neat?

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

twosday.formatted(.dateTime.day())       // "22"
twosday.formatted(.dateTime.dayOfYear()) // "53"
twosday.formatted(.dateTime.era())       // "AD"
twosday.formatted(.dateTime.hour())      // "2 AM"
twosday.formatted(.dateTime.minute())    // "22"
twosday.formatted(.dateTime.month())     // "Feb"
twosday.formatted(.dateTime.quarter())   // "Q1"
twosday.formatted(.dateTime.second())    // "22"
twosday.formatted(.dateTime.timeZone())  // "MST"
twosday.formatted(.dateTime.week())      // "9"
twosday.formatted(.dateTime.weekday())   // "Tue"
twosday.formatted(.dateTime.year())      // "2022"
```

It's usage is simple, but verbose. Call the formatted method on the Date and pass in the `dateTime` style with a chain of units you'd like to include.

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

twosday.formatted(.dateTime.year().month().day().hour().minute().second()) // "Feb 22, 2022, 2:22:22 AM"
twosday.formatted(.dateTime.second().minute().hour().day().month().year()) // "Feb 22, 2022, 2:22:22 AM"
```

> Note: As you can see, the order of the components doesn't matter. The system will display them in the correct way for your device's Locale and Calendar.

If you are wanting to customize the Locale of your string, you can simply hang the `.locale()` call at the end of your chain of time units:

```Swift
let franceLocale = Locale(identifier: "fr_FR")
twosday.formatted(.dateTime.year().month().day().hour().minute().second().locale(franceLocale)) // "22 févr. 2022 à 02:22:22"
```

### Customizing Individual Time Units

Each unit can be customized by passing in a `Symbol` into each individual component method. You can use them to further customize the component and build out the perfect string. There's a lot of them, and each has a variety of options available to you.

- `Date.FormatStyle.Symbol.CyclicYear`
- `Date.FormatStyle.Symbol.Day`
- `Date.FormatStyle.Symbol.DayOfYear`
- `Date.FormatStyle.Symbol.DayPeriod`
- `Date.FormatStyle.Symbol.Era`
- `Date.FormatStyle.Symbol.Hour`
- `Date.FormatStyle.Symbol.Minute`
- `Date.FormatStyle.Symbol.Month`
- `Date.FormatStyle.Symbol.Quarter`
- `Date.FormatStyle.Symbol.Second`
- `Date.FormatStyle.Symbol.SecondFraction`
- `Date.FormatStyle.Symbol.StandaloneMonth`
- `Date.FormatStyle.Symbol.StandaloneQuarter`
- `Date.FormatStyle.Symbol.StandaloneWeekday`
- `Date.FormatStyle.Symbol.TimeZone`
- `Date.FormatStyle.Symbol.VerbatimHour`
- `Date.FormatStyle.Symbol.Week`
- `Date.FormatStyle.Symbol.Weekday`
- `Date.FormatStyle.Symbol.Year`
- `Date.FormatStyle.Symbol.YearForWeekOfYear`

Putting it all together:

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

twosday.formatted(.dateTime.day(.twoDigits))           // "22"
twosday.formatted(.dateTime.day(.ordinalOfDayInMonth)) // "4"
twosday.formatted(.dateTime.day(.defaultDigits))       // "22"
```

The power of this cannot be overstated. While it is verbose, this allows for you to specify exactly the string representation of the date you would like to an almost ludicrous degree. 

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>