---
title: "Measurement.FormatStyle"
date: 2022-03-13T21:09:18-06:00
draft: false
tags: [ios15, formatstyle, deepdive]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

The Measurement.FormatStyle is able to handle the various associated units of the Measurement class easily, there is one small caveat that you need to explicitly state the Unit when creating a custom instance of the style.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e)

<hr>

```Swift
let gForce = Measurement(value: 1.0, unit: UnitAcceleration.gravity)
let mpsec = Measurement(value: 1.0, unit: UnitAcceleration.metersPerSecondSquared)

gForce.formatted(.measurement(width: .wide))        // "1 g-force"
gForce.formatted(.measurement(width: .narrow))      // "1G"
gForce.formatted(.measurement(width: .abbreviated)) // "1 G"

gForce.formatted(.measurement(width: .wide).locale(franceLocale))        // "1 fois l’accélération de pesanteur terrestre"
gForce.formatted(.measurement(width: .narrow).locale(franceLocale))      // "1G"
gForce.formatted(.measurement(width: .abbreviated).locale(franceLocale)) // "1 force g"
```

> Note: I'm only showing `UnitAcceleration` here, but the formatter will work with every one available to you.

The simple way to get set the locale is to use the `.locale()` call:

```Swift
let franceLocale = Locale(identifier: "fr_FR")

gForce.formatted(.measurement(width: .wide).locale(franceLocale))        // "1 fois l’accélération de pesanteur terrestre"
gForce.formatted(.measurement(width: .narrow).locale(franceLocale))      // "1G"
gForce.formatted(.measurement(width: .abbreviated).locale(franceLocale)) // "1 force g"
```

## Customizing

Because of the associated type shenanigans of the `Measurement` class, there are two separate initializers, one specific for when you're using `UnitTemperature` measurements.

```Swift
let inFrench = Measurement<UnitAcceleration>.FormatStyle(
    width: .wide,
    locale: Locale(identifier: "fr_FR"),
    usage: .general
)

inFrench.format(gForce)     // "1 fois l’accélération de pesanteur terrestre"
gForce.formatted(inFrench)  // "1 fois l’accélération de pesanteur terrestre"
```

> Notice that you have to explicitly set your unit.

And finally, to create a fully custom solution:

```Swift
struct InFrench: FormatStyle {
    typealias FormatInput = Measurement<UnitAcceleration>
    typealias FormatOutput = String

    static let formatter = Measurement<UnitAcceleration>.FormatStyle(
        width: .wide,
        locale: Locale(identifier: "fr_FR"),
        usage: .general
    )

    func format(_ value: Measurement<UnitAcceleration>) -> String {
        InFrench.formatter.format(value)
    }
}

extension FormatStyle where Self == InFrench {
    static var inFrench: InFrench { .init() }
}

gForce.formatted(.inFrench) // "1 fois l’accélération de pesanteur terrestre"
```
<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e)

<hr>