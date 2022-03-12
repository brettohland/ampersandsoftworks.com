---
title: "Date & FormatStyle & You"
date: 2022-03-11T06:53:13-07:00
draft: false
tags: [formatters, ios15, deepdive]
---

Apple introduced the new `FormatStyle` protocol with iOS 15. It allows for some truly remarkable things to happen when you're converting your data into strings. In true Apple fashion though, details about how to use these new features are lightly documented with few examples.

This post is going to dive into how to use the new `.formatted()` methods on the `Date` object and how its simplified interface hides some exciting complexity.

TL;DR: [Here's a gist with everything](https://gist.github.com/brettohland/84f03e32fa2d327c10ca2944d7d92d5c)

## Basic Usage (`.formatted()`)
Many of the internal value types have had a `.formatted()` method added to them. When called, the system will use a sensible default to display your data using your device's current Locale, Calendar and Language.

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

You can see the variations that Apple provides to us. But we're going to focus solely on Date formatting in this post.

[According to Apple](https://forums.swift.org/t/how-to-use-the-new-formatstyle-to-format-an-int-to-hex/51176/5), the implementation under the hood still uses the various `Formatter` subclasses, but now the system handles the caching for us. Our long nightmare is over.

Something to note, by default, the various formatters use the device's current Locale and Language to display all of its values. You are able to set a fixed Locale and Calendar

## Advanced Usage

By calling `.formatted(_ :)` and including an appropriate value that conforms to the `FormatStyle` protocol, we can customize the display of our data in our UI. 

`Date` types have a unique convenience method that lets you set the `Date.FormatStyle.DateStyle` and `Date.FormatStyle.TimeStyle` on the formatter.

``` Swift
.formatted(date: Date.FormatStyle.DateStyle, time: Date.FormatStyle.TimeStyle)
```

**DateStyle** ([Apple Documentation](https://developer.apple.com/documentation/foundation/date/formatstyle/datestyle))

- `.abbreviated` Displays the shortened localized month, day, and year: `"Feb 22, 2022"`
- `.complete` Displays the long form of the localized day of the week, the month, the numerical day, and year: `"Tuesday, February 22, 2022"`
- `.long` Displays the full length month, day, and year: `"February 22, 2022"`
- `.numeric` Displays the numeric month, numeric day, and numeric year: `"2/22/2022"`
- `.omitted` Omits from display

**TimeStyle** ([Apple Documentation](https://developer.apple.com/documentation/foundation/date/formatstyle/timestyle))
- `.complete` Displays the hour, minute, second, and time zone: `"2:22:22 AM MST"`
- `.shortened` Displays the hour, minute, and second: `"2:22 AM"`
- `.standard` Displays the hour, minute, second without the time zone: `"2:22:22 AM"`
- `.omitted` Omits from display

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

Of course, you can mix and match these values however you'd like as the method requires you to include both the `date` and `time` values.

``` Swift
.formatted(_: Date.FormatStyle)
```
([Apple Documentation](https://developer.apple.com/documentation/foundation/date/formatstyle))

The `Date.FormatStyle` struct has a `.dateTime` property. This can be composited in a way that allows for the creation of complex date strings with little work. You simply include within the formatted method a list of components you would like to include in the final string. **The order of these components does not matter**

Each of the date components are available to you to display:

- `.day()`
- `.dayOfYear()`
- `.era()`
- `.hour()`
- `.minute()`
- `.month()`
- `.quarter()`
- `.second()`
- `.timeZone()`
- `.week()`
- `.weekday()`
- `.year()`

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

You can then use these components to composite the exact string that you'd like convert to:

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
(You can see how the order of the components does not affect the final string)

You can _further specify_ the formatting styling for each of these components with specified `Symbol` types.

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

If you're needing to customize the locale, calendar, time zone, and capitalization context for a date, you can simply initialize a new `Date.FormatStyle` value and pass it into the `FormatStyle` parameter.

Unfortunately, you are limited to the `Date.FormatStyle.DateStyle` and `Date.FormatStyle.TimeStyle` values mentioned earlier for the display:

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
let posixStyle = Date.FormatStyle(
    date: .complete,
    time: .complete,
    locale: Locale(identifier: "en_us_POSIX"),
    calendar: Calendar(identifier: .chinese),
    timeZone: TimeZone(secondsFromGMT: 0)!,
    capitalizationContext: .standalone
)

twosday.formatted(posixStyle) // "Tuesday, February 22, 2022(2022), 9:22:22 AM GMT"
```

## Custom FormatStyle

If, for whatever reason, you aren't happy with the sheer power that's now available to you by the various built in `Date.FormatStyle` implementations. You can even ascend to the next level and fully write your own custom FormatStyle. 

For example, why not make the most useless formatter ever imagined that displays the time and date in a reverse format:

``` Swift
/// Returns the date in the most useless way ever
struct ReversedDateFormat: FormatStyle {
    typealias FormatInput = Date
    typealias FormatOutput = String

    func format(_ value: Date) -> String {
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

twosday.formatted(.reversedDate) // "22:22:2 AM 22 Feb 2022 "

```

1. Create a struct that conforms to the `FormatStyle` protocol
2. Required: Define the input type for the formatter
3. Required: Define the output type for the formatter
4. Implement the main function of the `FormatStyle` protocol, do whatever formatting or transformation you need within this method and return the output type.
5. You can then extend the `FormatStyle` protocol with the specified custom style to allow for easier usage

Remember: If it's stupid and it works, it's not stupid.

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
