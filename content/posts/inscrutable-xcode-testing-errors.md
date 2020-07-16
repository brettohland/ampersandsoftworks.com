---
title: "Inscrutable Xcode Testing Errors"
date: 2015-08-06T19:51:30+00:00
draft: false
tags: ["xcode", "xctest"]
---

I just experienced the most bizarre error while attempting to run some Xcode unit tests:

>IDEBundleInjection.c: Error 3588 loading bundle '/Users/bohland/Library/Developer/Xcode/DerivedData/iPhone-ekwcwqbkoffufcgwkcjkmkzrwhnn/Build/Products/Debug-iphonesimulator/XXX.xctest': The bundle “XXX.xctest” couldn’t be loaded.
    
### Backstory

This App is a massive project with many developers working at the same time. It uses `cocoapods` to manage packages and there are many many many branches.

I'm working on a feature with another dev, I was working on some unit tests and wanted to update my  branch with the other dev's changes.

I did a git pull with no issues and all of a sudden any testing would fail with the above error.

### Solution

There wasn't a lot of help online with this issue and it seemed to be fairly common within the organization to have this happen. Many of our branches have different pods that are being added and removed, causing the need to regen your podfiles a lot.

The solution was to delete everything that Cocoapods generates: `Pods/`, `Podfile.lock` **AND** the `.xcodeworkspace` file.

Simple as that. Hope this helps someone else.