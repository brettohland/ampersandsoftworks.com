---
title: "Building a Keyboard (My Ergodox Story)"
date: 2015-08-14T10:57:59-06:00
draft: true
---

<small>(Or, how I made my life really complicated for a little while.)</small>

![](/images/2015/Aug/ergodox_complete-1.jpg)

Have you ever had a problem? One that is easy enough to solve but because of your personality you end up making your life exceptionally more complicated for a little while?

I'm guessing yes if you're reading this. So let's talk about how I ended up building a keyboard using open source hardware shipped from Poland.

## The Issue.

I love mechanical keyboards. Especially [tenkeyless models with Cherry MX Blue keyswitches](http://amzn.to/1SIXUSV). Unfortunately, using the keyboard for development can cause everyone around you to quickly think about [defenestration](https://en.wikipedia.org/wiki/Defenestration).

The standard issue keyboard at my current job is the standard [Apple Bluetooth keyboard](http://amzn.to/1g5gByC). I used it as my daily driver for 6 months and managed to develop some early signs of RSI.

Stop everything, this needs to change.

## The Solution.

This is where I fell down a hole. I ended up discovering the world of open source hardware keyboards. The front-runner that I found was the [Ergodox](http://ergodox.org).

It's essentially an open-source, smaller version, non dished version of the [Kinesis Advantage](http://amzn.to/1InfTnP). You get a split keyboard who's keys are in a matrix layout with the added advantage of having layer support. Plus it's completely re-programmable to fit your needs.

Since it's a kit, you can put whatever keyswitches you want into it. I decided that [Cherry MX Brown](http://deskthority.net/wiki/Cherry_MX_Brown) keys would fit my needs nicely (they're quiet and have a tactile actuation point).

## The Quest for the Ergodox

If you had the dedication, motivation, time, and money, you can truly build one from scratch. Another option is [Massdrop](http://massdrop.com), they're a company that uses group buying power to purchase things at a discount. [They offer the keyboard as a kit](https://www1.massdrop.com/buy/ergodox) a few times a year but unfortunately I missed their most recent drop ([for their fancier Ergodox Infinity](https://www1.massdrop.com/buy/infinity-ergodox)) by a few months.

This is where I discovered [Falbatech](http://falbatech.pl/prestashop/index.php). They sell all of the parts (and even offer to [pre-build](http://falbatech.pl/prestashop/index.php?id_product=13&controller=product&id_lang=2) some of the more difficult aspects of the kit for you).

[The parts you need are as follows](http://ergodox.org/Hardware.aspx):

- The Ergodox PCB
- All electronics components
- A Teensy Microcontroller
- A case to put everything in
- Your choice of keyswitches
- Keycaps
- Firmware + Software

I purchased the [electronics](http://falbatech.pl/prestashop/index.php?id_product=25&controller=product&id_lang=2), [PCB](http://falbatech.pl/prestashop/index.php?id_product=10&controller=product&id_lang=2), [Teensy](http://falbatech.pl/prestashop/index.php?id_product=11&controller=product&id_lang=2), [case](http://falbatech.pl/prestashop/index.php?id_product=44&controller=product&id_lang=2) and [partial assembly](http://falbatech.pl/prestashop/index.php?id_product=13&controller=product&id_lang=2) from Falbatech.

I purchased [Gateron Brown keyswitches from Amazon](http://www.amazon.com/Gateron-KS-3-Mechanical-type-Switch/dp/B00YKLRVSO/ref=sr_1_1?ie=UTF8&qid=1438449908&sr=8-1&keywords=gateron+brown) (They're a competitor to Cherry and offer a similar keyswitch)

I purchased a set of white and orange keycaps from [Pimp My Keyboard](http://keyshop.pimpmykeyboard.com/products/full-keysets/dsa-blank-sets-1) (They offer a full set of Ergodox modifier keys).

I decided to start off with the firmware recommended by Massdrop (https://github.com/benblazak/ergodox-firmware/) but am looking at the ergodox fork of the [TMK firmware](https://github.com/cub-uanic/tmk_keyboard)

## The Issues Begin

I purchased the [compact PVC case from Falbatech](http://falbatech.pl/prestashop/index.php?id_product=44&controller=product&id_lang=2). A few days after placing my order they updated their store page to include a warning that the compact case is difficult to put together and they recommend that you get them to fully assemble it. This understandably freaked me out a it, considering that I hadn't soldered anything in a decade. The idea of shipping the case back to Poland wasn't terribly exciting.

The canonical assembly instructions online are the ones you find on Massdrop. They talk about soldering the keyswitches in place by first pushing the posts through the case, and PCB and then soldering as you would expect from there. Simple and easy.

The issue with the Falbatech compact case is that the keyswitch posts end up flush with the back side of the PCB. When I emailed them for instructions it turns out that they're relying on the fact that the Ergodox PCBs are built double-sided. Thus you need to create a solder bubble on the underside of the board using your iron.

![](/images/2015/Aug/IMG_7765.JPG)<br><small>Photo by Falbatech</small>

This turned out to be a simple enough thing to do. I had to be careful to line up each switch to the board holes while I was installing them however. There were at least three switches that I installed that weren't properly showing continuity when I tested them and needed to be re-soldered.

![](/images/2015/Aug/soldering.jpg)

I first installed all of the switches to the right hand board and began assembling the case. This is when an unfortunate realization dawned on me. You see, the Teensy was now soldered _behind_ the case with no access hole to the front switch. The Teensy was stock, it had the factory firmware installed which did nothing but blink the front LED every few seconds.

Uh oh.

I needed access to the front button in order to load the Ergodox firmware. Not to mention that I needed access to be able to reload new keyboard configurations in the future.

The solution thankfully wasn't to de-solder the keyswitches (whew), it turns out that you can pull back the case from the board and use the included allen key to reach in and hit the button. Crisis averted. The further issue of accessing the button to reprogram is even easier as the firmware includes a software reprogramming button on layer 2.

![](/images/2015/Aug/teensy.jpg)

The final issue that I'm still tackling is the issues of a few of the keyswitches being flaky. Sometimes they will double press, sometimes a key will simply not register at all.

Over the following few weeks I slowly figured out which of the keys were the worst, it slowly became apparent that the issue was improperly soldered switches. Pressing the switches into the case would almost always fix the issues. The solution was pretty easy, just take the keyboard apart and add a lot more solder to each of the keys.

After that, the keyboard ran like a dream.

## The First Week of hell
I had a rough first week with the keyboard. Not going to lie.

I discovered pretty quickly just how badly my typing skills had degraded from "Using all 5 fingers on each hand in home row" to "Primarily using three fingers and your thumb while madly floating your hand position over they keyboard". I used my right hand to hit the "t" and "g" keys all of the time and my left hand ring finger was atrophied.

While I was re-learning home row I also had to constantly engage my brain to find keys. I found that I was going home at the end of the mentally exhausted from this. My old keyboard was sitting there mocking me the entire time, its siren's call whispering just how much easier it would be to give up and go back.

I pushed through. Two things happened that were indicative of my progress:

1. I managed log into my work machine without error.
2. I managed to unlock my 1Password vault using the Diceware passphrase I generated without error.

The best thing I did was print off a physical copy of my layout and tape it to my monitor.


## The Benefits.
I took a package of index cards and used them to tent the keyboard. This quickly relieved the RSI issues I was starting to feel and put my hands in a much more natural position.

It's been a month and the strain has moved from my wrists to my shoulders. Good/bad news I guess, it just tells me that I have more work to do on my ergonomics of my work setup before I can claim complete win.

Coding wise, the best thing that I did was create a layer that toggles the right-hand home row to use Vim movement keys.

A full month of usage and a few disassemblies to re-solder some switches has gotten me back to my previous typing speed.

## The Future/In Conclusion

So was it worth it? Yes, I'd say it was. I like having a reprogrammable keyboard if not just for the neckbeard points but for extreme flexibility.

I think the next step software wise is to get the TMK firmware installed. It gives me media keys and the ability to wake the system from sleep (which is something the keyboard can't do right now which always throws me off).

Various places online will offer group buys for printed Ergodox keycap sets. I'm not sure if I'd want to go back to printed set or not but I may also modify the colour scheme in the future.

The cables that comes with the Falbatech electronics package are pretty cheap. Pexon, a company based in the UK sells high quality sleeved cable [sets for the Ergodox](http://pexonpcs.co.uk/collections/usb-cables/products/ergo-dox-keyboard-cables). You can customize wraps and make them coiled. I think some orange creamcicle cables in my future.

Questions? Comments? Let me know and I can help point you in the right direction.
