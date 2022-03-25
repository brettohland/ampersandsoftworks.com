---
title: "FormatStyle AttributedString Output"
date: 2022-03-24T09:05:43-06:00
draft: false
tags: [ios15, formatstyle, deepdive, development, swift, swiftui]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

Outputting `AttributedString` values instead of plain `String` values from a `FormatStyle` instance shows the hidden power of the `FormatStyle` protocol.

Apple has included support for `AttributedString` output in quite a few of their style implementations, and accessing it is as easy as calling `.attributed`.


<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

While not all styles are supported by default, currently we have support for:

- [Dates](/posts/formatstyle-deep-dive/date-and-formatstyle-and-you/)
	- [Date.FormatStyle.dateTime()](/posts/formatstyle/style-deep-dives/dates/datetime/)
	- [Date.VerbatimFormatStyle](/posts/formatstyle/style-deep-dives/dates/verbatim/)
- [Measurements.FormatStyle](/posts/formatstyle/style-deep-dives/measurement/)
- [ByteCountFormatStyle](/posts/formatstyle/style-deep-dives/bytecountformatstyle/)
- [PersonNameComponents.FormatStyle](/posts/formatstyle/style-deep-dives/personnamecomponents/)
- [Numerical Formatters](/posts/formatstyle/numerical)
	- [Number](/posts/formatstyle/style-deep-dives/numerical/number/)
	- [Currency](/posts/formatstyle/style-deep-dives/numerical/currency/)
	- [Percent](/posts/formatstyle/style-deep-dives/numerical/currency/)
	
If you're feeling limited by those provided (or if you have a fully custom FormatStyle), you can easily add support by rolling your own `FormatStyle`.	
	
[Details on outputting `AttributedString` values in custom `FormatStyle` implementations.](#adding-attributedstring-output-to-custom-format-styles)

<hr>

## Examples

```Swift
0.88.formatted(.percent.attributed)
```

Outputs:

![Attributed String Output for 88%](/images/2022/Mar/attributed-string-output.png)

<hr>

You can then bring to bear the power of the new `AttributedString` API in order to modify every aspect of the text for display:

```Swift
struct ContentView: View {
    var percentAttributed: AttributedString {
        var percentAttributedString = 0.8890.formatted(.percent.attributed)
        percentAttributedString.swiftUI.font = .title
        percentAttributedString.runs.forEach { run in
            if let numberRun = run.numberPart {
                switch numberRun {
                case .integer:
                    percentAttributedString[run.range].foregroundColor = .orange
                case .fraction:
                    percentAttributedString[run.range].foregroundColor = .blue
                }
            }

            if let symbolRun = run.numberSymbol {
                switch symbolRun {
                case .percent:
                    percentAttributedString[run.range].foregroundColor = .green
                case .decimalSeparator:
                    percentAttributedString[run.range].foregroundColor = .red
                default:
                    break
                }
            }
        }

        return percentAttributedString
    }

    var body: some View {
        VStack {
            Text(percentAttributed)
        }
        .padding()
    }
}
```

Will show:

![Attributed String Output for 88%](/images/2022/Mar/attributed-string-swiftui.png)

<hr>

# Adding AttributedString output to Custom Format Styles

To have your custom `FormatStyle` output `AttributedString` values, you simply have to create another `FormatStyle` that simply sets it's `FormatOutput` to `AttributedString`.

Once created, you can set the `.attributed` property on the original `FormatStyle` and call it:

```Swift
struct ToYen: FormatStyle {
    typealias FormatInput = Int
    typealias FormatOutput = String

    static let multiplier = 100
    static let formatter = IntegerFormatStyle<Int>.Currency.currency(code: "jpy")

    var attributed: ToYen.AttributedStyle = AttributedStyle()

    func format(_ value: Int) -> String {
        (value * ToYen.multiplier).formatted(ToYen.formatter)
    }
}

extension ToYen {
    struct AttributedStyle: FormatStyle {
        typealias FormatInput = Int
        typealias FormatOutput = AttributedString

        func format(_ value: Int) -> AttributedString {
            (value * ToYen.multiplier).formatted(ToYen.formatter.attributed)
        }
    }
}

extension FormatStyle where Self == ToYen {
    static var toYen: ToYen { .init() }
}

30.formatted(ToYen()) // "¥3,000"
30.formatted(.toYen) // "¥3,000"
30.formatted(ToYen().attributed)
30.formatted(.toYen.attributed)
```

<hr>

### One issue

The compiler will have issue if you attempt the following:

```Swift
Text(0.555, format: .percent.attributed)
```

```
error: Attributed String Support.xcplaygroundpage:38:13: error: initializer 'init(_:format:)' requires the types 'FloatingPointFormatStyle<Double>.Attributed.FormatOutput' (aka 'AttributedString') and 'String' be equivalent
````

This is simply because the `Text(_: format:)` initializer expects that the `FormatOutput` type associated with the passed in `FormatStyle` is of type `String`. You have to use the initializer that accepts the `AttributedString` type as a parameter.

Which is completely understandable, passing an unmodified `AttributedString` into a `TextView` seems of limited use.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>