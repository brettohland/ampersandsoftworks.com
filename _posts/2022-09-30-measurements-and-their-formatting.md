---
layout: post
title: Over 3,000 Words On What The Measurement Type Is And Why You Should Be Using It
description: So much power to convert, do math on, and localize the display of your measurement values at your fingertips… yet no one uses it.
tags: [ios, development, swift, formatstyle]
date: 2022-09-30 06:21 -0600
---

Foundation's `Measurement` type is an incredibly useful tool in an Apple developer's toolkit. It's a purpose-built type for storing, converting, and calculating the sum of physical measurements with a powerful localization system built on top of it. It's a relatively new API that was introduced with Xcode 8 in 2016 and is supported by iOS 10+, macOS 10.12+, Mac Catalyst 13.0+, tvOS 10.0+, watchOS 3.0+.

From personal experience, there's a hesitation to use this type in production code. I think the biggest reasons are that Apple hasn't done a great job in selling devs on the benefits of the type, and that the powerful localization features were locked behind a clunky `MeasurementFormatter`. 

It may seem overkill to wrap that temperature or distance value in an addition layer of complexity, especially if your app will never be released outside of the US market. But I'd like to change your mind on that.

Let's walk though `Measurement`, how to use it, how to convert things using it, and how to localize its output. At the end I hope I've convinced you to use it in your code starting tomorrow.

> This post is all about the Swift API for `Measurement`. Know that these are accessible in Objective-C as `NSMeasurement`, and nearly everything mentioned in this post is available to you. Unfortunately the `Measurement<UnitType>.FormatStyle` is Swift-only, you'll need to rely on the `NSMeasurementFormatter` for localization.

## Measurement Basics

To be a good developer in a type-safe language, you should be using the appropriate types for the data in question. Strings should be `String`, Numbers should be `Int`, `Float` or `Decimal` as needed and those measurements of physical properties should be a `Measurement`.

The `Measurement` type requires that you associate your measurement value with a unit. Makes sense. 

{% splash %}

struct Measurement<UnitType> where UnitType : Unit

{% endsplash %}

But here we have run into the first knowledge hurdle about the API: **What units are even supported?**

As of Xcode 14, this is the canonical list of Dimensions [^1] that are supported:

| Dimension [^1]                                                                                          | Description                                       | Base unit                           |
| ------------------------------------------------------------------------------------------------------- | ------------------------------------------------- | ----------------------------------- |
| [Unit Acceleration](https://developer.apple.com/documentation/foundation/unitacceleration)              | Unit of measure for acceleration                  | meters per second squared (m/s²)    |
| [Unit Angle](https://developer.apple.com/documentation/foundation/unitangle)                            | Unit of measure for planar angle and rotation     | degrees (°)                         |
| [Unit Area](https://developer.apple.com/documentation/foundation/unitarea)                              | Unit of measure for area                          | square meters (m²)                  |
| [Unit Mass](https://developer.apple.com/documentation/foundation/unitconcentrationmass)                 | Unit of measure for concentration of mass         | grams per liter (g/L)               |
| [Unit Dispersion](https://developer.apple.com/documentation/foundation/unitdispersion)                  | Unit of measure for dispersion                    | parts per million (ppm)             |
| [Unit Duration](https://developer.apple.com/documentation/foundation/unitduration)                      | Unit of measure for duration of time              | seconds (sec)                       |
| [Unit Charge](https://developer.apple.com/documentation/foundation/unitelectriccharge)                  | Unit of measure for electric charge               | coulombs (C)                        |
| [Unit Current](https://developer.apple.com/documentation/foundation/unitelectriccurrent)                | Unit of measure for electric current              | amperes (A)                         |
| [Unit Difference](https://developer.apple.com/documentation/foundation/unitelectricpotentialdifference) | Unit of measure for electric potential difference | volts (V)                           |
| [Unit Resistance](https://developer.apple.com/documentation/foundation/unitelectricresistance)          | Unit of measure for electric resistance           | ohms (Ω)                            |
| [Unit Energy](https://developer.apple.com/documentation/foundation/unitenergy)                          | Unit of measure for energy                        | joules (J)                          |
| [Unit Frequency](https://developer.apple.com/documentation/foundation/unitfrequency)                    | Unit of measure for frequency                     | hertz (Hz)                          |
| [Unit Efficiency](https://developer.apple.com/documentation/foundation/unitfuelefficiency)              | Unit of measure for fuel efficiency               | liters per 100 kilometers (L/100km) |
| [Unit Illuminance](https://developer.apple.com/documentation/foundation/unitilluminance)                | Unit of measure for illuminance                   | lux (lx)                            |
| [Unit Storage](https://developer.apple.com/documentation/foundation/unitinformationstorage)             | Unit of measure for quantities of information     | bytes (b)                           |
| [Unit Length](https://developer.apple.com/documentation/foundation/unitlength)                          | Unit of measure for length                        | meters (m)                          |
| [Unit Mass](https://developer.apple.com/documentation/foundation/unitmass)                              | Unit of measure for mass                          | kilograms (kg)                      |
| [Unit Power](https://developer.apple.com/documentation/foundation/unitpower)                            | Unit of measure for power                         | watts (W)                           |
| [Unit Pressure](https://developer.apple.com/documentation/foundation/unitpressure)                      | Unit of measure for pressure                      | newtons per square meter (N/m²)     |
| [Unit Speed](https://developer.apple.com/documentation/foundation/unitspeed)                            | Unit of measure for speed                         | meters per second (m/s)             |
| [Unit Temperature](https://developer.apple.com/documentation/foundation/unittemperature)                | Unit of measure for temperature                   | kelvin (K)                          |
| [Unit Volume](https://developer.apple.com/documentation/foundation/unitvolume)                          | Unit of measure for volume                        | liters (L)                          |

[^1]: [Apple's documentation refers to these units as subclasses of `Dimension`](https://developer.apple.com/documentation/foundation/dimension), which is "An abstract class representing a dimensional unit of measure.".

Each of these Dimensions have a number of units available. Here's every unit for `UnitLength` as an example:

| Name               | Method            | Symbol | Coefficient |
|--------------------|-------------------|--------|-------------|
| Megameters         | megameters        | Mm     | 1000000.0   |
| Kilometers         | kilometers        | kM     | 1000.0      |
| Hectometers        | hectometers       | hm     | 100.0       |
| Decameters         | decameters        | dam    | 10.0        |
| Meters             | meters            | m      | 1.0         |
| Decimeters         | decimeters        | dm     | 0.1         |
| Centimeters        | centimeters       | cm     | 0.01        |
| Millimeters        | millimeters       | mm     | 0.001       |
| Micrometers        | micrometers       | µm     | 0.000001    |
| Nanometers         | nanometers        | nm     | 1e-9        |
| Picometers         | picometers        | pm     | 1e-12       |
| Inches             | inches            | in     | 0.0254      |
| Feet               | feet              | ft     | 0.3048      |
| Yards              | yards             | yd     | 0.9144      |
| Miles              | miles             | mi     | 1609.34     |
| Scandinavian Miles | scandinavianMiles | smi    | 10000       |
| Light Years        | lightyears        | ly     | 9.461e+15   |
| Nautical Miles     | nauticalMiles     | NM     | 1852        |
| Fathoms            | fathoms           | ftm    | 1.8288      |
| Furlongs           | furlongs          | fur    | 201.168     |
| Astronomical Units | astronomicalUnits | ua     | 1.496e+11   |
| Parsecs            | parsecs           | pc     | 3.086e+16   |

I'd recommend that you check out [Apple's documentation for each of the Dimensions](https://developer.apple.com/documentation/foundation/dimension) to get a good idea of every possible unit available to you.

Creating a new measurement is as easy as setting the value and declaring it's `Dimension` and it's unit:

{% splash %}

let speedLimit = Measurement(value: 100, unit: UnitSpeed.kilometersPerHour)
let myHeight = Measurement(value: 190, unit: UnitLength.centimeters)
let drivingDistance = Measurement(value: 200, unit: UnitLength.kilometers)
let averageBaseballThrow = Measurement(value: 70, unit: UnitLength.feet)
let bodyTemperature = Measurement(value: 98.5, unit: UnitTemperature.fahrenheit)
let aNiceDay = Measurement(value: 25.0, unit: UnitTemperature.celsius)

// Alternatively, declare the Dimension and only set the unit.
let coldDay: Measurement<UnitTemperature> = .init(value: -30, unit: .celsius)
{% endsplash %}

Once created, you can think of that value as a unit-agnostic representation of the `Dimension`. While you had initialized that speed limit as kilometers per hour, you should immediately stop thinking of it in that way. This is the completely opposite of simply storing these values as an `Int`, `Double`, `Float`, or `Decimal` as you'd be needing to keep that unit in mind at all times when working with the unit.

However, it is important to know that under the hood the value is tied to the unit it's initialized with. This only really comes into play when you're using the `MeasurementFormatStyle` to output your measurement as a nice looking string. This is detailed later on.

## Calculating Sums

Once you have your unit agnostic dimensional value, you can then do math on several unit agnostic dimensional values! Units no longer matter, as long as everything shares the same `Dimension`:

{% splash %}

let myWalkingDistance = Measurement(value: 20, unit: UnitLength.fathoms)
let yourSwimmingDistance = Measurement(value: 10, unit: UnitLength.nauticalMiles)

let ourDistance = myWalkingDistance + yourSwimmingDistance // 18556.576 m

{% endsplash %}

## Unit Conversions

The best part about having your value stored in an agnostic fashion is that you can rely on the system to do your unit conversions for you.

To use, simply call `converted(to:)` on the Measurement which will return a Measurement in that new unit.

{% splash %}

let calgaryTemperature = Measurement(value: 9, unit: UnitTemperature.celsius)
let bostonTemperature = Measurement(value: 58, unit: UnitTemperature.fahrenheit)
let marsTemperature = Measurement(value: -112, unit: UnitTemperature.fahrenheit)
let surfaceOfTheSunTemperature = Measurement(value: 5772, unit: UnitTemperature.kelvin)

calgaryTemperature.converted(to: .celsius) // 9.0 °C
bostonTemperature.converted(to: .celsius) // 14.444444444446788 °C
marsTemperature.converted(to: .celsius) // -79.99999999999841 °C
surfaceOfTheSunTemperature.converted(to: .celsius) // 5498.85 °C

{% endsplash %}

There's also the `convert(to:)` method, which will modify the internal unit of that Measurement. Again, this is used in specific cases when outputting string values.

# Custom Units

[Apple outlines how to create a custom Dimension, and extending Dimensions with a custom `Unit` on a provided `Dimension`.](https://developer.apple.com/documentation/foundation/dimension)

{% splash %}

// A custom one-off Unit (https://en.wikipedia.org/wiki/Smoot)
let smoots = UnitLength(symbol: "smoot", converter: UnitConverterLinear(coefficient: 1.70180))

// Extending a Dimension to include a custom Unit
extension UnitSpeed {
    static let furlongPerFortnight = UnitSpeed(
        symbol: "fur/ftn",
        converter: UnitConverterLinear(coefficient: 201.168 / 1209600.0)
    )
}

// Fully custom Dimension subclass
class CustomRadioactivityUnit: Dimension {
    static let becquerel = CustomRadioactivityUnit(symbol: "Bq", UnitConverterLinear(coefficient: 1.0))
    static let curie = CustomRadioactivityUnit(symbol: "Ci", UnitConverterLinear(coefficient: 3.7e10))
    static let baseUnit = self.becquerel
}

{% endsplash %}


# Pretty Strings

**TL;DR: Measurement outputs are localized, and this can cause unexpected output.**

Having your data nicely represented as unit agnostic values is one thing, but showing them to your users is another thing all together.

In the past, you had to rely on the `MeasurementFormatter` class to handle this job. It was clunky to work with as you had to initialize a new instance of the formatter for every different output style that you wanted to show. And similar to the `DateFormatter` initializing them is expensive so you _should_ be storing these instances in a shared location to avoid re-creating them as much as humanly possible.

That all changed with iOS 15 and `FormatStyle`, which created an extremely simplified API to convert your data into pretty strings. Unfortunately, Apple's documentation is sparse on this topic, so I [created an entire site to document and show off what this system can do](https://goshdarnformatstyle.com).

## Simple FormatStyle Output

At it's most basic, you can simply call `.formatted()` onto any Measurement instance and get a nice looking string out of it:

{% splash %}

let speedLimit = Measurement(value: 100, unit: UnitSpeed.kilometersPerHour)
let myHeight = Measurement(value: 190, unit: UnitLength.centimeters)
let drivingDistance = Measurement(value: 200, unit: UnitLength.kilometers)
let averageBaseballThrow = Measurement(value: 70, unit: UnitLength.feet)
let averageWeight = Measurement(value: 197.9, unit: UnitMass.pounds)
let bodyTemperature = Measurement(value: 98.5, unit: UnitTemperature.fahrenheit)

speedLimit.formatted() // "62 mph"
myHeight.formatted() // "6.2 ft"
drivingDistance.formatted() // "124 mi"
averageBaseballThrow.formatted() // "70 ft"
averageWeight.formatted() // "198 lb"
bodyTemperature.formatted() // "98°F"

{% endsplash %}

Useful for debugging or simple output, but you almost certainly want more control of things.

To customize the output, we can access the `.measurement(width:usage:numberFormatStyle)` extension on `FormatStyle` and pass in different options for the three parameters.

| Parameter                      | Accepted Type                                 | Description                         |
| ------------------------------ | --------------------------------------------- | ----------------------------------- |
| `width`                        | `Measurement<UnitType>.FormatStyle.UnitWidth` | Sets how verbose the output is      |
| `usage` (optional)             | `MeasurementFormatUnitUsage<UnitType>`        | Sets how the unit will be used      |
| `numberFormatStyle` (optional) | `FloatingPointFormatStyle<Double>`            | Sets the format style on the number |

Explaining how each of these parameters interact with each other, and how this all ties into the `Measurement<UnitType>.FormatStyle` struct that backs this whole feature means we need to discuss this system from the ground up.
  
## Width parameter

Before we dive deeply into the details, we can cover the `width` parameter quickly. There are three possible options:

| Width          | Description                                         |
| -------------- | --------------------------------------------------- |
| `.wide`        | Displays the full unit description                  |
| `.abbreviated` | Displays an abbreviated unit description            |
| `.narrow`      | Displays the unit in the least number of characters |

In general, `wide` will spell out the name of the unit in the most verbose way possible. `.abbreviated` will output the shortened version of the unit, and `.narrow` will remove any whitespace characters.

{% splash %}

let gForce = Measurement(value: 1.0, unit: UnitAcceleration.gravity)

gForce.formatted(.measurement(width: .wide)) // "1 g-force"
gForce.formatted(.measurement(width: .narrow)) // "1G"
gForce.formatted(.measurement(width: .abbreviated)) // "1 G"

{% endsplash %}

## The Nitty and the Gritty

[TL;DR: I've updated goshdarnformatstyle.com with all of this info if you just want to see the available options.](https://goshdarnformatstyle.com/measurement-style/)

I've detailed how the `FormatStyle` protocol works by creating one for my own custom type (the ISBN) [in an earlier post](https://ampersandsoftworks.com/posts/formatstyle-parseableformatstyle-and-your-custom-types/). It's a great primer on understanding _how_ the system is implemented under the hood by Apple's engineers.

The `.formatted()` method on any Measurement instance accepts an optional parameter that conforms to the [`FormatStyle` protocol](https://developer.apple.com/documentation/foundation/formatstyle). The protocol itself is quite simple: You define an input type, an output type, and you get a method to do your conversion. That's it.

We can create an instance of our format style by initializing an instance with it's `Dimension`. This is how it's defined in the documentation:

{% splash %}

public init(
    width: Measurement<UnitType>.FormatStyle.UnitWidth,
    locale: Locale = .autoupdatingCurrent,
    usage: MeasurementFormatUnitUsage<UnitType> = .general,
    numberFormatStyle: FloatingPointFormatStyle<Double>? = nil
)

{% endsplash %}

Interestingly enough, there's a special initializer with an extra parameter that's available only when you're creating a new instance with the `UnitTemperature` Dimension:

{% splash %}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Measurement.FormatStyle where UnitType == UnitTemperature {

    /// Hides the scale name. For example, "90°" rather than "90°F" or "90°C" with the `narrow` unit width, 
    /// or "90 degrees" rather than "90 degrees celcius" or "90 degrees fahrenheit" with the `wide` width.
    public var hidesScaleName: Bool

    public init(
        width: Measurement<UnitType>.FormatStyle.UnitWidth = .abbreviated,
        locale: Locale = .autoupdatingCurrent,
        usage: MeasurementFormatUnitUsage<UnitType> = .general,
        hidesScaleName: Bool = false,
        numberFormatStyle: FloatingPointFormatStyle<Double>? = nil
    )
}

{% endsplash %}

The extra option allows us to omit the output of the temperature scale in the final string. Thanks to the magic of protocol extensions with `where` clauses, this is only available when our `UnitType` is `UnitTemperature`.

With this understanding, we can create a new instance of our format style and use it to format our measurement by using the `.formatted()` method on the measurement _OR_ using the `.format()` method on our format style.

{% splash %}

let myHeight = Measurement(value: 190, unit: UnitLength.centimeters)
let measurementStyle = Measurement<UnitLength>.FormatStyle(width: .wide)

myHeight.formatted(measurementStyle) // "6.2 feet"
measurementStyle.format(myHeight) // "6.2 feet"

{% endsplash %}

But this brings up some issues and questions related to the output: "6.2 feet"?

1. Why am I getting "feet" as my output when I created it using `UnitLength.centimetres`?
2. Why am I getting fractional feet as my output? No one uses that for a person's height!

Answering both questions means we need to understand how the format style uses the `locale` and `usage` parameters together to create our output.

### Obfuscated Localization

As a quick aside, you need to know that the string output of the `.formatted()` method on a `Measurement` instance is non-deterministic between different devices.

Because by default, the measurement format style will use the device's current locale, this means that two developers _can_ get different output by the simple fact that their devices are set to different locales.

{% splash %}

let myHeight = Measurement(value: 190, unit: UnitLength.centimeters)
let measurementStyle = Measurement<UnitLength>.FormatStyle(width: .wide)

// When the device's Locale is US (en-US)
myHeight.formatted(measurementStyle) // "6.2 feet"

// When the device's Local is Sweden (sv-SE)
myHeight.formatted(measurementStyle) // "1.9 m"

{% endsplash %}

### That FormatStyle extension

Creating instances of `Measurement<UnitType>.FormatStyle` isn't how you should be interacting with the system. At all. You're much better off using the `.measurement(width:usage:numberFormatStyle)` extension on `FormatStyle` directly.

The `usage` and `numberFormatStyle` parameters are optional. And to specify the `Locale`, you can simply hang the `.locale()` off the end:

{% splash %}

let usa = Locale(identifier: "en-US")
let sweden = Locale(identifier: "sv-SE")

let myHeight = Measurement(value: 190, unit: UnitLength.centimeters)

myHeight.formatted(.measurement(width: .abbreviated, usage: .general).locale(usa)) // "6.2 ft"
myHeight.formatted(.measurement(width: .abbreviated, usage: .general).locale(sweden)) // "1.9 m"

{% endsplash %}

We're going to be using this from now on.

### Usage Is Very Important

Let's answer both of those earlier questions with the same unsatisfying answer:

1. Why am I getting "feet" as my output when I created it using `UnitLength.centimetres`?
2. Why am I getting fractional feet as my output? No one uses that for a person's height!

That's easy: Because the default `usage` parameter is `.general` and the default `Locale` is `en-US` when you're using an Xcode Playground.

But seriously, let's get into more detail.

The `usage` parameter is interesting because while there are two shared options, Apple provides some specialized usages depending on your `Dimension` that is used.

The shared options are:

| Option        | Description                                                                         |
| ------------- | ----------------------------------------------------------------------------------- |
| `.general`    | Outputs the value in the most generalized way for the given locale                  |
| `.asProvided` | Outputs a string value of the unit the `Dimension` was created with or converted to |

Therefore this means that for the US English locale, the system defines fractional feet as the output when the `.general` usage parameter is used. Whereas for the Sweden Swedish locale defines the `.general` usage parameter as outputting fractional metres.

If we switch up the usage on the above code to use the `.asProvided` option, we'd get the output in the original units regardless of the Locale:

{% splash %}

let usa = Locale(identifier: "en-US")
let sweden = Locale(identifier: "sv-SE")

let myHeight = Measurement(value: 190, unit: UnitLength.centimeters)

myHeight.formatted(.measurement(width: .abbreviated, usage: .asProvided).locale(usa)) // "190 cm"
myHeight.formatted(.measurement(width: .abbreviated, usage: .asProvided).locale(sweden)) // "190 cm"

{% endsplash %}

To answer the second question, we need to detail the usage options that are available to us only when the `Dimension` is `UnitLength`.

#### MeasurementFormatUnitUsage

All of the custom usages are static properties on the `MeasurementFormatUnitUsage` struct ([you can check Apple's docs here](https://developer.apple.com/documentation/foundation/measurementformatunitusage)). But here are all of the custom usages available to us when we use the `UnitLength` `Dimension`.

| Option          | Description                              |
| --------------- | ---------------------------------------- |
| `.person`       | For distances as they relate to a person | 
| `.personHeight` | For displaying a person's height         |
| `.road`         | For distances while driving              |
| `.focalLength`  | For the focal length of optics           |
| `.rainfall`     | For displaying rainfall values           |
| `.snowfall`     | For displaying snowfall values           |

Look at that, we have a special usage option for displaying someone's height.

{% splash %}

let usa = Locale(identifier: "en-US")
let sweden = Locale(identifier: "sv-SE")

let myHeight = Measurement(value: 190, unit: UnitLength.centimeters)

myHeight.formatted(.measurement(width: .abbreviated, usage: .personHeight).locale(usa)) // "6 ft, 2.8 in"
myHeight.formatted(.measurement(width: .abbreviated, usage: .personHeight).locale(sweden)) // "1 m, 90 cm"

{% endsplash %}

Better. Much better. We now get the height in the customary units of feet and inches for the US locale and metres and centimetres for the Sweden locale.

## Formatting the number

Our new string is a lot better than before, there is one issue though: The fractional inches.

Colloquially in the US, you give your height in whole values for feet and inches so we need to somehow remove or round that inches value. This is where that final `numberFormatStyle` parameter comes in. As you can guess by looking at the name, this is simply another format style we provide to our `Measurement<UnitType>.FormatStyle`. In this case is specifically a `FloatingPointFormatStyle<Double>` format style.

This format style is complicated and powerful. If you're looking for a detailed explanation of it, you can see my [write up on the goshdarnformatstyle.com site](https://goshdarnformatstyle.com/numeric-styles/#number-style). But for our uses here, we can see how to both round the value up and remove all fractional digits:

{% splash %}

let usa = Locale(identifier: "en-US")
let sweden = Locale(identifier: "sv-SE")

let myHeight = Measurement(value: 190, unit: UnitLength.centimeters)

myHeight.formatted(
    .measurement(
        width: .abbreviated,
        usage: .personHeight,
        numberFormatStyle: .number.precision(.fractionLength(0))
    ).locale(usa)
) // "6 ft, 3 in"

myHeight.formatted(
    .measurement(
        width: .abbreviated,
        usage: .personHeight,
        numberFormatStyle: .number.precision(.fractionLength(0))
    ).locale(sweden)
) // "1 m, 90 cm"

{% endsplash %}

# The Hard Sell

You can now see why storing your physical values as `Measurement` types can unlock some incredible features inside of your app. Converting and doing math on these values can be helpful, but the real power comes in when you get so much localization power for free.

Even though a country officially uses one set of units, colloquially a population can use different sets of units depending on the situation. Canadians give out their height and weight in imperial units, British roads use miles per hour as their speed, etc. Much like using the `Date` type to store dates [removes so many common date mistakes](https://gist.github.com/timvisee/fcda9bbdff88d45cc9061606b4b923ca), using `Measurement` for store and format your measurements saves you from having an encyclopedic knowledge of local customs.

The next time you're faced with using a physical measurement value, it may be tempting to simply store it as a numeric type. But I hope now you see the power in fully embracing using `Measurement` from now on.

---