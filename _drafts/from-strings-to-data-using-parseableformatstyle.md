---
layout: post
title: ParseableFormatStyle, Your New Friend
---

The venerable `(NS)Formatter` class (and Apple's various subclasses) were an Objective-C based API that let you do some very powerful conversions from data types to strings. One of the lesser-known super powers of these classes were the ability to the reverse: Parse strings into their respective data types.

`FormatStyle`, the protocol that handles the conversion _from_ a type to another, and Apple has provided a comprehensive set of APIs to convert nearly all of the buil-in `Foundation` data types into strings and attributed strings.

> If you're wanting to see the full power of FormatStyle, including examples of everything it can output. I built an entier site for it: [goshdarnformatstyle.com](https://goshdarnformatstyle.com)

But what about the reverse?. How do we use our new `FormatStyle` to parse someting _into_ out data type? Well, Apple provides us with another new protocol to handle this: `ParseableFormatStyle`.

# Let's Build Something
I learn best by doing, so let's do just that. We'll define new data type and slowly add the necessary protocol conformances and implementations to get us to something that can be use to convert to or from strings.

> See the final code here as a [Gist]() or [Playground]()

## The Plan

We're going to go through this [step-by-step](https://en.wikipedia.org/wiki/Step_by_Step_(TV_series)):

1. Define a new data type
1. Define a FormatStyle struct to handle all of this functionality, then have it conform to the `FormatStyle` protocol
2. Define a way that the user can customize how the output of the formatter (and implement it)
3. Add some convenience methods onto the new data type to make accessing the formatter easy
3. Define a ParseStrategy struct that will define ways to parse the new data type, then have it conform to the `ParseStrategy` protocol
3. Have the original FormatStyle struct conform to the `ParseableFormatStyle` protocol
4. Add some convenience methods to make accessing the parsing code easy

Not going to lie, there's a lot of steps to go through before we have our shiny new data type with formatting and parsing functionality. One criticism that I have about this whole system is that because it's a set of protocols working together, the discoverability is quite low.

> A note about style: This example uses extension extensively. Because of the complexity of the implementation, this is an attempt to make each piece clear, concise, and understandable.

## Our Data Type: ISBN

A good candidate for some structured data is an [International Standard Book Number(ISBN)](https://en.wikipedia.org/wiki/ISBN):

{% splash %}
struct ISBN: Codable, Sendable, Equatable, Hashable {
    let prefix: String
    let registrationGroup: String
    let registrant: String
    let publication: String
    let checkDigit: String
}
{% endsplash %}

## Handling Formatting to String

> I patterned this example after the [URL FormatStyle and ParseStyle Proposal](https://forums.swift.org/t/url-formatstyle-and-parsestrategy/56607) from the Swift mailing list that was ultimately included in iOS 16.

The first step is to create a FormatStyle struct that will ultimately conform to both the `FormatStyle` and `ParseableFormatStyle` protocols. 

{% splash %}
extension ISBN {
    struct FormatStyle: Codable, Sendable, Hashable {
        enum DelimiterStrategy: Codable {
            case hyphen
            case none
        }

        let strategy: DelimiterStrategy

        init(delimiter strategy: DelimiterStrategy = .hyphen) {
            self.strategy = strategy
        }
    }
}
{% endsplash %}

The `ISBN.FormatStyle` struct is quite simple. It declares the `DelimiterStrategy` enum that will allow us to output strings with or without hypens delimiting each section of the ISBN ("978-17-85889-01-1" vs "9781785889011").

You'll notice, that we haven't actually conformed to the `FormatStyle` protocol, let's do that now:

{% splash %}
extension ISBN.FormatStyle: FormatStyle {
    func format(_ value: ISBN) -> String {
        switch strategy {
        case .hyphen:
            return "\(value.prefix)-\(value.registrationGroup)-\(value.registrant)-\(value.publication)-\(value.checkDigit)"
        case .none:
            return "\(value.prefix)\(value.registrationGroup)\(value.registrant)\(value.publication)\(value.checkDigit)"
        }
    }
}
{% endsplash %}

There are two associated types required by the Protocol: `FormatInput` and `FormatOutput`. In this case, our input type is `ISBN` and our output is `String`.

We switch off of the `DelimiterStrategy` enum in order to modify our final output string.

At this point, we have a functional `FormatStyle`. We can pass an instance of an ISBN into 

{% splash %}
let isbn = ISBN(
    prefix: "978",
    registrationGroup: "17",
    registrant: "85889",
    publication: "01",
    checkDigit: "1"
)

ISBN.FormatStyle().format(isbn) // "978-17-85889-01-1"
ISBN.FormatStyle(delimiter: .none).format(isbn) // "9781785889011"
{% endsplash %}

## Adding Formatting Conveniences

We can extend our `ISBN` struct with some formatted methods to follow Apple's lead and let us access our string output as easily as possible. 

{% splash %}
extension ISBN {
  
    // 1
    func formatted() -> String {
        ISBN.FormatStyle().format(self)
    }

    // 2
    public func formatted<F: Foundation.FormatStyle>(_ format: F) -> F.FormatOutput where F.FormatInput == ISBN {
        format.format(self)
    }
}

// 3
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension FormatStyle where Self == ISBN.FormatStyle {
    static var isbn: Self { .init() }
}

// 4
extension ISBN.FormatStyle {
    func delimiter(_ strategy: DelimiterStrategy = .hyphen) -> Self {
        .init(delimiter: strategy)
    }
}
{% endsplash %}

1. This method output our sensible default: with hypens as delimiters.
2. This method lets us pass in _any_ `FormatStyle` who's `FormatInput` type is `ISBN`.
3. This extends `FormatStyle` itself with the `isbn` property when `FormatStyle` is `ISBN.FormatStyle`
4. This method allows us to return a new `ISBN.FormatStyle` and therefore chain methods together.


We can now create the instance methods on the FormatStyle:

{% splash %}
let isbn = ISBN(
    prefix: "978",
    registrationGroup: "17",
    registrant: "85889",
    publication: "01",
    checkDigit: "1"
)
isbn.formatted() // "978-17-85889-01-1"
isbn.formatted(.isbn) // "978-17-85889-01-1"
isbn.formatted(.isbn.delimiter(.none)) // "9781785889011"
{% endsplash %}

Finished. Now onto the parsing end of thing.

## Implementing ParseableFormatStyle

Before we can conform to `ParseableFormatStyle`, we need something that conforms to `ParseStrategy`.

Similar to the earlier `FormatStyle` struct that conforms to the `FormatStyle` protocol, let's create a `ParseStrategy` struct.

> We need to create a struct named `ParseStrategy` here because the `ParseableFormatStyle` protocol requires us to have an implementation of the `ParseStrategy` protocol defined before we can continue.

{% splash %}
extension ISBN {
    struct ParseStrategy {}
}
{% endsplash %}

Next, let's actually implement the code that will consume the `String` and convert it into an `ISBN`.

> I'm including both methods to be future proof, but to also give us the ability to compare and contrast the old and new APIs.

{% splash %}
extension ISBN {
    // 1
    enum DecodingError: Error {
        case invalidISBN(String)
    }
}

extension ISBN {
    // 2
    static func validate(_ value: String) -> Bool {
        let sum = value.enumerated().reduce(0) { partialResult, character in
            guard
                character.element.isNumber,
                let number = character.element.wholeNumberValue
            else {
                return partialResult
            }

            // Alternate multiplying by 1 or 3
            let multiplier = character.offset % 2 == 0 ? 1 : 3
            return partialResult + (number * multiplier)
        }
        return sum % 10 == 0
    }
}

extension ISBN.ParseStrategy {

    // 3
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    static func parse(_ value: String) throws -> ISBN {
        let isbnRegex = /([\d]{3})([\d]{2})([\d]{5})([\d]{2})([\d]{1})/
        let strippedValue = value.components(separatedBy: .decimalDigits.inverted).joined()

        guard
            ISBN.validate(strippedValue),
            let wholeMatch = try isbnRegex.wholeMatch(in: strippedValue)
        else {
            throw ISBN.DecodingError.invalidISBN(value)
        }

        let prefix = String(wholeMatch.output.1)
        let group = String(wholeMatch.output.2)
        let registrant = String(wholeMatch.output.3)
        let publication = String(wholeMatch.output.4)
        let checkDigit = String(wholeMatch.output.5)

        return ISBN(
            prefix: prefix,
            registrationGroup: group,
            registrant: registrant,
            publication: publication,
            checkDigit: checkDigit
        )
    }
    
    // 4
    static func legacyParse(_ value: String) throws -> ISBN {
        let strippedValue = value.components(separatedBy: .decimalDigits.inverted).joined()
        let isbnPattern = "([0-9]{3})([0-9]{2})([0-9]{5})([0-9]{2})([0-9]{1})"
        guard
            ISBN.validate(strippedValue),
            let regex = try? NSRegularExpression(pattern: isbnPattern, options: .useUnicodeWordBoundaries)
        else {
            throw ISBN.DecodingError.invalidISBN(strippedValue)
        }
        let nsRange = NSRange(location: 0, length: strippedValue.count)
        guard let match = regex.matches(in: value, options: [], range: nsRange).first else {
            throw ISBN.DecodingError.invalidISBN(strippedValue)
        }
        var captures = [String]()
        // Start at index 1 since `0` is the range of the whole string.
        for index in 1 ..< match.numberOfRanges {
            guard let range = Range<String.Index>.init(match.range(at: index), in: strippedValue) else {
                continue
            }
            let captureSubstring = value[range]
            captures.append(String(captureSubstring))
        }
        let prefix = captures[0]
        let group = captures[1]
        let registrant = captures[2]
        let publication = captures[3]
        let checkDigit = captures[4]

        return ISBN(
            prefix: prefix,
            registrationGroup: group,
            registrant: registrant,
            publication: publication,
            checkDigit: checkDigit
        )
    }
}
{% endsplash %}

1. We define a custom error to throw in our parsing methods. This can be helpful for debugging during implementation.
2. This is an implementation of the [check digit calculation](https://en.wikipedia.org/wiki/ISBN#ISBN-13_check_digit_calculation)
2. This is the parsing method using the new Regex APIs in iOS 16
3. This is the pain of parsing the data using the old NSRegrularExpression APIs (yikes)

Nearly there. Our last piece of functionality is to make our `ISBN.FormatStyle` struct conform to `ParseableFormatStyle`:

{% splash %}
extension ISBN.ParseStrategy: ParseStrategy {
    func parse(_ value: String) throws -> ISBN {
        if #available(iOS 16.0, *) {
            return try ISBN.ParseStrategy.parse(value)
        } else {
            return try ISBN.ParseStrategy.legacyParse(value)
        }
    }
}

extension ISBN.FormatStyle: ParseableFormatStyle {
    var parseStrategy: ISBN.ParseStrategy { .init() }
}
{% endsplash %}

At this point we have the ability to parse our ISBN strings!

{% splash %}
try? ISBN.FormatStyle().parseStrategy.parse("9781785889011") // Outputs an ISBN struct.
{% endsplash %}

## Adding Parsing Conveniences

{% splash %}
// 1
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension ParseableFormatStyle where Self == ISBN.FormatStyle {
    static var isbn: Self { .init() }
}

// 2
extension ISBN {
    init(_ string: String) throws {
        self = try ISBN.ParseStrategy().parse(string)
    }
} 
{% endsplash %}

1. We extend `ParseableFormatStyle` to allow for us to have a shortcut to the format style struct
2. This ISBN initializer now lets us create a new ISBN instance using nothing but a string
data
After all this, we now have a data type with some tightly defined ways of going to and from `ISBN` to `String`:

{% splash %}
// Success
try? ISBN("9781785889011") // ISBN
try? ISBN.FormatStyle().parseStrategy.parse("9781785889011") // ISBN
try? ISBN.ParseStrategy().parse("9781785889011") // ISBN
try? ISBN("978-17-85889-01-1") // ISBN

// Failures
try? ISBN("a") // nil
try? ISBN("978178588901") // nil
try? ISBN("9781785889111") // nil
try? ISBN("9781785A8901") // nil

let isbn = try! ISBN("9781785889011")

isbn.formatted() // "978-17-85889-01-1"
isbn.formatted(.isbn) // "978-17-85889-01-1"
isbn.formatted(.isbn.delimiter(.none)) // "9781785889011"
isbn.formatted(ISBN.FormatStyle()) // "978-17-85889-01-1"
isbn.formatted(ISBN.FormatStyle(delimiter: .none)) // "9781785889011"
{% endsplash %}

It's 