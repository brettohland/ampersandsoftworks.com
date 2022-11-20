---
layout: post
title: You can stop writing date format strings like "yyyy-MMM-dd"
description: Apple gives us a modern replacement for the magical format strings we pass to DateFormatters, let's talk about the Verbatim Format Style.
tags: [ios, development, swift, formatstyle]
date: 2022-11-19 06:21 -0600
---

<small>_Updated November 19th, 2022 to include clarity around setting the TimeZone and/or Calendar on the Verbatim Format Style._</small>

I dislike time. 

Well, more specifically: I hate being a programmer and dealing with times and dates.

> This is your bi-annual reminder about the [falsehoods programmers believe about time](https://gist.github.com/timvisee/fcda9bbdff88d45cc9061606b4b923ca).

As Apple ecosystem developers, I can say that we're spoiled by [Foundation's incredible date and time handling](https://developer.apple.com/documentation/foundation/dates_and_times). When used correctly, you can push a lot of those date and time assumptions out of your brain and trust that someone *much more dedicated to the cause than you* has been toiling in the calendar mines for a very long time and taken care of it for you.

But it's not all sunshine and roses… 

# Enter the DateFormatter

> TL;DR [Just read the best practices section of NSDateFormatter.com](https://nsdateformatter.com/#best-practices) on why DateFormatters are rough.

To handle the complexities of showing the user a localized date string, we have the [`(NS)DateFormatter`](https://developer.apple.com/documentation/foundation/nsdateformatter) to do the heavy lifting for us.

I wouldn't consider this, or any other of the formatter classes, to be beginner friendly. This is because there's a level of specialized knowledge that you need to use them effectively. The biggest "gotcha" is that they're expensive to initialize, but not so much that you'd notice if you create a handful of them.

A simple example that I've seen (and written myself before I knew better) would be solving the need of showing a date to a user in a `UITableView` cell:

{% splash %}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .full

    var cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
    // Display the current date and time in the cell using the above date formatter.
    cell.textLabel?.text = formatter.string(from: .now)
    return cell
}
{% endsplash %}

We're now in a situation where the size of our table's data source can now cripple the performance of our application. You aren't going to notice an issue scrolling through a table of a few items (or probably a few dozen), but the minute you're scrolling through a list of posts in your social network client. You're going to start seeing a lot of memory usage.

The solve for this is to create your date formatter once in a shared location and to use that instance everywhere.

[Apple's current documentation doesn't mention this pitfall](https://developer.apple.com/documentation/foundation/dateformatter), which is a shame. If you dig deep, [you can find this info in the documentation archive](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html#//apple_ref/doc/uid/TP40002369-SW10), but I'm not sure many developers will dig this deep. Hopefully you'll run into this advice somewhere in Stack Overflow.

Next bit of esoterica:

# Now Read A Unicode Technical Standard!

If you're needing more fine-grained control over your date string (outside of the set none/short/medium/long/full options for `dateStyle` and `timeStyle`), you get to learn all about [Unicode standard date format patterns](http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns).

Thankfully, because it's a Unicode standard, the internet is awash with information about how to write your magical date strings to get the exact output you want. But there's weird traps here too. For example: [If you use "YYYY" instead of "yyyy", your code is going to output the wrong year 1% of the time](https://dev.to/shane/yyyy-vs-yyyy-the-day-the-java-date-formatter-hurt-my-brain-4527). Good luck with that bug.

Infamously, [Ben Scheirman](https://benscheirman.com)/[NSScreencast](https://nsscreencast.com/) built a single serving site just to help with this: [https://nsdateformatter.com](https://nsdateformatter.com). Honestly, just read the [Best Practices](https://nsdateformatter.com/#best-practices) section to immediately learn everything you need to know about this.

But to quickly recap:

1. You should be using the presets as much as possible
2. The formatter isn't fully Locale-aware by default
3. You should be using the `ISO8601DateFormatter` if you're dealing with standard dates (and set the `en_US_POSIX` locale)

There has to be a better way.

# Format Styles Are Great

Starting with every platform supported by Xcode 13 [^1] (iOS 15.0+, iPadOS 15.0+, Mac Catalyst 15.0+, tvOS 15.0+, watchOS 8.0+, macOS 12.0+) and made slightly easier in every platform supported by Xcode 14 [^2]. Apple has moved away from the formatter classes to the more modern Format Style protocol. But in true Apple fashion, the documentation for this functionality is spotty. In fact, [I made a whole site to document what they can do](https://goshdarnformatstyle.com).

[^1]: Xcode 13 supports iOS 15.0+, iPadOS 15.0+, Mac Catalyst 15.0+, tvOS 15.0+, watchOS 8.0+, macOS 12.0+
[^2]: Xcode 14 supports iOS 16.0+, iPadOS 16.0+, Mac Catalyst 16.0+, tvOS 16.0+, watchOS 9.0+, macOS 13.0+

> **New to the concept of format styles? Here's a recap:**
> 
> 1. Nearly every Foundation type have a `.formatted()` method as of Xcode 13 [^1]
> 2. You can optionally pass something that conforms to the `FormatStyle` protocol into this method to be specific in what shows up
> 3. Apple extended `FormatStyle` with static properties and methods to give you easy access to special format styles
> 4. The `Text` View in SwiftUI accepts a `FormatStyle` as an optional second parameter to simplify sting output
> 
> I'll refer you to [goshdarnformatstyle.com](https://goshdarnformatstyle.com/#the-basics) for a lot more detail as to what you can do, so we can fully focus on our topic at hand.

There's a whole host of date format styles available to us that represent nearly every possible use case for displaying dates. And all of them support localization out of the box:

* [Single Date Styles](https://goshdarnformatstyle.com/date-styles/)
    * [Compositing](https://goshdarnformatstyle.com/date-styles/#compositing)
    * [Date and Time Style](https://goshdarnformatstyle.com/date-styles/#date-and-time-single-date)
    * [ISO 8601 Style](https://goshdarnformatstyle.com/date-styles/#iso-8601-date-style-single-date)
    * [Relative Date Style](https://goshdarnformatstyle.com/date-styles/#relative-date-style-single-date)
    * [Verbatim Style](https://goshdarnformatstyle.com/date-styles/#verbatim-date-style-single-date) (Updated for Xcode 14)
* [Date Range Styles](https://goshdarnformatstyle.com/date-range-styles/)
    * [Interval Style](https://goshdarnformatstyle.com/date-range-styles/#interval-date-style-date-range)
    * [Components Style](https://goshdarnformatstyle.com/date-range-styles/#components-date-style-date-range)

I encourage you to [look through this gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c) and marvel at just how comprehensive these various formatters are.

Apple has essentially split the functionality present in `DateFormatter` into discrete Format Style chunks, but not made it terribly obvious or discoverable what and how to use them.

So let's change that a bit, by covering one specific use case: How can we replicate the `yyyy-MMM-dd` output from earlier?

# A Tale of Two Date Styles

## Using Date.FormatStyle

Let's say, for example, that we want to replicate a `DateFormatter` that is set up to output a date in the following format: "yyyy-MMM-dd". Knowing some of the available date format styles available to us, you may decide to simply do the following to grab each piece of the date using the `Date.FormatStyle` static methods and use string concatenation to put them together:

{% splash %}
let twosdayDateComponents = DateComponents(
    year: 2_022,
    month: 2,
    day: 22,
    hour: 2,
    minute: 22,
    second: 22,
    nanosecond: 22
)
let twosday = Calendar(identifier: .gregorian).date(from: twosdayDateComponents)!

// Outputs "2022-Feb-22"
let outputString = "\(twosday.formatted(.dateTime.year()))-\(twosday.formatted(.dateTime.month()))-\(twosday.formatted(.dateTime.day()))"

{% endsplash %}

Or, if you aren't playing life on hard mode you may want to clean things up a bit:

{% splash %}

let twosdayDateComponents = DateComponents(
    year: 2_022,
    month: 2,
    day: 22,
    hour: 2,
    minute: 22,
    second: 22,
    nanosecond: 22
)
let twosday = Calendar(identifier: .gregorian).date(from: twosdayDateComponents)!

let yearString = twosday.formatted(.dateTime.year())
let monthString = twosday.formatted(.dateTime.month())
let dayString = twosday.formatted(.dateTime.day())

// Outputs "2022-Feb-22"
let outputString = "\(yearString)-\(monthString)-\(dayString)"
{% endsplash %}

Absolutely, this is a valid way of showing this information to the user. But it's awkward to use in a reusable manner and we've effectively [lost the SwiftUI magic in the `Text` View](https://goshdarnformatstyle.com/swiftui/). If we're needing to explicitly set the `Locale`, `TimeZone`, or `Calendar`, then this method further breaks down as we'll have to specifically set it for each of the year, month, and day components. 

Wouldn't it be great to just do it once and be done with it?

# Enter: The Verbatim Format Style

As a great philosopher once said: ["Knowing is half the battle"](https://www.youtube.com/watch?v=pele5vptVgc). [^3]

[^3]: When I started my journey into documenting the various format styles, the Verbatim Format Style was the one that had almost no information written about it online. The Apple docs were non-existent, and the one bit of info I did find was on [the Swift language forums about outputting 24 hour time](https://forums.swift.org/t/new-date-formatstyle-anyway-to-do-24-hour/52994/38?page=2).

What the Verbatim Format Style gives us is the exact functionality we're looking for, but without the need of that magic, tokenized date format string. Instead we have a new `Date.FormatString` which gives us access to all of our date components, but it's type safe and easy to use. 

> Don't use this for ISO8601 string output. [Apple built a purpose-built format style for this purpose](https://goshdarnformatstyle.com/date-styles/#iso-8601-date-style-single-date).

The initializer for this style is fairly straightforward:

{% splash %}

public init(format: Date.FormatString, locale: Locale? = nil, timeZone: TimeZone, calendar: Calendar)

{% endsplash %}

The `Locale`, `TimeZone`, and `Calendar` parameters are self explanatory, and should inform you that this format style is a serious style for serious developers needing serious date strings. But what in the world is a `Date.FormatString`?

Well, this is where the magic is going to happen.

Let's think about our example from earlier when we manually built out our date string using `Date.FormatStyle` static methods to access various date components:

{% splash %}
let outputString = "\(twosday.formatted(.dateTime.year()))-\(twosday.formatted(.dateTime.month()))-\(twosday.formatted(.dateTime.day()))"
{% endsplash %}

We're using standard Swift string interpolation to get our final string (essentially everything between Swift magical `\()` characters). But because that same standard string interpolation has no idea about the domain of the problem that we're trying to solve, we have to explicitly tell it about how to create the year, month, and day values.

As of Swift 5.0, we actually have the ability to get the compiler into night classes and teach it about what we want to do by using the `ExpressibleByStringInterpolation` protocol. And as luck would have it, `Date.FormatString` conforms to it and does just that.

 > If you aren't familiar with `ExpressibleByStringInterpolation`, I honestly can't blame you.  [Apple's documentation is pretty sparse](https://developer.apple.com/documentation/swift/expressiblebystringinterpolation), but everyone's favourite Mattt [wrote a great article in 2019 on NSHipster](https://nshipster.com/expressiblebystringinterpolation/) which covered it in great detail (hilariously enough where he uses date formatting as an example). 

`Date.FormatString` defines ways of accessing _all_ of the date components available to us with the Unix standard date format patterns, but in a type safe and discoverable manner.

To output "yyyy-MMM-dd", it's as easy as:

{% splash %}
let formatString: Date.FormatString = "\(year: .defaultDigits)-\(month: .abbreviated)-\(day: .twoDigits)"
{% endsplash %}

Yes, this line of code is longer than our original `DateFormatter` format string, but what we've lost in horizontal compactness, we've gained five-fold in readability and discoverability. You can read this and reason out exactly what's going to be output by this string and tweak it until it's exactly what you need.

You can access:

- [Era](https://goshdarnformatstyle.com/date-styles/#era-token)
- [Year](https://goshdarnformatstyle.com/date-styles/#year-token)
- [YearForWeekOfYear](https://goshdarnformatstyle.com/date-styles/#yearforweekofyear-token)
- [CyclicYear](https://goshdarnformatstyle.com/date-styles/#cyclicyear-token)
- [Quarter](https://goshdarnformatstyle.com/date-styles/#quarter-token)
- [Month](https://goshdarnformatstyle.com/date-styles/#month-token)
- [Week](https://goshdarnformatstyle.com/date-styles/#week-token)
- [Day](https://goshdarnformatstyle.com/date-styles/#day-token)
- [DayOfYear](https://goshdarnformatstyle.com/date-styles/#dayofyear-token)
- [Weekday](https://goshdarnformatstyle.com/date-styles/#weekday-token)
- [DayPeriod](https://goshdarnformatstyle.com/date-styles/#dayperiod-token)
- [Minute](https://goshdarnformatstyle.com/date-styles/#minute-token)
- [Second](https://goshdarnformatstyle.com/date-styles/#second-token)
- [SecondFraction](https://goshdarnformatstyle.com/date-styles/#secondfraction-token)
- [TimeZone](https://goshdarnformatstyle.com/date-styles/#timezone-token)
- [StandaloneQuarter](https://goshdarnformatstyle.com/date-styles/#standalonequarter-token)
- [StandaloneMonth](https://goshdarnformatstyle.com/date-styles/#standalonemonth-token)
- [StandaloneWeekday](https://goshdarnformatstyle.com/date-styles/#standaloneweekday-token)
- [VerbatimHour](https://goshdarnformatstyle.com/date-styles/#verbatimhour-token)

And each of these date components have quite a few customization options available.

(Did I mention I created a [whole gosh darned website to document these](https://goshdarnformatstyle.com/date-styles/#verbatim-date-style-single-date)?)

Armed with this new knowledge, you quickly put it in practice:

{% splash %}

let twosdayDateComponents = DateComponents(
    year: 2_022,
    month: 2,
    day: 22,
    hour: 2,
    minute: 22,
    second: 22,
    nanosecond: 22
)
let twosday = Calendar(identifier: .gregorian).date(from: twosdayDateComponents)!

let verbatimStyle = Date.VerbatimFormatStyle(
    format: "\(year: .defaultDigits)-\(month: .abbreviated)-\(day: .twoDigits)",
    timeZone: .autoupdatingCurrent,
    calendar: Calendar(identifier: .gregorian)
)

twosday.formatted(verbatimStyle) // "2022-M02-22"???????

{% endsplash %}

`"2022-M02-22"`? Why in the world is our month being output as `M02`?

# Chekhov's Optional Locale

You might have noticed in the above example that I didn't provide the `locale` parameter to the initializer as it's an optional value that defaults to `nil`. This specifically is the problem as the system has no idea how to display the month to us. You can simply add it to fix our issue:

{% splash %}

let twosdayDateComponents = DateComponents(
    year: 2_022,
    month: 2,
    day: 22,
    hour: 2,
    minute: 22,
    second: 22,
    nanosecond: 22
)
let twosday = Calendar(identifier: .gregorian).date(from: twosdayDateComponents)!

let verbatimStyle = Date.VerbatimFormatStyle(
    format: "\(year: .defaultDigits)-\(month: .abbreviated)-\(day: .twoDigits)",
    locale: Locale(identifier: "en_US"),
    timeZone: .autoupdatingCurrent,
    calendar: Calendar(identifier: .gregorian)
)

twosday.formatted(verbatimStyle) // "2022-Feb-22"

{% endsplash %}

Success.

# An Aside About Calendars & Locales

One thing that we need to remember as we're using this format style is that our choices for `TimeZone` and `Calendar` have interesting side-effects that may not be obvious to us. As a developer based in Canada, I rarely have to consider the effects that using the Buddhist or Hebrew calendars might do to my code.

In the example above, you'll notice that I explicitly set the `Locale` to be US English (`Locale(identifier: "en_US")`) and the `Calendar` to be Gregorian (`Calendar(identifier: .gregorian)`). Since the general goals of this format style is to have a fixed date format string as the output, it makes a lot of sense to set these to guarantee the output.

In cases where that need isn't so fixed (maybe just showing the user a specifically formatted string), then it might make sense to set the `Locale`, `TimeZone`, and `Calendar` to `.autoupdatingCurrent`. 

I will warn you though, it seems that using `.autoupdatingCurrent` for the `Locale` will override any set `Calendar` parameter used to create the format style.

{% splash %}

// By using `.autoupdatingCurrent` for the `Locale`, the calendar parameter is ignored in the output string.
Date.VerbatimFormatStyle(
    format: "\(year: .defaultDigits)-\(month: .abbreviated)-\(day: .twoDigits)",
    locale: .autoupdatingCurrent,
    timeZone: .autoupdatingCurrent,
    calendar: Calendar(identifier: .buddhist)
).format(twosday) // "2022-Feb-22"

// By setting an explicit Locale, the calendar parameter is used.
Date.VerbatimFormatStyle(
    format: "\(year: .defaultDigits)-\(month: .abbreviated)-\(day: .twoDigits)",
    locale: Locale(identifier: "en_US"),
    timeZone: .autoupdatingCurrent,
    calendar: Calendar(identifier: .buddhist)
).format(twosday) // "2065-Feb-22"

// When omitting the locale, the calendar parameter is used.
Date.VerbatimFormatStyle(
    format: "\(year: .defaultDigits)-\(month: .abbreviated)-\(day: .twoDigits)",
    timeZone: .autoupdatingCurrent,
    calendar: Calendar(identifier: .buddhist)
).format(twosday) // "2565-M02-22"

{% endsplash %}

Is this a bug? Possibly. (Feedback FB11806265 was submitted)

# One Final Convenience

If you've used or have been comfortable with format styles in the past, you know that creating and holding onto instances of formats styles is a clumsy way of doing things. Apple has extended `FormatStyle` in ways to expose these styles to you in simple ways.

For all platforms supported by Xcode 13 [^1], the simple accessor for the verbatim format style is missing which did force you to create and hold onto instances. Thankfully Apple did fix this in Xcode 14 [^2] and you can simply do this:

{% splash %}

let twosdayDateComponents = DateComponents(
    year: 2_022,
    month: 2,
    day: 22,
    hour: 2,
    minute: 22,
    second: 22,
    nanosecond: 22
)
let twosday = Calendar(identifier: .gregorian).date(from: twosdayDateComponents)!

// "2022-Feb-22"
twosday.formatted(
    .verbatim("\(year: .defaultDigits)-\(month: .abbreviated)-\(day: .twoDigits)",
    locale: .autoupdatingCurrent,
    timeZone: .autoupdatingCurrent,
    calendar: .autoupdatingCurrent)
)

{% endsplash %}

If you are targeting those Xcode 13 platforms [^1], you can easily backport this functionality by simply adding this extension to your project:

{% splash %}

public extension FormatStyle where Self == Date.VerbatimFormatStyle {
    static func verbatim(
        _ format: Date.FormatString,
        locale: Locale? = nil,
        timeZone: TimeZone,
        calendar: Calendar
    ) -> Date.VerbatimFormatStyle {
        return Date.VerbatimFormatStyle(format: format, locale: locale, timeZone: timeZone, calendar: calendar)
    }
}

{% endsplash %}

And there we have it, you now know everything that there is to know to get started using this modern replacement for the `DateFormatters` of old. Format styles as a concept are fantastic once you've learned the ins and outs of the various styles available to you by Apple.

Happy verbatiming!

---