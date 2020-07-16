---
title: "Hot&Cold - Prototype Code Review"
date: 2014-05-18T04:49:06+00:00
draft: false
tags: ["multipeer", "hotcold"]
---

[Aaand I have iBeacons. (v0.1)](https://github.com/brettohland/HotCold/tree/1b900992f796ced588335a6cee5385b3856acf42)

All told, I had the iBeacon code up and running in a little less that 2 hours. Unfortunately, those 2 hours were spread over three weeks as my 9 month old son decided to go through a sleep regression. Babies!

Back to the code.

![](/images/2014/May/storyboard.png)

The code itself was simple after reading the API docs. I've broken out the applications into three ~~beautifully designed~~ screens.

- [ASWChoiceViewController](https://github.com/brettohland/HotCold/blob/1b900992f796ced588335a6cee5385b3856acf42/HotCold/ASWChoiceViewController.m): Lets you choose your action.
- [ASWHideViewController](https://github.com/brettohland/HotCold/blob/1b900992f796ced588335a6cee5385b3856acf42/HotCold/ASWHideViewController.m): Activated the iBeacon.
- [ASWSeekViewController](https://github.com/brettohland/HotCold/blob/1b900992f796ced588335a6cee5385b3856acf42/HotCold/ASWSeekViewController.m): Shows the distance to the beacon.
- [ASWDefaults](https://github.com/brettohland/HotCold/blob/1b900992f796ced588335a6cee5385b3856acf42/HotCold/ASWDefaults.m): Some shared defaults for the app.

The app is using Storyboards.


## [ASWChoiceViewController](https://github.com/brettohland/HotCold/blob/1b900992f796ced588335a6cee5385b3856acf42/HotCold/ASWChoiceViewController.m)

![](/images/2014/May/Screen-Shot-2014-05-17-at-8-10-08-PM.png)

Honestly, nothing too much of interest here. The app has a couple of segues set up. Each of the two buttons are hooked up to the same `IBAction` call and depending on which one you select you end up going to the required screen.

``` Objective-C
- (IBAction)gotoSegue:(UIButton *)sender {
    NSString *segueIdent = @"";
    if ([sender.titleLabel.text isEqualToString:@"Hide"]) {
        segueIdent = @"toSend";
    } else {
        segueIdent = @"toReceive";
    }
    [self performSegueWithIdentifier:segueIdent sender:self];
}
```
## [ASWDefaults](https://github.com/brettohland/HotCold/blob/1b900992f796ced588335a6cee5385b3856acf42/HotCold/ASWDefaults.m)

The implementation of this is almost identical to [Apple's AirLocate APLDefaults file](https://developer.apple.com/library/ios/samplecode/AirLocate/Listings/AirLocate_APLDefaults_m.html#//apple_ref/doc/uid/DTS40013430-AirLocate_APLDefaults_m-DontLinkElementID_14)

### ASWDefaults.m

``` Objective-C
//ASWDefaults.h
extern NSString *BeaconIdentifier;
```

``` Objective-C
//ASWDefaults.m
NSString *BeaconIdentifier = @"com.example.ampersand-softworks.HotCold";
```

The `BeaconIdentifier` is simply being stored as a global string constant and is declared in the header file.


``` Objective-C
-(id) init { 
    self = [super init];
    if (self){
        _supportedProximityUUIDs = @[[[NSUUID alloc] initWithUUIDString:@"D9EED498-BFDB-43C0-8B55-D06BB74C430B"]];
        _defaultPower = @-59;
    }
    return self;
}
```
The `init` method populates an array of supported UUIDs, I simply used the `uuidgen` command in the terminal to get myself a new one and added it to the list. This is future-proofing the app as well since adding support for a whole new set of beacons is trivial.

``` Objective-C
+(ASWDefaults*) sharedDefaults {    
    static id sharedDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDefaults = [[self alloc] init];
    });
    return sharedDefaults;
}
```
In the past I've used the `@synchronized` in order to thread this. This is my first chance to use GCD and blocks in this manner. I heart blocks.

``` Objective-C
- (NSUUID *) defaultProximityUUID {
    return _supportedProximityUUIDs[0];
}
```
Simply returns the one (and only) uuid that we're using. Again, future proofing.

### ASWDefaults.h

Simply exposes the stuff that was set up.

``` Objective-C
extern NSString *BeaconIdentifier;

@interface ASWDefaults : NSObject

+(ASWDefaults *) sharedDefaults;

@property (nonatomic, copy, readonly) NSArray *supportedProximityUUIDs;
@property (nonatomic, copy, readonly) NSUUID *defaultProximityUUID;
@property (nonatomic, copy, readonly) NSNumber *defaultPower;

@end
``` 

## [ASWHideViewController](https://github.com/brettohland/HotCold/blob/1b900992f796ced588335a6cee5385b3856acf42/HotCold/ASWHideViewController.m)

![](/images/2014/May/Screen-Shot-2014-05-17-at-8-10-11-PM.png)

Let's get our device broadcasting as an iBeacon. I was surprised at just how little code was needed in order to get the beacon broadcasting with the required region information. 

``` Objective-C
@import CoreLocation;
@import CoreBluetooth;
```

Awwwwww yeah, precompiled header modules. I'm pretty sure the guy giving [the talk on modules](https://developer.apple.com/wwdc/videos/?include=205#205) at WWDC mentioned that all `#import` calls are mapped to `@import` behind the scene. 


``` Objective-C
CBPeripheralManager *perhipheralManager = nil;
CLBeaconRegion *region = nil;

NSDictionary *beaconPerhipheralData;
NSNumber *power = nil;
```

We need an instance of the [CBPerhipheralManager](https://developer.apple.com/Library/ios/documentation/CoreBluetooth/Reference/CBPeripheralManager_Class/Reference/CBPeripheralManager.html) and the [CLBeaconRegion](https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLBeaconRegion_class/Reference/Reference.html) classes to begin broadcasting. 

- `CBPeripheralManager` is what actually handles the bluetooth broadcasts.
- `CLBeaconRegion` gets fed the uuid, major version, minor version and identifier so the peripheral manager knows what values to throw out into the aether.

The `beaconPerhipheralData` dictionary and the power variables are simply there to hold setup values.

``` Objective-C
@interface ASWHideViewController () <CBPeripheralManagerDelegate>

@property NSUUID *uuid;
@property NSNumber *major;
@property NSNumber *minor;

@end
```

- We set ourselves up to receive any `CBPeripheralManager` events that get fired 
- Set up some private variables.

``` Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.uuid = [ASWDefaults sharedDefaults].defaultProximityUUID;
    self.major = [NSNumber numberWithShort:0];
    self.minor = [NSNumber numberWithShort:0];
    power = [ASWDefaults sharedDefaults].defaultPower;
    
    region = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid
                                                     major:[self.major shortValue]
                                                     minor:[self.minor shortValue]
                                                identifier:BeaconIdentifier];
    beaconPerhipheralData = [region peripheralDataWithMeasuredPower:power];
}
```
Inside the `viewDidLoad` we pull the `uuid`, `major`, `minor`, `identifier` and `power` values from the ASWDefaults file and alloc a new instance of the `CLBeaconRegion`. From there, we store that value in a dictionary for future peripheral manager use.

``` Objective-C
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!perhipheralManager) {
        perhipheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                                   options:nil];
    } else {
        perhipheralManager.delegate = self;
    }
}
```
Lazy load the peripheral manager with a default background thread.

``` Objective-C
-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"TRANSMITTING");
        [perhipheralManager startAdvertising:beaconPerhipheralData];
    } else if (peripheral.state == CBPeripheralManagerStatePoweredOff){
        NSLog(@"Transmission Ceased");
        [perhipheralManager stopAdvertising];
    }
}
```
Here's where the magic happens. If bluetooth is turned on we begin broadcasting the iBeacon region information using startAdvertising. Just like that, we have an iBeacon.

## [ASWSeekViewController](https://github.com/brettohland/HotCold/blob/1b900992f796ced588335a6cee5385b3856acf42/HotCold/ASWSeekViewController.m)

![](/images/2014/May/Seek-Screen.png)

The first bit of surprising information that I discovered is that all of the iBeacon receiving code is handed by a Core Location locationManager instance. The minute that you initialize it, the user is asked if they will allow you app to know your location.

It makes sense, you could get someone's location within a centimetre with a combination of an iBeacon and GPS. It was just a bit unexpected that the first time I ran the app.

Right now, the prototype simply shows the distance to the beacon (the value is actually the `accuracy` value from a CLBeacon).

``` Objective-C
@interface ASWSeekViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *howClose;

@property CLLocationManager *locationManager;
@property NSMutableDictionary *rangedRegions;

@end
```
The `CLLocationManager` does all of the magic and this view controller is it's delegate. Some other properties are simply set up.

``` Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    for (NSUUID *uuid in [ASWDefaults sharedDefaults].supportedProximityUUIDs) {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        self.rangedRegions[region] = [NSArray array];
    }
}
``` 
The loop here is pretty interesting. 

What we're doing is grabbing all of the beacon UUIDs from ASWdefaults file and filling the rangedBeacons array with CLBeaconRegion instances containing those values. This is used in the `locationManager:didRangeBeacons` and `locationManager:startRangingBeaconsInRegion` methods.

``` Objective-C
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    for (CLBeaconRegion *region in self.rangedRegions) {
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}
```
This is where the magic happens. Just loop through the CLBeaconRegions in the rangedBeacons dictionary and start listening for events.

``` Objective-C
-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {

    if ([beacons count] > 0) {
        // Let's assume we're getting one beacon for now.
        CLBeacon *beacon = beacons[0];
        self.howClose.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
    } else {
      self.howClose.text = @"No Beacons Found";
    }
    
}
```
If a beacon is found we simply show the `accuracy` value on screen. I do get weird instances when I get -1.000 as the value. It seems to happen if there's a lot of interference.

I'll have to do more testing with the accuracy values to see what can happen. 


## Final thoughts
- The app will probably crash right now if you have bluetooth disabled. I'll have to lock down the app at various points to alert the user that it's required. Not too bad.
- I'll have to figure out the messaging for how the app asks for access to your location. It might be a bit surprising if the user gets the location request since location = GPS (at leas in my mind) and I'm not using that at all.
- The location manager in ASWSeekViewController assumes that it'll find only one beacon. The rest of the code is future proof but this one is a hack. Need to finish it off.
- The `accuracy` value I'm getting back on the beacons returned from `locationManager:didRangeBeacons:inRegion` method isn't updated too regularly. This is going to be perfectly [cromulent](http://en.wiktionary.org/wiki/cromulent) for the app's use case since I won't be displaying the distance values directly. But I will be able to use these values to figure out when HOT or COLD will be yelled at the person.
- Having `[locationManager startRangingBeacons]` in the viewDidAppear is for the prototype only. Need to better figure out a way handling the activation of the search.
- Each CLBeacon has a near/far/immediate proximity value available for use. Even though Apple bragged about the iBeacon's "centimetre accuracy" they seem to be recommending you use these values instead.