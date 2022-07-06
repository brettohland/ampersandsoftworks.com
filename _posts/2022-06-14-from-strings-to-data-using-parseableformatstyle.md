---
layout: post
title: From Strings to Data using ParsableFormatStyle
description: The other side of the FormatStyle coin, getting our data from strings.
tags: [formatstyle, development, swift, formatstyle]
---

**TL;DR** [Xcode Playground](https://github.com/brettohland/ParseableFormatStyle-Examples) or [Examples as Gist](https://gist.github.com/brettohland/f07fa1069e495d96dda098f13adaefae)

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

## Parsing Decimals

Of all of the number types in Foundation, only the `Decimal` type's `FormatStyle` conforms to `ParseableFormatStyle`. 

{% splash %}

// MARK: - Using the FormatStyle directly
try? Decimal.FormatStyle().notation(.scientific).parseStrategy.parse("1E5") // 100000
try? Decimal.FormatStyle().scale(5).notation(.scientific).parseStrategy.parse("1E5") // 20000
try? Decimal.FormatStyle().scale(-5).notation(.scientific).parseStrategy.parse("1E5") // -20000

try? Decimal.FormatStyle.Percent().parseStrategy.parse("15%") // 0.15
try? Decimal.FormatStyle.Percent().scale(2).parseStrategy.parse("100%") // 50
try? Decimal.FormatStyle.Percent(locale: Locale(identifier: "fr_FR")).parseStrategy.parse("15 %") // 0.15
try? Decimal.FormatStyle.Percent(locale: Locale(identifier: "en_CA")).parseStrategy.parse("15 %") // 0.15

try? Decimal.FormatStyle.Currency(code: "GBP")
    .presentation(.fullName)
    .parseStrategy.parse("10.00 British pounds") // 10

try? Decimal.FormatStyle.Currency(code: "GBP", locale: Locale(identifier: "fr_FR"))
    .presentation(.fullName)
    .parseStrategy.parse("10,00 livres sterling") // 10

try? Decimal.FormatStyle.Currency(code: "GBP")
    .presentation(.fullName)
    .locale(Locale(identifier: "fr_FR"))
    .parseStrategy.parse("10,00 livres sterling") // 10

// MARK: - Custom Initializers on Decimal

try? Decimal("1E5", strategy: Decimal.FormatStyle().notation(.scientific).parseStrategy) // 100000
try? Decimal("1E5", format: Decimal.FormatStyle().notation(.scientific)) // 100000

try? Decimal("15%", strategy: Decimal.FormatStyle.Percent().parseStrategy) // 0.15
try? Decimal("15%", format: Decimal.FormatStyle.Percent()) // 0.15

try? Decimal("10.00 British pounds", strategy: Decimal.FormatStyle.Currency(code: "GBP").parseStrategy) // 10
try? Decimal("10.00 British pounds", format: Decimal.FormatStyle.Currency(code: "GBP")) // 10

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

New for iOS 16, you can now parse URLs using this exact manner:

{% splash %}
try? URL.FormatStyle()
    .parseStrategy.parse("https://jAppleseed:Test1234@apple.com:80/macbook-pro?get-free#someFragmentOfSomething")

try? URL(
    "https://jAppleseed:Test1234@apple.com:80/macbook-pro?get-free#someFragmentOfSomething",
    strategy: URL.FormatStyle().parseStrategy
{% endsplash %}

---

[Xcode Playground](https://github.com/brettohland/ParseableFormatStyle-Examples) or [Examples as Gist](https://gist.github.com/brettohland/f07fa1069e495d96dda098f13adaefae)