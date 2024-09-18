---
layout: post
title: Building A Stopwatch And Timer Using Xcode 16's New SystemFormatStyles
description: SwiftUI Documentation continues to be lacking.
tags: [ios, development, swift, formatstyle]
date: 2024-09-18T06:00:57-06:00
---

Apple has provided some new format style implementations with Xcode 16 (which is in beta as of this writing).

I've been working to update the [Gosh Darned Site](https://goshdarnformatstyle.com/) to include all of the new updates, but ran into a wall when it comes to two of the new SwiftUI-only styles: `SystemFormatStyle.Stopwatch` and `SystemFormatStyle.Timer`.  Initially, I expected to get an animating SwiftUI view "for free" without needing to create any sort of a view hierarchy but quickly found out I was wrong.

Trying to figure out they're to be used was frustrating. Apple's documentation is pretty sparse, as is the code comment documentation in `SwiftUICore`. 

Because these new styles aren't a part of `Foundation`, you can't see their internals at the [Swift Foundation](https://github.com/apple/swift-foundation) Github repo. It's unclear exactly how to use these new styles to make a stopwatch or a timer in your views. 

I did figure it out, and decided that sending some information out into the &aelig;ther might help out any other devs who're looking to use these styles.

# A `FormatStyle` Refresher

In brief, format styles are Apple's modern Swift replacements for the older Objective-C `Formatter` classes. They allow you to quickly and easily create localized string representations of various data types to display to a user without all of the "gotchas" relating to the old classes.

They're safe, performant, and really easy to use throughout your code to convert one type into another. Apple provides quite a few implementations for all sorts of data types from dates, numbers, lists, to measurements.

I've covered them extensively in the past, as well as created an entire site which fills in the gaps in Apple's documentation.

- [FormatStyle Deep Dive](/posts/format-style-deep-dive/)
- [Gosh Darned FormatStyle](https://goshdarnedformatstyle.com)

The big issue is that until very recently Apple's documentation has been extremely sparse, making these powerful tools hard to use.

---

# `SystemFormatStyle` Differences from `FormatStyle`

All of the new styles included in the `SystemFormatStyle` enum/namespace are all made to format `Date` objects. However unlike the `FormatStyle` implementations inside of `Foundation` which have their outputs set to be `String` values, these new styles will output an `AttributedString` by default.

The only SwiftUI View that accepts an `AttributedString` is the `Text` View, and that's only because Apple added a new initializer which accepts it. This really isn't as limiting as it might seem at first, really the only places you're going to be using these new styles are in a `Text` view anyway.

One last big difference that's only present in the new `SystemFormatStyle.Stopwatch` and `SystemFormatStyle.Timer` styles is that a second data value is passed into the styles in order to correctly calculate date offsets. All other `Foundation` format styles will accept different `enum` types which control the output of style. These are the first ones which take in an additional value or object in order to work.

Enough preamble, let's build a stopwatch.

# Stopwatch MVP

The MVP for a stopwatch that counts up needs two pieces of data to function, and two pieces of UI:

1. Data
	1. A `Date` which represents starting time
	2. A `Date` which represents the current moment in time to calculate an offset to the starting time
2. UI
	1. A `Text` view to show the styled differences between those dates
	2. A `Button` which starts the stopwatch counting up

Lets build that out:

```swift
struct Stopwatch: View {
    @State var startDate: Date? // 1.1

    var body: some View {
        Text(Date.now, format: .stopwatch(startingAt: startDate ?? .now)) // 2.1 
        Button("Start") { // 2.2
            startDate = .now
        }
    }
}
```

This gives us the base view hierarchy that we'll need to make our stopwatch. It's nonfunctional right now, since our start and end dates are `Date.now` and there's no mechanism to animate the view.

![The SwiftUI Output of the above code](/images/2024/Aug/stopwatch-mvp.png)

It's `2.1` where our new `SystemFormatStyle.Stopwatch` style is being used. We're using the new initializer on the `Text` view which takes in a type as well as a format style which has it's output set to an `AttributedString`. The `.stopwatch(startingAt:)` static method we're using here is an Apple-provided extension on `FormatStyle` that we use as a shortcut to creating a new instance of the required `SystemFormatStyle.Stopwatch` format style.


## Adding Animation Using TimelineView

Animating a millisecond-precise stopwatch is actually filled with technical and logistical challenges. You have to redraw the screen at a rate that is both as fast as the stopwatch updates yet not so fast as it's more often than the refresh rate of the screen. Oh, and the device displaying this stopwatch to the user might have [Pro Motion](https://developer.apple.com/documentation/quartzcore/optimizing_promotion_refresh_rates_for_iphone_13_pro_and_ipad_pro). Good luck!

Thankfully, Apple provides a view which takes care of redrawing the screen for us _and_ provides us with the appropriate `Date` object to satisfy 1.2: A `Date` that represents the current moment to show the length of time since the stopwatch began counting.

Let's add that, and also let's add a reset button and a few view modifiers to make things look nice.

```swift
struct Stopwatch: View {
    @State var anchorDate: Date? // Stores when the user presses the start button
    @State var lastUpdate: Date? // Stores the date of the last update on screen
    @State var isAnimationPaused = true // Flag to control the animation update schedule

    var body: some View {
        // A view which periodically updates itself based on a schedule.
        TimelineView(.animation(paused: isAnimationPaused)) { context in
            // The `context` object provides the `Date` at which the view was redrawn
            //
            Text(
                // We fall back on the context.date since the view will not accept an optional value
                lastUpdate ?? context.date,
                // The format style uses `Date.now` as the anchor date initially to display "0:00:00"
                format: .stopwatch(startingAt: anchorDate ?? .now)
            )
            .font(.title)
            // The onChange listener allows us to store the date at which the last update was drawn.
            // This is specifically to keep the final duration of the stopwatch on screen once the Stop button
            // is pressed
            .onChange(of: context.date) { _, newValue in
                lastUpdate = newValue
            }
        }
        HStack {
            Button("Start") {
                // Store the moment at which the user presses the Start button
                anchorDate = .now
                // Unpause the TimelineView's animation schedule
                isAnimationPaused = false
            }
            .buttonStyle(.bordered)
            .tint(.green)
            .disabled(isAnimationPaused == false)
            Button("Stop") {
                // We only pause the animation schedule to stop the
                isAnimationPaused = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(isAnimationPaused)
        }
    }
}
```

We now have a a fully functioning stopwatch.

![A screen recording of the completed stopwatch](/images/2024/Aug/stopwatch-complete.gif)

---

# Let's Build A Timer Using `SystemFormatStyle.Timer`

Conceptually, `SystemFormatStyle.Timer` is similar to `SystemFormatStyle.Stopwatch`. The `Date` object that we apply the format to is the "current" date used for the style's calculation, but instead of a single `Date` representing the starting time of the stopwatch, we pass a `Range<Date>` value representing the upper and lower bounds of the timer.

If you're a visual learner (like myself), this might help:

```
   0:00                                                              0:10
LowerBound                                                        UpperBound <- Range<Date>
    └----------------------------------------------------------------- ┘
                                  <-|
                                   0:05
                                currentDate
```

- If the current date is at or below the lower bound, it will display `0:00`
- If it's within the range, it will calculate and display the offset between the current date and the lower bound
- If the current date is at or above the upper bound, it will display the offset between the lower and upper bound

## Timer Code Example

The base structure of the view hierarchy is really similar to the stopwatch:. We have a `Text` view wrapped in a `TimelineView` to provide animations, a `Stepper` to add time to the timer, and some buttons to stop and reset it, and a few `@State` variables to trigger some actions and store values.

```swift
struct CountdownTimer: View {
    private let timerStepRange = 0 ... 60

    @State var isAnimationPaused = true // Flag to control the animation update schedule
    @State var isTimerDone = false // Flag set when the timer has completed
    @State var timerRange: Range<Date>? // Stores the range of the timer
    @State var timerStep = 0 // Bound to the stepper to control the timer

    var body: some View {
        timerDisplay
            .font(.title)
            .foregroundStyle(isTimerDone ? .green : .primary)
        stepperControls
        buttons
    }

    var timerDisplay: some View {
        // A view which periodically updates itself based on a schedule.
        TimelineView(.animation(paused: isAnimationPaused)) { context in
            // The `context` object provides the `Date` at which the view was redrawn
            Text(
                // If the context's current date is within the format style's range, then it will
                // display the remaining time to the user
                context.date,
                // We need to provide the format style with the upper and lower bounds of a valid
                // timer date. Otherwise, we fall back to a range which will display a zero value to
                // the user
                format: .timer(countingDownIn: timerRange ?? .now ..< .now)
            )
            // We react to the changing context's date in order to determine when the timer
            // has completed its countdown
            .onChange(of: context.date) { _, newValue in
                    // Checking that the context's date property is within the valid timer range is
                    // the easiest way to determine if the timer has completed
                    guard timerRange?.contains(newValue) == false else {
                        return
                    }
                    handleTimerFinished()
                }
        }
    }

    var stepperControls: some View {
        // A simple stepper that adds seconds to the timer in increments of 10
        Stepper(value: $timerStep, in: timerStepRange, step: 10) {
            Text("Seconds")
                .padding()
        } onEditingChanged: { didPressDown in
            // Verify that the user has released the button
            guard didPressDown == false else { return }
            timerRange = makeTimerRange(addingSeconds: TimeInterval(timerStep))
        }
    }

    var buttons: some View {
        HStack {
            Button("Start") {
                // Reset the timer's "done" flag
                isTimerDone = false
                // Recalculate the timer's range based on the current step on the Stepper vie
                timerRange = makeTimerRange(addingSeconds: TimeInterval(timerStep))
                // Unpause the TimelineView
                isAnimationPaused.toggle()
            }
            // Disable the button if the timer is running OR if the stepper value is '0"
            .disabled(isAnimationPaused == false || timerStep == 0)
            .tint(.green)
            Button("Stop") {
                isAnimationPaused.toggle()
            }
            // Disable the button if the animation is paused
            .disabled(isAnimationPaused)
            .tint(.red)
        }
        .buttonStyle(.bordered)
    }

    /// Returns a `Range<Date>` that can be used by timer's format style
    /// - Parameter seconds: `TimeInterval`
    /// - Returns: `Range<Date>` where the lower bound is the current date and the upper bound is the
    /// current date adding the `seconds` parameter
    func makeTimerRange(addingSeconds seconds: TimeInterval) -> Range<Date> {
        // We capture the current date to be used throughout this method to guarantee accuracy
        let currentDateTime = Date.now
        // Make sure that our seconds value is greater than zero. This guarantees that our range calculations 
        // will be formatted correctly.
        guard seconds > 0 else {
            // Otherwise we return a 0 value
            return currentDateTime ..< currentDateTime
        }
        // Date calculations should _always_ be done using the `Calendar` APIs to avoid any sort of strange date
        // related edge cases.
        let upperBoundDate = Calendar.current.date(byAdding: .second, value: Int(seconds), to: .now)
        // As a fallback, we use the less-safe (but probably okay) Date API.
        return currentDateTime ..< (upperBoundDate ?? currentDateTime.addingTimeInterval(seconds))
    }

    func handleTimerFinished() {
        // Stops the `TimelineView` from animating and therefore stops the `onChange` view modifier
        // from firing
        isAnimationPaused = true
        // Set the completion flag to true
        isTimerDone = true

        // Additional animation, sounds, or system notifications can be added here
    }
}
```

Running this code, you'll end up with a very simple countdown timer:

![A screen recording of the completed countdown timer](/images/2024/Aug/timer-complete.gif)

# Just The Beginning

These new styles are two of a handful that are being released with Xcode 16 under the `SystemFormatStyle` enum/namespace and examples only scratch the surface of what these new format styles can do. Unfortunately I wish I could say to "read the docs", but the sad truth is that Apple has once again woefully fallen short in sharing documentation with their developers. 

Thankfully in the comings weeks, there will be updates to the [Gosh Darn Format Style](https://goshdarnformatstyle.com) that documents everything (and more!).
