---
title: "Custom FormatStyle"
date: 2022-03-12T08:09:30-07:00
draft: false
tags: [ios15, formatstyle]
---

Using the built in implementations of FormatStyle provided by Apple can get you a long way. In fact, [checking the Apple Docs](https://developer.apple.com/documentation/foundation/formatstyle) provides a full list of them. You can format numbers, currency, percentages, dates, bytes, measurements, and even relative dates.

But if you're in a position where you'd like to add your own formatting styles (for whatever reason), you have the ability to do just that by creating your own `FormatStyle` struct.

For example, you could create a simple way to display any Integer as Yen using Swift's Decimal Currency features:

```Swift
struct ToYen: FormatStyle {
    typealias FormatInput = Int
    typealias FormatOutput = String

    func format(_ value: Int) -> String {
        Decimal(value * 100).formatted(.currency(code: "jpy"))
    }
}

// There has to be a better way
30.formatted(ToYen())
```
Conforming to the `FormatStyle` protocol is straightforward. The crux of it is that you need to define your `FormatInput` and `FormatOutput` types so that the compiler understands the ins and outs of your custom implementation.

> As an aside, it's interesting that the inputs and outputs are completely arbitrary. You could convert any type into any other type using this system, but that seems a bit overkill.

The issue now is that it's not terribly elegant or "Swifty" to constantly initialize the `ToYen()` FormatStyle every time that we want to use it. Thankfully, we can extend FormatStyle:

```Swift

struct ToYen: FormatStyle {
    typealias FormatInput = Int
    typealias FormatOutput = String

    func format(_ value: Int) -> String {
        Decimal(value * 100).formatted(.currency(code: "jpy"))
    }
}

extension FormatStyle where Self == ToYen {
    static var toYen: ToYen { .init() }
}

30.formatted(.toYen) // "¥3,000"
```

Easy.

Also. Don't use `Float` or `Double` types to store currency. Their imprecision is going to lead you to be very sad.