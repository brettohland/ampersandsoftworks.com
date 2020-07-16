---
title: "Killing Bluetooth From The Terminal"
date: 2015-12-18T15:10:42+00:00
draft: false
tags: ["terminal"]
---

Not sure if I'm the only one on the internet who has this problem but…

Have you ever opened up your Mac to do some work and not be able to use the internal trackpad to click on anything? Does it turn out that this happens because you're still in bluetooth range and something heavy is sitting on the Magic Trackpad in the other room?

This happens to me fairly often, especially when we have guests over (the spare bedroom is also the guest room and the desk ends up as a dumping point).

Now what happens if the occupants of the room are still asleep and you have just a few precious moments to work on [your book](https://www.packtpub.com/application-development/xcode-7-essentials-second-edition) before the toddler wakes up and requires your full attention?

You fire up your termal and type these two commmands:

```
sudo defaults write /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState 0

sudo killall blued
```

If you're feeling super fancy, you can create a bash or zsh alias:

```
alias killbluetooth="sudo defaults write /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState 0 && sudo killall blued"
```

This sets the bluetooth pref to `off` and then resets the bluetooth process so that new value is read.

Problem solved.