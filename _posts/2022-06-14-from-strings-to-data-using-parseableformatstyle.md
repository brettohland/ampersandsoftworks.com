---
layout: post
title: From Strings to Data using ParsableFormatStyle
description: The other side of the FormatStyle coin, getting our data from strings.
tags: [ios, formatstyle, development, swift]
---

**TL;DR** [Xcode Playground](https://github.com/brettohland/ampersandsoftworks.com-examples/tree/main/%5B2022-06-14%5D%20ParseableFormatStyle) or [Examples as Gist](https://gist.github.com/brettohland/f07fa1069e495d96dda098f13adaefae)

The venerable [(NS)Formatter class (and Apple's various subclasses)](https://developer.apple.com/documentation/foundation/formatter/) are an Objective-C based API that is most well known as the go-to method for converting data types into strings. One of the lesser-known features of the APIs are that these same formatters can do the reverse: parse strings into their respective data types. 

Apple's modern Swift replacement system for `Formatter` is a set of protocols: `FormatStyle` and `ParseableFormatStyle`. The former handles the conversion to strings, and the latter strings to data.

> One small thing. I mention conversion to and from strings here specifically. But these two protocols are completely type agnostic. You can convert to and from any data type. Follow your dreams.

`FormatStyle` and it's various implementations is it's own beast. Apple's various implementations to support the built-in Foundation data types is quite extensive but spottily documented. [I made a whole site to help you use them](https://goshdarnformatstyle.com). 

But that's not what we're going to talk about today.

Today we're going to talk about `ParseableFormatStyle` and it's implementations. How can we convert some strings into data?

# What is ParseableFormatStyle Anyway?

The `ParseableFormatStyle` protocol is quite simple, it inherits from `FormatStyle` and simply defines a `ParseStrategy` property:

{% splash %}
/// A type that can convert a given data type into a representation.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public protocol ParseableFormatStyle : FormatStyle {

    associatedtype Strategy : ParseStrategy where Self.FormatInput == Self.Strategy.ParseOutput, Self.FormatOutput == Self.Strategy.ParseInput

    /// A `ParseStrategy` that can be used to parse this `FormatStyle`'s output
    var parseStrategy: Self.Strategy { get }
}
{% endsplash %}

[Apple's Documentation for ParseableFormatStyle](https://developer.apple.com/documentation/foundation/parseableformatstyle/)

Okay, so what's `ParseStrategy` then?

{% splash %}
/// A type that can parse a representation of a given data type.
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public protocol ParseStrategy : Decodable, Encodable, Hashable {

    /// The type of the representation describing the data.
    associatedtype ParseInput

    /// The type of the data type.
    associatedtype ParseOutput

    /// Creates an instance of the `ParseOutput` type from `value`.
    func parse(_ value: Self.ParseInput) throws -> Self.ParseOutput
}
{% endsplash %}

[Apple's Documentation for ParseStrategy](https://developer.apple.com/documentation/foundation/parsestrategy)

The protocols themselves are concise, and to the point. You can very easily use them to bolt this functionality onto your own custom types. 

# How Do I Use It?

The most direct way of parsing a string into it's respective data type is to create an instance of a `ParseableFormatStyle` that's set up to understand the structure of the incoming string. From there you access it's `parseStrategy` property, and call the `parse()` method on it.

This is a bit cumbersome, so Apple has included custom initializers onto each of the supported data types that take the string and either a `ParseableFormatStyle` or a `ParseStrategy` instance to do the parsing. What's interesting is that Apple includes initializers that can accept _any_ input type, as long as you provide a `ParseStrategy` that informs the type how to parse it. Aren't constrained generics neat?

# What Types Are Supported?

You can parse:

- Dates
- Decimals (Numbers, Percentages, Currency)
- Person Names
- URLs (iOS 16 only)

In general, you have two ways of accessing the parsing code:

## Parsing Numbers

All of Swift's numerical styles are supported with a new initializer.

{% splash %}
// MARK: Parsing Integers
try? Int("120", format: .number) // 120
try? Int("0.25", format: .number) // 0
try? Int("1E5", format: .number.notation(.scientific)) // 100000

// MARK: Parsing Floating Point Numbers
try? Double("0.0025", format: .number) // 0.0025
try? Double("95%", format: .number) // 95
try? Double("95%", format: .percent) // 95
try? Double("1E5", format: .number.notation(.scientific)) // 100000

try? Float("0.0025", format: .number) // 0.0025
try? Float("95%", format: .number) // 95
try? Float("1E5", format: .number.notation(.scientific)) // 100000

// MARK: Parsing Decimals
try? Decimal("0.0025", format: .number) // 0.0025
try? Decimal("95%", format: .number) // 95
try? Decimal("1E5", format: .number.notation(.scientific)) // 100000

// MARK: Parsing Percentages
try? Int("98%", format: .percent) // 98
try? Float("95%", format: .percent) // 0.95
try? Decimal("95%", format: .percent) // 0.95

// MARK: Parsing Currencies
try? Decimal("$100.25", format: .currency(code: "USD")) // 100.25
try? Decimal("100.25 British Points", format: .currency(code: "GBP")) // 100.25

{% endsplash %} 

## Parsing Dates

While there's [a myriad of different ways to format a `Date` object for display using the various included format styles](https://goshdarnformatstyle.com/#date-and-time-single-date). The only two that conform to `ParseableFormatStyle` are `Date.FormatStyle` and `Date.ISO8601FormatStyle`.

{% splash %}

try? Date.FormatStyle()
    .day()
    .month()
    .year()
    .hour()
    .minute()
    .second()
    .parse("Feb 22, 2022, 2:22:22 AM") // Feb 22, 2022, 2:22:22 AM

try? Date.FormatStyle()
    .day()
    .month()
    .year()
    .hour()
    .minute()
    .second()
    .parseStrategy.parse("Feb 22, 2022, 2:22:22 AM") // Feb 22, 2022, 2:22:22 AM

try? Date.ISO8601FormatStyle(timeZone: TimeZone(secondsFromGMT: 0)!)
    .year()
    .day()
    .month()
    .dateSeparator(.dash)
    .dateTimeSeparator(.standard)
    .timeSeparator(.colon)
    .timeZoneSeparator(.colon)
    .time(includingFractionalSeconds: true)
    .parse("2022-02-22T09:22:22.000") // Feb 22, 2022, 2:22:22 AM

try? Date.ISO8601FormatStyle(timeZone: TimeZone(secondsFromGMT: 0)!)
    .year()
    .day()
    .month()
    .dateSeparator(.dash)
    .dateTimeSeparator(.standard)
    .timeSeparator(.colon)
    .timeZoneSeparator(.colon)
    .time(includingFractionalSeconds: true)
    .parseStrategy.parse("2022-02-22T09:22:22.000") // Feb 22, 2022, 2:22:22 AM

try? Date(
    "Feb 22, 2022, 2:22:22 AM",
    strategy: Date.FormatStyle().day().month().year().hour().minute().second().parseStrategy
) // Feb 22, 2022 at 2:22 AM

try? Date(
    "2022-02-22T09:22:22.000",
    strategy: Date.ISO8601FormatStyle(timeZone: TimeZone(secondsFromGMT: 0)!)
        .year()
        .day()
        .month()
        .dateSeparator(.dash)
        .dateTimeSeparator(.standard)
        .timeSeparator(.colon)
        .timeZoneSeparator(.colon)
        .time(includingFractionalSeconds: true)
        .parseStrategy
) // Feb 22, 2022 at 2:22 AM

{% endsplash %}

## Parsing Names

Parsing Names is helpful when you just don't want to think about how various locals handle the order and display of given and family names.

{% splash %}
// namePrefix: Dr givenName: Elizabeth middleName: Jillian familyName: Smith nameSuffix: Esq.
try? PersonNameComponents.FormatStyle()
    .parseStrategy.parse("Dr Elizabeth Jillian Smith Esq.")

// namePrefix: Dr givenName: Elizabeth middleName: Jillian familyName: Smith nameSuffix: Esq.
try? PersonNameComponents.FormatStyle(style: .long)
    .parseStrategy.parse("Dr Elizabeth Jillian Smith Esq.")

// namePrefix: Dr givenName: Elizabeth middleName: Jillian familyName: Smith nameSuffix: Esq.
try? PersonNameComponents.FormatStyle(style: .long, locale: Locale(identifier: "zh_CN"))
    .parseStrategy.parse("Dr Smith Elizabeth Jillian Esq.")

// namePrefix: Dr givenName: Elizabeth middleName: Jillian familyName: Smith nameSuffix: Esq.
try? PersonNameComponents.FormatStyle(style: .long)
    .locale(Locale(identifier: "zh_CN"))
    .parseStrategy.parse("Dr Smith Elizabeth Jillian Esq.")

// namePrefix: Dr givenName: Elizabeth middleName: Jillian familyName: Smith nameSuffix: Esq.
try? PersonNameComponents(
    "Dr Elizabeth Jillian Smith Esq.",
    strategy: PersonNameComponents.FormatStyle(style: .long).parseStrategy
)
{% endsplash %}

## URLs (iOS 16/Xcode 14 only)

Xcode 14, you can now use the new `URL.FormatStyle.ParseStrategy` struct to parse URLs (as an alternative to using the venerable `URL(string:relativeTo)` initializer).

You can set as options for each component to be required, optional, or default to a set value:

{% splash %}

try URL.FormatStyle.Strategy(port: .defaultValue(80)).parse("http://www.apple.com") // http://www.apple.com:80
try URL.FormatStyle.Strategy(port: .optional).parse("http://www.apple.com") // http://www.apple.com
try URL.FormatStyle.Strategy(port: .required).parse("http://www.apple.com") // throws an error

// This returns a valid URL
try URL.FormatStyle.Strategy()
    .scheme(.required)
    .user(.required)
    .password(.required)
    .host(.required)
    .port(.required)
    .path(.required)
    .query(.required)
    .fragment(.required)
    .parse("https://jAppleseed:Test1234@apple.com:80/macbook-pro?get-free#someFragmentOfSomething")

// This throws an error (the port is missing)
try URL.FormatStyle.Strategy()
    .scheme(.required)
    .user(.required)
    .password(.required)
    .host(.required)
    .port(.required)
    .path(.required)
    .query(.required)
    .fragment(.required)
    .parse("https://jAppleseed:Test1234@apple.com/macbook-pro?get-free#someFragmentOfSomething")
{% endsplash %}

By default, only the scheme and host are required.

---

[Xcode Playground](https://github.com/brettohland/ParseableFormatStyle-Examples) or [Examples as Gist](https://gist.github.com/brettohland/f07fa1069e495d96dda098f13adaefae)