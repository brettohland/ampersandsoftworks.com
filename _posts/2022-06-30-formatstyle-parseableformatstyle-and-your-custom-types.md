---
layout: post
title: Formatting your own types
description: A full example of adding all of the bells and whistles of ParseableFormatStyle onto your own types, including AttributedString output.
tags: [ios, formatstyle, development, swift]
---

[So you've read the gosh darn site and know how to get strings from data types.](https://goshdarnformatstyle.com). 

[Then you read the ParseableFormatStyle post and know how to parse strings into data](/posts/from-strings-to-data-using-parseableformatstyle/).

If your next thought was: "Now I want to do this with my own data types", then this is for you.

**TL;DR:** [Download the Xcode Playground](https://github.com/brettohland/ampersandsoftworks.com-examples/tree/main/%5B2022-06-30%5D%20ISBN-FormatStyle) or [See everything as a Gist](https://gist.github.com/brettohland/744fcbd2a8aa77907ec84a286e8da3b0)

# Sections

1. [Our Data Type](#our-data-type)
2. [String Output](#string-output)
  * [Creating our ISBN.FormatStyle](#creating-our-isbnformatstyle)
  * [Making Access Easier](#making-access-easier)
3. [AttributedString Output](#attributedstring-output)
  * [Creating a Custom AttributedScope](#creating-a-custom-attributedscope)
  * [Creating Our ISBN.AttributedStringFormatStyle](#creating-our-isbnattributedstringformatstyle)
4. [Parsing Strings Into ISBNs](#parsing-strings-into-isbns)
  * [ISBN Validation Implementation](#isbn-validation-implementation)
  * [Creating our ParseStrategy](#creating-our-parsestrategy)
  * [ParseableFormatStyle Conformance & Convenience Extensions](#parseableformatstyle-conformance---convenience-extensions)
5. [Bonus Round: Unit Testing](#bonus-round--unit-testing)

---

**TL;DR:** [Download the Xcode Playground](https://github.com/brettohland/ISBN-FormatStyle/) or [See everything as a Gist](https://gist.github.com/brettohland/744fcbd2a8aa77907ec84a286e8da3b0)

The API for this example is based heavily on the [`Date.FormatStyle`]() API, and the [URL FormatStyle and ParseStyle Proposal](https://forums.swift.org/t/url-formatstyle-and-parsestrategy/56607) that was ultimately included in iOS 16.

We're going to define a custom data type, and then add the following features:

1. A way to output `String` values
2. A way to output `AttributedString` values
3. A way to parse `String` inputs

# Our Data Type

[The humble ISBN](https://en.wikipedia.org/wiki/ISBN) is our international standard for uniquely identifying books. It has everything we need in a data type:

- It exists
- It represent a structure of data
- It can be validated

Our ISBN representation is going to be storing the 13 digit standard from 2007. 

<center><img src="/images/2022/Jun/isbn.png" alt="An ISBN Bacode (Based on the EAD13 Standard" width="200" style="margin-bottom: 10px"/></center>

{% splash %}

/// Represents a 13 digit International Standard Book Number.
public struct ISBN: Codable, Sendable, Equatable, Hashable {
    public let prefix: String
    public let registrationGroup: String
    public let registrant: String
    public let publication: String
    public let checkDigit: String

    /// Initializes a new ISBN struct
    /// - Parameters:
    ///   - prefix: The prefix to the registration group
    ///   - registrationGroup: The registration group (as numbers)
    ///   - registrant: The registrant (as number)
    ///   - publication: The publication (as numbers)
    ///   - checkDigit: The check digit used in validation
    public init(
        prefix: String,
        registrationGroup: String,
        registrant: String,
        publication: String,
        checkDigit: String
    ) {
        self.prefix = prefix
        self.registrationGroup = registrationGroup
        self.registrant = registrant
        self.publication = publication
        self.checkDigit = checkDigit
    }
}

{% endsplash %}

Simple enough. But one thing to note: Because of how the [validation is calculated](), each part of the ISBN is being stored as `String` values. Not `Int` values. There are no fixed sizes for each of the portions of the ISBN, and there may be a case where we might have values that start with 0.

# String Output

We're going to define a `struct` called `FormatStyle` inside of an extension on `ISBN`, which will then conform to the `FormatStyle` protocol.

Reading about the standard, we can learn that it's valid for an ISBN to use hyphens or spaces to separate each part of the value. Also, that (generally) you can convert between ISBN-13 and ISBN-10 values fairly freely by omitting or adding a standard prefix. So let's define two enums within our `FormatStyle` to define these options as well.

## Creating our ISBN.FormatStyle

{% splash %}
public extension ISBN {

    struct FormatStyle: Codable, Equatable, Hashable {

        /// Defines which ISBN standard to output
        public enum Standard: Codable, Equatable, Hashable {
            case isbn13
            case isbn10
        }

        public enum Separator: String, Codable, Equatable, Hashable {
            case hyphen = "-"
            case space = " "
            case none = ""
        }

        let standard: Standard
        let separator: Separator

        /// Initialize an ISBN FormatStyle with the given Standard
        /// - Parameter standard: Standard, defaults to .isbn13(.hyphen)
        public init(_ standard: Standard = .isbn13, separator: Separator = .hyphen) {
            self.standard = standard
            self.separator = separator
        }

        // MARK: Customization Method Chaining

        public func standard(_ standard: Standard) -> Self {
            .init(standard, separator: separator)
        }

        /// Returns a new instance of `self` with the standard property set.
        /// - Parameter standard: The standard to use on the final output
        /// - Returns: A copy of `self` with the standard set
        public func separator(_ separator: Separator) -> Self {
            .init(standard, separator: separator)
        }
    }
}
{% endsplash %}

You'll also notice that we define two instance methods as well `standard(:)` and `separator(:)`. The goals here is to follow the Swift team's standards and allow our new format style to be composited together like so: `ISBN.FormatStyle().standard(.isbn10).spacer(.space)`. 

Because our `ISBN.FormatStyle` is a struct (a value type), this is the best way to do it. Modifying structs is to be generally avoided (and you have to declare things "mutating" in order to do it.)

You'll notice that our shiny new `ISBN.FormatStyle` _doesn't actually conform to the FormatStyle protocol_. Well that's an easy fix:

{% splash %}
extension ISBN.FormatStyle: Foundation.FormatStyle {
    /// Returns a textual representation of the `ISBN` value passed in.
    /// - Parameter value: A `ISBN` value
    /// - Returns: The textual representation of the value, using the style's `standard`.
    public func format(_ value: ISBN) -> String {
        let parts = [
            value.prefix,
            value.registrationGroup,
            value.registrant,
            value.publication,
            value.checkDigit,
        ]
        switch standard {
        case .isbn13:
            return parts.joined(separator: separator.rawValue)
        case .isbn10:
            // ISBN-10 is missing the "prefix" portion of the number.
            return parts.dropFirst().joined(separator: separator.rawValue)
        }
    }
}
{% endsplash %}

Now we're in an interesting place. We have a valid `FormatStyle`, but it's not great to use. Right now our API to use it would be limited to initializing an instance of it, and calling the `format(:)` method.

{% splash %}
let isbn = ISBN(
    prefix: "978",
    registrationGroup: "17",
    registrant: "85889",
    publication: "01",
    checkDigit: "1"
)

// The default (ISBN-13, hyphen)
ISBN.FormatStyle().format(isbn) // "978-17-85889-01-1"

// Initializer, with all properties set.
ISBN.FormatStyle(.isbn13, separator: .hyphen).format(isbn) // "978-17-85889-01-1"
ISBN.FormatStyle(.isbn13, separator: .space).format(isbn) // "978 17 85889 01 1"
ISBN.FormatStyle(.isbn13, separator: .none).format(isbn) // "9781785889011"
ISBN.FormatStyle(.isbn10, separator: .hyphen).format(isbn) // "17-85889-01-1"
ISBN.FormatStyle(.isbn10, separator: .space).format(isbn) // "17 85889 01 1"
ISBN.FormatStyle(.isbn10, separator: .none).format(isbn) // "1785889011"

// The ISBN-13 default, but using method chaining to change the separator
ISBN.FormatStyle().separator(.hyphen) // "978-17-85889-01-1"
ISBN.FormatStyle().separator(.space) // "978 17 85889 01 1"
ISBN.FormatStyle().separator(.none) // "9781785889011"

// Changing the standard and separator using method chainig
ISBN.FormatStyle().standard(.isbn10).separator(.hyphen) // "17-85889-01-1"
ISBN.FormatStyle().standard(.isbn10).separator(.space) // "17 85889 01 1"
ISBN.FormatStyle().standard(.isbn10).separator(.none) // "1785889011"
{% endsplash %}

## Making Access Easier

To follow along with the platform standards, we need to add  some extensions to `ISBN` and `FormatStyle` themselves:

{% splash %}
public extension ISBN {

    /// Converts `self` to its textual representation.
    /// - Returns: String
    func formatted() -> String {
        Self.FormatStyle().format(self)
    }

    /// Converts `self` to another representation.
    /// - Parameter style: The format for formatting `self`
    /// - Returns: A representations of `self` using the given `style`. The type of the return is determined by the FormatStyle.FormatOutput
    func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == ISBN {
        style.format(self)
    }
}

// MARK: Convenience FormatStyle extensions to ease access

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension FormatStyle where Self == ISBN.FormatStyle {

    static var isbn13: Self { .init(.isbn13, separator: .hyphen) }
    static var isbn10: Self { .init(.isbn10, separator: .hyphen) }

    static func isbn(
        standard: ISBN.FormatStyle.Standard = .isbn13,
        separator: ISBN.FormatStyle.Separator = .hyphen
    ) -> Self {
        .init(standard, separator: separator)
    }
}

// MARK: - Debug Methods on ISBN

extension ISBN: CustomDebugStringConvertible {
    public var debugDescription: String {
        "ISBN: \(formatted())"
    }
}

{% endsplash %}

We can now do the following:

{% splash %}
let isbn = ISBN(
    prefix: "978",
    registrationGroup: "17",
    registrant: "85889",
    publication: "01",
    checkDigit: "1"
)

isbn.formatted() // "978-17-85889-01-1"
isbn.formatted(.isbn()) // "978-17-85889-01-1"
isbn.formatted(.isbn(standard: .isbn13, separator: .hyphen)) // "978-17-85889-01-1"
isbn.formatted(.isbn(standard: .isbn13, separator: .space)) // "978 17 85889 01 1"
isbn.formatted(.isbn(standard: .isbn13, separator: .none)) // "9781785889011"

isbn.formatted(.isbn(standard: .isbn10, separator: .hyphen)) // "17-85889-01-1"
isbn.formatted(.isbn(standard: .isbn10, separator: .space)) // "17 85889 01 1"
isbn.formatted(.isbn(standard: .isbn10, separator: .none)) // "1785889011"

isbn.formatted(.isbn13.separator(.none)) // "9781785889011"
isbn.formatted(.isbn13.separator(.hyphen)) // "978-17-85889-01-1"
isbn.formatted(.isbn13.separator(.space)) // "978 17 85889 01 1"

isbn.formatted(.isbn10.separator(.none)) // "1785889011"
isbn.formatted(.isbn10.separator(.hyphen)) // "17-85889-01-1"
isbn.formatted(.isbn10.separator(.space)) // "17 85889 01 1"
{% endsplash %}

# AttributedString Output

Adding AttributedString support is as easy as creating a new struct that conforms to `FormatStyle` whose `FormatOutput` type is `AttributedString`. 

But why do this?

At the heart of it, an AttributedString is just a regular String but with metadata. Some of that metadata is used by our UI APIs to modify how they're shown on screen (think colours, letter case, or font weight), while other metadata is just for reference. Since our `ISBN` type has structured data, it could be useful for others to have each part of the identifier be marked up.

Individual pieces of metadata are defined as _attributes_, and those attributes are contained in _scopes_. [There's a great article on NilCoalescing about if you'd like to read more](https://nilcoalescing.com/blog/AttributedStringAttributeScopes/).

The first step is to define our scope and our attribute, and also extend the dynamic lookup system to add support for it.

## Creating a Custom AttributedScope

{% splash %}
// We need to create a new AttributedScope to contain our new attributes.
public extension AttributeScopes {

    /// Represents the parts of an ISBN which we will be adding attributes to.
    enum ISBNPart: Hashable {
        case prefix
        case registrationGroup
        case registrant
        case publication
        case checkDigit
        case separator
    }

    // Define our new AttributeScope
    struct ISBNAttributes: AttributeScope {
        // Our property value to access it.
        let isbnPart: ISBNAttributeKey
    }

    // We follow the AttributeStringKey protocol to define our new attribute.
    enum ISBNAttributeKey: AttributedStringKey {
        public typealias Value = ISBNPart
        public static let name = "isbnPart"
    }

    // This extends AttributeScope to allow us to access our new ISBNPart type quickly.
    var isbnPart: ISBNPart.Type { ISBNPart.self }
}

// We extend AttributeDynamicLookup to know about our custom type.
public extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.ISBNAttributes, T>) -> T {
        self[T.self]
    }
}
{% endsplash %}

## Creating Our ISBN.AttributedStringFormatStyle

With those defined, we can now build our `ISBN.AttributedStringFormatStyle` struct that will convert our ISBN to the `AttributedString`. Notice that after creating attributed string versions of each part, we then set the `.isbnPart` attribute of each. That specifically is why we've created this type.

{% splash %}
public extension ISBN {

    /// An ISBN FormatStyle for outputting AttributedString values.
    struct AttributedStringFormatStyle: Codable, Foundation.FormatStyle {

        private let standard: ISBN.FormatStyle.Standard
        private let separator: ISBN.FormatStyle.Separator

        /// Initialize an ISBN FormatStyle with the given Standard
        /// - Parameter standard: Standard (required)
        public init(standard: ISBN.FormatStyle.Standard, separator: ISBN.FormatStyle.Separator) {
            self.standard = standard
            self.separator = separator
        }

        // The format method required by the FormatStyle protocol.
        public func format(_ value: ISBN) -> AttributedString {

            // Creates AttributedString representations of each part of the ISBN
            var prefix = AttributedString(value.prefix)
            var group = AttributedString(value.registrationGroup)
            var registrant = AttributedString(value.registrant)
            var publication = AttributedString(value.publication)
            var checkDigit = AttributedString(value.checkDigit)

            // Assigns our custom attribute scope attribute to each part.
            prefix.isbnPart = .prefix
            group.isbnPart = .registrationGroup
            registrant.isbnPart = .registrant
            publication.isbnPart = .publication
            checkDigit.isbnPart = .checkDigit

            // Collect all parts in an array to allow for simple AttributedString concatenation using reduce
            let parts = [
                prefix,
                group,
                registrant,
                publication,
                checkDigit,
            ]

            // Create the final AttributedString by using the reduce method. We define the
            switch standard {
            case .isbn13 where separator == .none:
                // Merge all parts into one string.
                return parts.reduce(AttributedString(), +)
            case .isbn13:
                // Define the delimiter
                var separator = AttributedString(separator.rawValue)
                separator.isbnPart = .separator
                // Starting with the .prefix, use reduce to build the final AttributedString.
                return parts.dropFirst().reduce(prefix) { $0 + separator + $1 }
            case .isbn10 where separator == .none:
                // Drop the prefix, merge all parts.
                return parts.dropFirst().reduce(group, +)
            case .isbn10:
                // Define the delimiter
                var separator = AttributedString(separator.rawValue)
                separator.isbnPart = .separator
                // Drop the first two elements (prefix and group), then build the final AttributedString
                return parts.dropFirst(2).reduce(group) { $0 + separator + $1 }
            }
        }
    }
}

// Extend 
public extension ISBN.FormatStyle {
    var attributed: ISBN.AttributedStringFormatStyle {
        .init(standard: standard, separator: separator)
    }
}
{% endsplash %}

Now when we're using our ISBN, we can use these attributes to customize their display on screen:

{% splash %}
struct AttributedStringExample: View {

    let exampleISBN = ISBN(
        prefix: "978",
        registrationGroup: "17",
        registrant: "85889",
        publication: "01",
        checkDigit: "1"
    )

    var attributedString: AttributedString {
        var attributedISBN = exampleISBN.formatted(.isbn13.attributed)
        for run in attributedISBN.runs {
            if let isbnRun = run.isbnPart {
                switch isbnRun {
                case .prefix:
                    attributedISBN[run.range].foregroundColor = .magenta
                case .registrationGroup:
                    attributedISBN[run.range].foregroundColor = .blue
                case .registrant:
                    attributedISBN[run.range].foregroundColor = .green
                case .publication:
                    attributedISBN[run.range].foregroundColor = .purple
                case .checkDigit:
                    attributedISBN[run.range].foregroundColor = .orange
                case .separator:
                    attributedISBN[run.range].foregroundColor = .red
                }
            }
        }
        return attributedISBN
    }

    var body: some View {
        Text(attributedString)
            .padding(20)
    }
}
{% endsplash %}

Which is going to put the following on screen:

<center><img src="/images/2022/Jun/isbn-attributed-stirng-customization.png" style="margin-bottom: 10px;"></center>

# Parsing Strings Into ISBNs

The last piece of functionality we want to add is the ability to parse a string and convert it into an ISBN. [I did a `ParseableFormatStyle` write-up that can give you more information about the details of this protocol](https://ampersandsoftworks.com/posts/from-strings-to-data-using-parseableformatstyle/).

Our implementation is going to rely on separators to delimitate each part of the ISBN. While you can use the [ISBN check digit calculation](https://en.wikipedia.org/wiki/ISBN#ISBN-13_check_digit_calculation) to validate any 13 digit number as a valid ISBN, there's no real way to take a 13 digit number and chop it up into known parts. This is because each part of the ISBN could take up any arbitrary amount of those 13 digits, and we can't effectively make those assumptions without knowing _a lot_ more detail about how they're used in the real world.

## ISBN Validation Implementation

First up, let's add the check digit calculation validation to our ISBN:

{% splash %}
public extension ISBN {

    // Define our validation errors
    enum ValidationError: Error {
        case emptyInput
        case noGroupsPresent
        case invalidStringLength
        case invalidCharacters
        case checksumFailed
    }

    // Define our valid character set. We avoid using CharacterSet.decimalDigit since that includes
    // all unicode characters which represents digits. ISBN values only use the Arabic numerals,
    // hyphens, or spaces.
    static let validCharacterSet = CharacterSet(charactersIn: "0123456789").union(validSeparatorsSet)

    // Define our valid separators.
    static let validSeparatorsSet = CharacterSet(charactersIn: "- ")

    // Define the "Bookland" prefix (https://en.wikipedia.org/wiki/Bookland) to convert ISBN-10 values to ISBN-13
    static let booklandPrefix = "978"

    /// Returns a validated, 13 digit ISBN string.
    /// https://en.wikipedia.org/wiki/ISBN#ISBN-13_check_digit_calculation
    /// - Parameter value: A string representation of an ISBN
    /// - Returns: String, the valid String that passed the check.
    static func validate(_ candidate: String?) throws -> String {

        // Unwrap the value passed in.
        guard let candidate = candidate else { throw ValidationError.emptyInput }

        // Validate that we have spacers present, otherwise we're not going to be able to parse out
        // any ISBN values
        guard candidate.rangeOfCharacter(from: Self.validSeparatorsSet) != nil else {
            throw ValidationError.noGroupsPresent
        }

        // Trim any leading and trailing whitespace and newlines.
        // Newlines will fail on the next check.
        let trimmedString = candidate.trimmingCharacters(in: .whitespaces)

        // Check for the existence of any invalid characters.
        // We invert validCharacterSet to represent every other character in unicode than what is valid.
        // If rangeOfCharacter returns a value, we know that those characters exist (and therefore fails)
        guard trimmedString.rangeOfCharacter(from: Self.validCharacterSet.inverted) == nil else {
            // So we throw the appropriate error
            throw ValidationError.invalidCharacters
        }

        // Convert any ISBN-10 values into ISBN13 values by adding
        // the "Bookland" prefix (https://en.wikipedia.org/wiki/Bookland)
        let isbn13String = trimmedString.count == 10 ? Self.booklandPrefix + trimmedString : trimmedString

        // Run the ISBN 13 checksum calculation
        // https://en.wikipedia.org/wiki/ISBN#ISBN-13_check_digit_calculation
        // Use the reduce method to run the checksum, starting with 0
        // We enumerate the string because we need the position (it's offset) for each character, as
        // well as the number itself.

        // Start by removing all of the hyphens
        let isbnString = isbn13String.components(separatedBy: .decimalDigits.inverted).joined()

        // Verify that we have either 10 or 13 characters at this point.
        guard [10, 13].contains(isbnString.count) else {
            throw ValidationError.invalidStringLength
        }

        // First, we take the sum of the number. Multiplying each digit by either 1 or 3.
        let sum = isbnString.enumerated().reduce(0) { partialResult, character in

            // Safely convert the character into an integer.
            guard let number = character.element.wholeNumberValue else {
                return partialResult
            }
            // We alternate multiplying each character by 1 or 3
            let multiplier = character.offset % 2 == 0 ? 1 : 3
            // We then multiply the number by the multiplier, and add it to the previous result
            return partialResult + (number * multiplier)
        }
        // We then  make sure that the number is cleanly divisible by 10 by using the modulo function.
        guard sum % 10 == 0 else {
            throw ValidationError.checksumFailed
        }

        // Success. Return the original ISBN-10 or ISBN-13 string
        return trimmedString
    }
}
{% endsplash %}

## Creating our ParseStrategy

We can then create our `ParseStrategy`, extend `ISBN.FormatStyle` to conform to `ParseableFormatStyle`, add some new initializers to `ISBN` that will parse a `String`, and extend `ParseableFormatStyle` with our new style to allow for simple access.

{% splash %}
public extension ISBN.FormatStyle {

    enum DecodingError: Error {
        case invalidInput
    }

    struct ParseStrategy: Foundation.ParseStrategy {

        public init() {}

        public func parse(_ value: String) throws -> ISBN {
            // Trim the input string any leading or trailing whitespaces
            let trimmedValue = value.trimmingCharacters(in: .whitespaces)

            // Attempt to validate our trimmed string
            let validISBN = try ISBN.validate(trimmedValue)

            // Create an array of strings based on the separator used.
            let components = validISBN.components(separatedBy: ISBN.validSeparatorsSet)

            // Having 4 components means that we were given an ISBN-10 number.
            // Therefore we need to convert it.
            let finalComponents = components.count == 4 ? [ISBN.booklandPrefix] + components : components

            // Since we're going to use subscripts to access each value in the array, it's a good
            // idea to verify that all values are present to avoid crashing.
            guard finalComponents.count == 5 else {
                throw DecodingError.invalidInput
            }

            // Build the final ISBN from the component parts.
            return ISBN(
                prefix: finalComponents[0],
                registrationGroup: finalComponents[1],
                registrant: finalComponents[2],
                publication: finalComponents[3],
                checkDigit: finalComponents[4]
            )
        }
    }
}

{% endsplash %}

## ParseableFormatStyle Conformance & Convenience Extensions

{% splash %}

// MARK: ParseableFormatStyle conformance on ISBN.FormatStyle

extension ISBN.FormatStyle: ParseableFormatStyle {
    public var parseStrategy: ISBN.FormatStyle.ParseStrategy {
        .init()
    }
}

// MARK: Convenience members on ISBN to simplify access to the ParseStrategy

public extension ISBN {

    init(_ string: String) throws {
        self = try ISBN.FormatStyle().parseStrategy.parse(string)
    }

    init<T, Value>(_ value: Value, standard: T) throws where T: ParseStrategy, Value: StringProtocol, T.ParseInput == String, T.ParseOutput == ISBN {
        self = try standard.parse(value.description)
    }
}

// MARK: Extend ParseableFormatStyle to simplify access to the format style

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension ParseableFormatStyle where Self == ISBN.FormatStyle {
    static var isbn: Self { .init() }
}
{% endsplash %}

Which gives us the power to do the following:

{% splash %}
try? ISBN("978-17-85889-01-1") // ISBN: 978-17-85889-01-1
try? ISBN("978 17 85889 01 1") // ISBN: 978-17-85889-01-1
try? ISBN(" 978-17-85889-01-1 ") // ISBN: 978-17-85889-01-1
try? ISBN("978 17-85889-01-1") // ISBN: 978-17-85889-01-1
try? ISBN("978-1-84356-028-9") // ISBN: 978-1-84356-028-9
try? ISBN("978-0-684-84328-5") // ISBN: 978-0-684-84328-5
try? ISBN("978-0-8044-2957-3") // ISBN: 978-0-8044-2957-3
try? ISBN("978-0-85131-041-1") // ISBN: 978-0-85131-041-1
try? ISBN("978-0-943396-04-0") // ISBN: 978-0-943396-04-0
try? ISBN("978-0-9752298-0-4") // ISBN: 978-0-9752298-0-4
{% endsplash %}

# Bonus Round: Unit Testing

Because we're dealing with a checksum validation, we might also want to write some unit test cases to verify that our implementation is correct.

{% splash %}
final class ISBNTests: XCTestCase {

    let isbn = ISBN(
        prefix: "978",
        registrationGroup: "17",
        registrant: "85889",
        publication: "01",
        checkDigit: "1"
    )

    func testISBN13Output() throws {
        let expectedHyphen = "978-17-85889-01-1"
        let expectedSpace = "978 17 85889 01 1"
        let expectedNone = "9781785889011"

        XCTAssertEqual(isbn.formatted(), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn13), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn13.separator(.hyphen)), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn13.separator(.space)), expectedSpace)
        XCTAssertEqual(isbn.formatted(.isbn13.separator(.none)), expectedNone)

        XCTAssertEqual(ISBN.FormatStyle().format(isbn), expectedHyphen)
        XCTAssertEqual(ISBN.FormatStyle(.isbn13, separator: .hyphen).format(isbn), expectedHyphen)
        XCTAssertEqual(ISBN.FormatStyle(.isbn13, separator: .space).format(isbn), expectedSpace)
        XCTAssertEqual(ISBN.FormatStyle(.isbn13, separator: .none).format(isbn), expectedNone)
    }

    func testISBN10Output() throws {
        let expectedHyphen = "17-85889-01-1"
        let expectedSpace = "17 85889 01 1"
        let expectedNone = "1785889011"

        XCTAssertEqual(isbn.formatted(.isbn10), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn10.separator(.hyphen)), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn10.separator(.space)), expectedSpace)
        XCTAssertEqual(isbn.formatted(.isbn10.separator(.none)), expectedNone)

        XCTAssertEqual(ISBN.FormatStyle(.isbn10, separator: .hyphen).format(isbn), expectedHyphen)
        XCTAssertEqual(ISBN.FormatStyle(.isbn10, separator: .space).format(isbn), expectedSpace)
        XCTAssertEqual(ISBN.FormatStyle(.isbn10, separator: .none).format(isbn), expectedNone)
    }

    func testISBNParsing() throws {
        XCTAssertNoThrow(try ISBN("978-17-85889-01-1"))
        XCTAssertNoThrow(try ISBN("978 17 85889 01 1"))
        XCTAssertNoThrow(try ISBN(" 978-17-85889-01-1 "))
        XCTAssertNoThrow(try ISBN("978 17-85889-01-1"))
        XCTAssertNoThrow(try ISBN("978-1-84356-028-9"))
        XCTAssertNoThrow(try ISBN("978-0-684-84328-5"))
        XCTAssertNoThrow(try ISBN("978-0-8044-2957-3"))
        XCTAssertNoThrow(try ISBN("978-0-85131-041-1"))
        XCTAssertNoThrow(try ISBN("978-0-943396-04-0"))
        XCTAssertNoThrow(try ISBN("978-0-9752298-0-4"))

        XCTAssertNoThrow(try ISBN("17-85889-01-1"))
        XCTAssertNoThrow(try ISBN("17 85889 01 1"))

        XCTAssertThrowsError(try ISBN("9780975229804"))
        XCTAssertThrowsError(try ISBN("0"))
        XCTAssertThrowsError(try ISBN("98 17 85889 01 1"))
    }
}
{% endsplash %}

[Download the Xcode Playground](https://github.com/brettohland/ampersandsoftworks.com-examples/tree/main/%5B2022-06-30%5D%20ISBN-FormatStyle) or [See everything as a Gist](https://gist.github.com/brettohland/744fcbd2a8aa77907ec84a286e8da3b0)