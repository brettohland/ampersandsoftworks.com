---
title: "Numerical FormatStyles"
date: 2022-03-15T22:17:25-06:00
draft: false
url: /posts/formatstyle/numerical/
tags: [ios15, formatstyle, deepdive, development, swift, swiftui]
---

[This is part of the FormatStyle Deep Dive series](/posts/formatstyle-deep-dive)

Every supported number type in Swift have identical support for numerical FormatStyles. Each one has the identical ability to be formatted as `.number`, `.currency`, and `.percent`.

> NOTE: Please don't use floating point numbers to store and modify currency vales. This storage type is not guaranteed to be free of rounding errors, and will cause long term grief.

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>

## [`.number`](/posts/formatstyle/style-deep-dives/numerical/number/)

This is the general `FormatStyle` for numbers. 

[See the `.number` deep dive](/posts/formatstyle/style-deep-dives/numerical/number/)

<hr>

## [`.currency`](/posts/formatstyle/style-deep-dives/numerical/currency/)

A powerful style that handles the localization complexities of display currency values.

[See the `.currency` deep dive](/posts/formatstyle/style-deep-dives/numerical/currency/)

<hr>

## [`.percent`](/posts/formatstyle/style-deep-dives/numerical/percent/)

Handles the display of percentages

[See the `.percent` deep dive](/posts/formatstyle/style-deep-dives/numerical/percent/)

<hr>

[Download the Xcode Playground with all examples](https://github.com/brettohland/FormatStylesDeepDive/)

[See the examples as a gist](https://gist.github.com/brettohland/ac2fbd1446bc7bb64da491587b010e3c)

<hr>