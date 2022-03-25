---
title: "SwiftUI & FormatStyle"
date: 2022-03-16T09:49:36-06:00
draft: false
tags: [ios15, formatstyle, deepdive, development, swift, swiftui]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

The `Text` View struct now can accept any data type and a `formatted: FormatStyle` parameter. The view will then apply that formatter onto that data type and render the string on screen.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

Never write `Text("\()")` again. Just pass in the right `FormatStyle`.

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

Will show:

![](/images/2022/Mar/text-date-formatter.png)

Every data type and style is supported. [Check out the full deep dive!](/posts/formatstyle-deep-dive/)

<hr>

# Attributed Strings

`Text` views can accept `AttributedStrings` as a parameter in their initializers. Most of the `FormatStyle` implementations provided by apple have the ability to output `AttributedString` values instead of plain `String` types.

[The `AttributedStrings` Deep Dive has full details on this.](/posts/formatstyle/style-deep-dives/attributed-strings/)

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>