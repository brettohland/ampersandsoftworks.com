z---
title: "UIFont Fun"
date: 2021-11-24T10:18:52-07:00
draft: false
tags: [development, swift, swiftui]
---

In your career, do you have a technical problem that you know you've solved multiple times, but it's infrequent enough that the lessons of how to actually implement never seem to stick around in your brain?

For me, it's custom fonts in your iOS apps.

In summary, to add a custom font to your app you need to:

1. Add the font file to your project and make sure that it's included in your build target.
2. Register your font file in the `Info.plist` in an array under the `UIAppFonts` key.
3. Use the font by referencing it's name.

Unsurprisingly, it's #3 that always seems to mess me up.

In this example, I was using the font `Inter` from Google Fonts, and I added the `light` variant to the project. 

Now, the project already includes the `Inter-Medium` and `Inter-Regular`, and their "real" names are (unsurprisingly) `Inter-Regular` and `Inter-Medium`.

The code that references this is exceptionally simple:

```Swift

public enum CustomFontVariant {
  case regular
  case medium
}

extension UIFont {
  static func customFont(
    variant: CustomFontVariant, 
    size: CGFloat
  ) -> UIFont? {
    switch variant {
      let fontName: String
      case: .regular:
        fontName = "Inter-Regular"
      case: .medium:
        fontName = "Inter-Medium"
    }
    return UIFont(name: fontName, size: size)
  }
}
```

Adding the `light` variant was simple (I thought)

```Swift

public enum CustomFontVariant {
  case light
  case regular
  case medium
}

extension UIFont {
  static func customFont(
    variant: CustomFontVariant, 
    size: CGFloat
  ) -> UIFont? {
    switch variant {
      let fontName: String
      case: .light:
        fontName = "Inter-Light"
      case: .regular:
        fontName = "Inter-Regular"
      case: .medium:
        fontName = "Inter-Medium"
    }
    return UIFont(name: fontName, size: size)
  }
}
```

The issue was, that the `UIFont` being returned by the method was always `nil`.

The issue, after an embarrassingly long amount of debugging, was the fact that while the font file was named `Inter-Light` the "real name" of the font was actually `Inter-Regular_light`…

And how do you discover this "real name"? Well you follow [_the code that Apple includes in the documentation_](https://developer.apple.com/documentation/uikit/text_display_and_fonts/adding_a_custom_font_to_your_app).

```Swift
for family in UIFont.familyNames.sorted() {
    let names = UIFont.fontNames(forFamilyName: family)
    print("Family: \(family) Font names: \(names)")
}
```

Just more proof that even though you've been developing mobile apps since iOS 5, you still should check the docs.
