---
layout: post
title: The Xcode 14 Format Style Updates
description: I've released a big update for Fucking FormatStyle/Gosh Darned FormatStyle.
tags: [formatstyle, development, swift, formatstyle]
---

I've been toiling away in the format style mines for the last month off and on as I've been fully documenting the new `FormatStyle` stuff that Apple has been including in the Xcode 14 betas.

Today I've finally launched the update!

The changelogs: [Fucking FormatStyle](https://fuckingformatstyle.com/changelog/) or [Gosh Darned FormatStyle](https://goshdarnformatstyle.com/changelog/)

## Updates

- ByteCountFormatStyle for Int64 values no longer crash when you try and use any unit larger than gigabyte.
- There's a special FormatStyle for `Measurement<UnitInformationStorage>` values that is identical to `ByteCountFormatStyle` 
- We now have a `URL.FormatStyle` which also conforms to `ParseableFormatStyle`, which means we can format and parse URL data now
- You can now access the `Date.VerbatimFormatStyle` by using the type method `formatted(.verbatim())` on Date values
- The new `Duration` type also has full format style support with two new styles
- The site has quickly grown outside of my original goals of a single page, single serving site. So I've broken it up into individual pages for sections.

Thanks everyone for sharing and using the site. I've gotten amazing feedback from the community about it.