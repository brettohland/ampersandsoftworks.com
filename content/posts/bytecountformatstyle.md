---
title: "ByteCountFormatStyle"
date: 2022-03-13T21:47:26-06:00
draft: false
tags: [ios15, formatstyle, deepdive]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

The `ByteCountFormatStyle` allows you to output a byte count to a more easily readable format (KB, MB, GB, etc.).

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e)

<hr>

```Swift
let terabyte: Int64 = 1_000_000_000_000

terabyte.formatted(.byteCount(style: .binary))  // "931.32 GB"
terabyte.formatted(.byteCount(style: .decimal)) // "1 TB"
terabyte.formatted(.byteCount(style: .file))    // "1 TB"
terabyte.formatted(.byteCount(style: .memory))  // "931.32 GB"
```

`.binary` and `.memory` use base 16 counts, while `.decimal` and `.file` use base 10.

You can also specify the display unit with the `allowedUnits` parameter:

```Swift
terabyte.formatted(.byteCount(style: .file, allowedUnits: .bytes)) // "1,000,000,000,000 bytes"
terabyte.formatted(.byteCount(style: .file, allowedUnits: .kb))    // "1,000,000,000 kB"
terabyte.formatted(.byteCount(style: .file, allowedUnits: .mb))    // "1,000,000 MB"
```

You can specify if the formatter will convert a 0 value into a spelled out string:

```Swift
Int64(0).formatted(.byteCount(style: .file, allowedUnits: .mb, spellsOutZero: true))   // "Zero bytes"
Int64(0).formatted(.byteCount(style: .file, allowedUnits: .mb, spellsOutZero: false))  // "0 MB"
```

You can also specify if you'd like for the raw byte count to be included in the string:

```Swift
terabyte.formatted(.byteCount(style: .file, allowedUnits: .mb, includesActualByteCount: true))  // "1,000,000 MB (1,000,000,000,000 bytes)"
terabyte.formatted(.byteCount(style: .file, allowedUnits: .mb, includesActualByteCount: false)) // "1,000,000 MB"
```

Mix and match as you please.

```Swift
terabyte.formatted(.byteCount(style: .file, allowedUnits: .all, spellsOutZero: true, includesActualByteCount: true)) // "1 TB (1,000,000,000,000 bytes)"
```

You can set the locale by using the `.locale()` method:

```Swift
let franceLocale = Locale(identifier: "fr_FR")

terabyte.formatted(.byteCount(style: .binary).locale(franceLocale)) // "931,32 Go"
terabyte.formatted(.byteCount(style: .decimal).locale(franceLocale)) // "1To"
terabyte.formatted(.byteCount(style: .file).locale(franceLocale)) // "1To"
terabyte.formatted(.byteCount(style: .memory).locale(franceLocale)) // "931,32 Go"
```

<hr>

## Customizing

Using a new instance of the `ByteCountFormatter` is nearly identical to using the `FormatStyle` extension shown above. 

```Swift
let inFrench = ByteCountFormatStyle(
    style: .memory,
    allowedUnits: .all,
    spellsOutZero: false,
    includesActualByteCount: true,
    locale: Locale(identifier: "fr_FR")
)

inFrench.format(terabyte) // "931,32 Go (1 000 000 000 000 octets)"
terabyte.formatted(inFrench) // "931,32 Go (1 000 000 000 000 octets)"
```
<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/0bafc12c89143d5e493e349341b31e9e)

<hr>