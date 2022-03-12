---
title: "FormatStyle Deep Dive"
date: 2022-03-12T09:44:41-07:00
draft: false
tags: [ios15, formatstyle, deepdive]
---

Apple introduced the new `FormatStyle` protocol with iOS 15. It allows for some truly remarkable things to happen when you're converting your data into localized strings. 

In true Apple fashion though, details about how to use these new features are lightly documented with few examples.

The breadth and depth that this new functionality has been added to Swift is really nice, Apple has added support for it on nearly all data types in Swift. You also have the ability to create custom `FormatStyle` implementations that allow you to arbitrarily convert types using this functionality.

To use this functionality in the past, you would have needed to create a new instance of the various `Formatter` subclasses on offer (`DateFormatter`, `NumberFormatter`, etc), configure it, and then use the instance to output our localized string. This came with the large gotcha that instantiating these formatters were expected, and you needed to know that you had to cache these somewhere in your app for quick reuse.

No more. According to Apple, the system is using these formatters under the hood and they're now handling the creation and cacheing of these objects for you.

[See a list of all posts in this series](/tags/formatstyle/)

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e)

In this post:

- [The Basics](#the-basics)
- [Customization Option Deep Dives](#customization-options)
- [Custom FormatStyle`](#creating-custom-formatstyle)

<hr>

# The Basics

You can access this new system in a few ways:

1. Call `.formatted()` on a data type for a sensible, localized default
2. Call `.formatted(_: FormatStyle)` on a data type and pass in a pre-defined or custom FormatStyle to customize your output
3. Call `.format()` on a custom FormatStyle and pass in a data value

## Sensible Defaults

At its most basic, to calling `.formatted()` with give you sensible default that uses your device's current locale and calendar to display the value.

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

> Note: My system is using the "en_US" locale, and the Gregorian calendar.

In general, these are useful to quickly convert your values into strings.

<hr>

# Customization Options

For every data type that's supported by the new system, Apple has provided ways to customize your string output in many different ways. The most granular customizations will use the device's locale and calendar, while a smaller subset will let you set them specifically.

Here are the deep-dives for each of the types, and their various customization options.

- [Formatting Dates](/posts/date-and-formatstyle-and-you)
- [Formatting Relative Dates](/posts/formatstyle-relative-dates/)
- Measurements
- Lists
- Numbers
- Decimals
- Names
- Lists
- TimeIntervals

<hr>

# Creating Custom FormatStyle

If Apple's built-in customization options aren't up to your liking. You can create new and exciting FormatStyles to suit any and all needs.

[Creating Custom FormatStyles](/posts/custom-formatstyles)