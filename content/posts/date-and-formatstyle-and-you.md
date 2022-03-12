---
title: "Date & FormatStyle & You"
date: 2022-03-11T06:53:13-07:00
draft: false
tags: [ios15, formatstyle, deepdive]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

Correctly displaying localized string values of dates is something that every developer needs. To do this correctly is incredibly complex, and thankfully Apple gives us a very powerful set of tools to do this correctly.

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e#file-date-formatting-swift)

Jump to each section:

- [`.formatted()`](#the-basics)
- [`.formatted(.dateStyle)`](#compositing-using-datetime)
- [`.formatted(date: time:)`](#datestyle--timestyle)
- [`.formatted(.relative)`](#relative-dates)
- [`.formatted(Date.FormatStyle)`](#custom-dateformatstyle)
- [`Text(_: format:) // SwiftUI`](#swiftui)

<hr>

# The Basics

Simply calling `.formatted()` on a Date object will give you a simple and easy to read string:

```Swift
twosday.formatted() // "2/22/2022, 2:22 AM"
``` 

This is great for simple use cases, and debugging.

<hr>

# Advanced Usage

## Compositing Using `.dateTime()`

([Apple Documentation](https://developer.apple.com/documentation/foundation/date/formatstyle))

Apple provides the `Date.FormatStyle.dateTime()` FormatStyle to allow us to mix and match the individual components we want to display in our final localized string. Each of these components can further customized to allow you to fine-tune every aspect of your display string.

The available components are:

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

> Note: I'm calling these "components", but in reality each of these are individual methods that return a `Date.FormatStyle`. You can further customize them (that's discussed below)

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

### Customizing Individual Components

Each component can be customized by passing in a `Symbol` into each individual component method. You can use them to further customize the component and build out the perfect string. There's a lot of them, so I'll just link to the docs if you're curious.

([Apple Documentation](https://developer.apple.com/documentation/foundation/date/formatstyle/symbol))

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

## DateStyle & TimeStyle

If you're not needing the granularity of the `.dateTime` style, you can quickly set the time and date styles using a convenience method on Date object.

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

<hr>

## Relative Dates

You can use the `.relative` format style if you'd like to show the distance between two dates. As this is using the `RelativeFormatStyle` and not the `DateFormatStyle`, I've written it in a separate post.

[Using RelativeDateStyle](/posts/formstyle-relative-dates)

<hr>

## Custom `Date.FormatStyle` & `FormatStyle`

If you're needing to set the calendar, locale, time zone, or capitalization style of your string you'll need to create a new `Date.FormatStyle` value. 

One of the unfortunate limitations is that you're limited to [the DateStyle and TimeStyle options](d#atestyle--timestyle) and not the full compositing ability of the `.dateTime` style.

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

## Custom FormatStyle

[As outline in this post, you can go one step further and create your own custom `FormatStyle`.](/posts/custom-formatstyle)

``` Swift
/// Returns the date in the most useless way ever
struct ReversedDateFormat: FormatStyle { // 1 
    typealias FormatInput = Date // 2
    typealias FormatOutput = String // 3

    func format(_ value: Date) -> String { // 4
        "\(value.formatted(.dateTime.second())):" +
        "\(value.formatted(.dateTime.minute())):" +
        "\(value.formatted(.dateTime.hour())) " +
        "\(value.formatted(.dateTime.day())) " +
        "\(value.formatted(.dateTime.month())) " +
        "\(value.formatted(.dateTime.year())) "
    }
}

extension FormatStyle where Self == ReversedDateFormat { // 5
    static var reversedDate: ReversedDateFormat { .init() }
}

twosday.formatted(.reversedDate) // "22:22:2 AM 22 Feb 2022 " // 6
```

1. Create a struct that conforms to the `FormatStyle` protocol
2. Required: Define the input type for the formatter
3. Required: Define the output type for the formatter
4. Implement the main function of the `FormatStyle` protocol, do whatever formatting or transformation you need within this method and return the output type.
5. You can then extend the `FormatStyle` protocol with the specified custom style to allow for easier usage

> Remember: If it's stupid and it works, it's not stupid.

<hr>

# SwiftUI

This power is available to us when we're using SwiftUI to display this data. The new initializer on the `Text` view allows us to pass in the data value in question and a formatter to output text without string concatenation.

```Swift
struct ContentView: View {
    static let twosdayDateComponents = DateComponents(
        year: 2022,
        month: 2,
        day: 22,
        hour: 2,
        minute: 22,
        second: 22,
        nanosecond: 22
    )

    var twosday: Date {
        Calendar(identifier: .gregorian).date(from: ContentView.twosdayDateComponents)!
    }

    var body: some View {
        VStack {
            Text(twosday, format: Date.FormatStyle(date: .complete, time: .complete))
            Text(twosday, format: .dateTime.hour())
            Text(twosday, format: .dateTime.year().month().day())
        }
        .padding()
    }
}
```

![](/images/2022/Mar/text-date-formatter.png)

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e#file-date-formatting-swift)