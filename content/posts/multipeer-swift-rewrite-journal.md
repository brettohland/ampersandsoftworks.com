---
title: "Multipeer Swift Rewrite Journal"
date: 2014-06-10T16:11:16+00:00
draft: false
tags: ["xcode", "objective-c", "multipeer"]
---

(This is a companion post to [this one](http://ampersandsoftworks.com/swift-multipeer-rewrite/))

### June 9, 2014

#### 14:20: 
Created a new project in Xcode 6, created a single view application and choosing Swift as my language. Took a quick poke around, SO WEIRD to see .swift extensions and no .m/.h files.

Looked at the Storyboard and saw the new Adaptive UI stuff. [Good thing I shotgunned](https://twitter.com/bretto/status/475809312720166913) the [What's New in Cocoa Touch](https://developer.apple.com/videos/wwdc/2014/#202-video) [session last night](https://twitter.com/bretto/status/475961894222589952).

#### 14:30
Figured out the Adaptive UI stuff pretty quickly, was able to get it up and running with some Auto Layout Magic™ easily.

#### 14:40
Testing layouts with a toddler on your lap is difficult.

#### 14:50
Started writing my first bits of Swift. Got all of the IBOutlets and IBactions created just like I would for Objective-C.

Read the docs, got the view controller saying that it can be delegates for the various multipeer framework objects.

``` Swift
import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate  {
    @IBOutlet var myPeerIDLabel : UILabel
    @IBOutlet var theirPeerIDLabel : UILabel
    @IBOutlet var theirCounterLabel : UILabel
    @IBOutlet var counterButton : UIButton
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func incrementCounterAndSend(sender : UIButton) {
        
    }

}
```

I can't seem to get the autocomplete to help me out when it comes to implementing all of the required protocols for these various objects though. Still looking.

#### 15:10

Yeah, looks like there's just weird issues with this version of Xcode 6. Once, and only once did I get the autocomplete to spit out 

``` Swift
func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {}
```
But I did manage to get the compiler to stop complaining `'ViewController' does not conform to protocol MCNearbyServiceAdvertiserDelegate`.

#### 15:20
It looks like it's something that's up with typing 'advertiser' that the autocomplete doesn't kick in. Bug report time.


#### 15:30
Weird. Setting the class properties kept giving me an error `Class `viewController' has no initializers`.

Setting them as optionals fixes it

``` Swift
    var session: MCSession?
    var advertiser: MCNearbyServiceAdvertiser?
    var browser: MCNearbyServiceBrowser?
    var localPeerID: MCPeerID?
    var connectedPeers = []
```

Ah, the docs make it clear:


>Classes and structures must set all of their stored properties to an appropriate initial value by the time an instance of that class or structure is created. Stored properties cannot be left in an indeterminate state.
>
>Properties of optional type are automatically initialized with a value of nil, indicating that the property is deliberately intended to have “no value yet” during initialization.

They need to be set as optionals since they have no initial state. Gotta remember to unwrap them.

#### 15:33
Booleans are `false` and `true`. Whole lot of muscle memory is going to keep me writing `YES` and `NO`.

#### 15:50
Using the optionals to initialize a local instance isn't making any sense. I think I need to watch more sessions

#### 20:30
Okay, what was I smoking a few hours ago. It's pretty simple. I had declared optionals and for some reason I was attempting to unfold the values before assigning them:

``` Swift
browser! = MCNearbyServiceBrowser(peer: localPeerID!, serviceType: HotColdServiceType)
```

It's that one "!" that's the issue. Of course I don't want to unwrap the value, I'm trying to set the value.

The rest of this should go much more smoothly

#### 20:45
Almost rewritten. Not really taking advantage of many of the new Swift features but that can be forgiven considering this is the first bit of actual Swift code I'm writing in earnest.

Had my first run-in with the array literal syntax. I needed to create a class level property for storing MCPeerIDs, ended up having to declare it like so:

``` Swift
var connectedPeers: MCPeerID[] = []
````	

It's kind of weird declaring what the array will store when you initialize it, but I could get used to it.

#### 21:15
Grand Central Dispatch! I was hitting my head as to how to pass a block into the dispatch_async method when I realized that I just pass in a closure.

``` Swift
dispatch_async(dispatch_get_main_queue(), {
    self.theirPeerIDLabel.text = peerID.displayName
    self.counterButton.enabled = true
})
```

Honestly, it couldn't be any more simple. Interesting that it explicitly yelled at me to call self within the closure, I was expecting that to just error out.

#### 21:20
So, I guess Swift native strings can't be created from NSData. Kind of odd, using native strings everywhere and then having to write some good ol' NSString. I think this is something that will confuse new programmers when they start.

``` Swift
let message = NSString(data: data, encoding: NSUTF8StringEncoding)
```

#### 21:25
Must be getting the hang of this, just converted a string to NSData in one line:

``` Swift
let data = "\(buttonCounter) times".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
```

#### 21:30
Started debugging and immediately started getting `EXC_BAD_ACCESS` errors on the MCSessionDelegate methods. Ugh. Done for the night.

### June 10, 2014

#### 9:40
Decided to look at my testing strategy. I was using an instance of the app in the simulator and an instance of my old Objective-C app. Instead, this morning I changed the deployment target to iOS 7 and ran it on my two testing devices. 
Lo and behold, it started working. 
The last thing I did was I rewrote all of the `NSLog` statements as `println` statements. I think that was the last bit of objective-c habits I need to purge. 

## All done

- [Code on GitHub](https://github.com/brettohland/MultipeerSwiftPrototype)
- [Write Up](http://ampersandsoftworks.com/swift-multipeer-rewrite/)