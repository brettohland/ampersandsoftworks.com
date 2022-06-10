---
layout: post
title: What's new with FormatStyles in iOS 16
description: Guess documenting FormatSytle is my life now
tags: [ios16, formatstyle, development, swift, swiftui, formatstyle]
---

Another year, another WWDC. The yearly developer conference was firing on all cylinders this year, with some nice additions and one big fix on the `FormatStyle` front.

> This is only a surface level overview of what's new. I'll be updating [fuckingformatstyle](https://fuckingformatstyle)/[goshdarnformatstyle](https://goshdarnformatstyle.com) soon with all of the new details.

## 1. ByteCountFormatStyle Doesn't Crash Anymore

The first good news is that Apple has fixed an issue I found in my research.

The formatter gives you the ability to take a byte count and convert to other orders of magnatude. For example, you could take a count in kilobytes and convert it to terabytes.

Previously, converting any count to any unit of gigabyte or above would result in a `fatalError` crash:

{% splash %}
// .gb, .tb, .pb, .eb, .zb, and .ybOrHigher cause a FatalError (Feedback FB10031442)
terabyte.formatted(.byteCount(style: .file, allowedUnits: .gb))
{% endsplash %}

I'm happy to report that as of 14.0 beta (14A5228q), this now works as expected.

{% splash %}
terabyte.formatted(.byteCount(style: .file, allowedUnits: .gb)) // "1,000 GB"
{% endsplash %}

## 2. New Measurement style for UnitInformatStorage

I mentioned on the [gosh darned site](https://goshdarnsyntaxstyle.com) that you could use the Measurement format style to convert between units. The issue is that you aren't able the same customization options as the `ByteCountFormatStyle` using that option.

That's changed now. 

We now have an API for the byte count format style on top of the Measurement framework when using the `UnitInformationStorage` unit.

{% splash %}
let severalTerabytes = Measurement(value: 3, unit: UnitInformationStorage.terabytes)

severalTerabytes.formatted() // "3 TB"
severalTerabytes.formatted(.byteCount(style: .binary)) // "2.73 TB"
severalTerabytes.formatted(.byteCount(style: .decimal)) // "3 TB"
severalTerabytes.formatted(.byteCount(style: .file)) // "3 TB"
severalTerabytes.formatted(
    .byteCount(
        style: .binary,
        allowedUnits: .tb,
        spellsOutZero: true,
        includesActualByteCount: true
    )
) // "2.73 TB (3,000,000,000,000 bytes)"
severalTerabytes.formatted(
    .byteCount(
        style: .binary,
        allowedUnits: .tb,
        spellsOutZero: true,
        includesActualByteCount: false
    )
) // "2.73 TB"

severalTerabytes.formatted(
    .byteCount(
        style: .binary,
        allowedUnits: .tb,
        spellsOutZero: true,
        includesActualByteCount: true
    )
    .locale(Locale(identifier: "fr_FR"))
) // "2,73 To (3 000 000 000 000 octets)"

severalTerabytes.formatted(
    .byteCount(
        style: .binary,
        allowedUnits: .tb,
        spellsOutZero: true,
        includesActualByteCount: true
    )
    .attributed
)

let byteCountMeasurementStyle = Measurement<UnitInformationStorage>.FormatStyle.ByteCount(
    style: .binary,
    allowedUnits: .mb,
    spellsOutZero: true,
    includesActualByteCount: true,
    locale: Locale(identifier: "fr_FR")
)

severalTerabytes.formatted(byteCountMeasurementStyle) // "2 861 022,9 Mo (3 000 000 000 000 octets)"

// This no longer results in a crash.
let threeTerabytes = Int64(3_000_000_000_000)
threeTerabytes.formatted(
    .byteCount(
        style: .binary,
        allowedUnits: .tb,
        spellsOutZero: false,
        includesActualByteCount: true
    )
) // "2.73 TB (3,000,000,000,000 bytes)"
{% endsplash %}

Very handy.

## 3. New `Duration` Unit Support

iOS 16 introduces the new `Duration` unit, which is purpose built to deal with very accurate time measurements. There's two new styles to support it.

### TimeFormatStyle

The simpler of the two, this one is the default

{% splash %}
let coupleOfSeconds: Duration = .seconds(3)
{% endsplash %}

With it, they've added a new build in format style to allow us to output the values in a nice way:

{% splash %}
let thousandSeconds: Duration = .seconds(1000)

thousandSeconds.formatted() // "0:16:40"
thousandSeconds.formatted(.time(pattern: .hourMinute)) // "0:17"
thousandSeconds.formatted(.time(pattern: .hourMinute).locale(Locale(identifier: "fr_FR"))) // "0:17"
thousandSeconds.formatted(.time(pattern: .hourMinute(padHourToLength: 10, roundSeconds: .awayFromZero))) // "0,000,000,000:17"
thousandSeconds.formatted(.time(pattern: .hourMinuteSecond)) // "0:16:40"
thousandSeconds.formatted(.time(pattern: .hourMinuteSecond(padHourToLength: 3, fractionalSecondsLength: 3,  roundFractionalSeconds: .awayFromZero))) // "000:16:40.000"
thousandSeconds.formatted(.time(pattern: .minuteSecond)) // "16:40"
thousandSeconds.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 3, fractionalSecondsLength: 3, roundFractionalSeconds: .awayFromZero))) // "016:40.000"
{% endsplash %}

### UnitsFormatStyle

You can also use the `UnitsFormatStyle` to show the `Duration` as a different unit.

{% splash %}
let halfSecond: Duration = .milliseconds(500)
halfSecond.formatted(.units()) // "0 sec"
halfSecond.formatted(
    .units(allowed: [.milliseconds])
) // "500 ms"
halfSecond.formatted(
    .units(
        allowed: [.milliseconds],
        width: .abbreviated
    )
) // "500 ms"
halfSecond.formatted(
    .units(
        allowed: [.milliseconds],
        width: .condensedAbbreviated
    )
) // "500ms"
halfSecond.formatted(
    .units(
        allowed: [.milliseconds],
        width: .narrow
    )
)
halfSecond.formatted(
    .units(
        allowed: [.milliseconds],
        width: .wide
    )
) // "500 milliseconds"
halfSecond.formatted(
    .units(
        allowed: [.seconds, .milliseconds],
        width: .wide,
        maximumUnitCount: 2,
        zeroValueUnits: .show(length: 2),
        valueLength: 5,
        fractionalPart: .show(length: 2, rounded: .awayFromZero, increment: 0.000025)
    )
) // "00,000.000000 seconds, 00,500.000000 milliseconds"
{% endsplash %}

## 4. URL Support
There's a new, and surprisingly deep, format style for URLs that start simple:

{% splash %}
let appleURL = URL(string: "https://apple.com")!
appleURL.formatted() // "https://apple.com"
appleURL.formatted(.url) // "https://apple.com"
appleURL.formatted(.url.locale(Locale(identifier: "fr_FR"))) // "https://apple.com"
{% endsplash %}

And quickly descend into some nice complexity:

{% splash %}
var httpComponents = URLComponents(url: appleURL, resolvingAgainstBaseURL: false)!
httpComponents.scheme = "https"
httpComponents.user = "jAppleseed"
httpComponents.password = "Test1234"
httpComponents.host = "apple.com"
httpComponents.port = 80
httpComponents.path = "/macbook-pro"
httpComponents.query = "get-free"
httpComponents.fragment = "someFragmentOfSomething"

let complexURL = httpComponents.url!
let everythingStyle = URL.FormatStyle(
    scheme: .always,
    user: .always,
    password: .always,
    host: .always,
    port: .always,
    path: .always,
    query: .always,
    fragment: .always
)

everythingStyle.format(complexURL) // "https://jAppleseed:Test1234@apple.com:80/macbook-pro?get-free#someFragmentOfSomething"

let omitStyle = URL.FormatStyle(
    scheme: .omitIfHTTPFamily,
    user: .omitIfHTTPFamily,
    password: .omitIfHTTPFamily,
    host: .omitIfHTTPFamily,
    port: .omitIfHTTPFamily,
    path: .omitIfHTTPFamily,
    query: .omitIfHTTPFamily,
    fragment: .omitIfHTTPFamily
)

var httpsComponent = httpComponents
httpsComponent.scheme = "https"
let httpsURL = httpsComponent.url!

var ftpComponents = httpComponents
ftpComponents.scheme = "ftp"
let ftpURL = ftpComponents.url!

omitStyle.format(complexURL) // ""
omitStyle.format(httpsURL) // ""
omitStyle.format(ftpURL) // "ftp://jAppleseed@apple.com:80/macbook-pro?get-free#someFragmentOfSomething"
{% endsplash %}

## 5. Date.VerbatimFormatStyle Changes

There's a couple of significant changes to the Verbatim style. 

1. The style can now have the `locale` set.
2. You can access it using the `.verbatim()` extension on `FormatStyle`

{% splash %}
let twosday = Calendar(identifier: .gregorian).date(from: twosdayDateComponents)!

twosday.formatted(
    .verbatim(
        "\(hour: .defaultDigits(clock: .twentyFourHour, hourCycle: .oneBased)):\(minute: .defaultDigits):\(minute: .defaultDigits) \(dayPeriod: .standard(.wide))",
        locale: Locale(identifier: "zh_CN"),
        timeZone: .current,
        calendar: .current
    )
) // "2:22:22 上午"
{% endsplash %}

## Conclusion
Not a bad set of updates. It's nice to see new units getting new format styles immediately.