---
title: "Multipeer Networking and You"
date: 2014-06-09T20:16:20+00:00
draft: false
tags: ["xcode", "objective-c", "multipeer"]
---

The goal of this prototype is to get two devices communicating via multipeer networking. If Apple's done their job right (Framework development + documentation) it should  be easy, right?

Once you wrap your head around how the whole system is implemented then yes, it actually is fairly easy to get multiple devices communicating.

First off, let's lay our our user story/use case:

>Two devices are connected via multipeer, each one has a button (which is activated when a connection is secured) which will increment the counter on the other device.


[Apple's Multipeer Framework](https://developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MultipeerConnectivityFramework/Introduction/Introduction.html) page is a bit light but it does lay out the general pieces that we need.

- Session objects handle the communications.
- Advertiser objects tells others they're available.
- Browser objects browse for advertised devices.
- Peer ID's allow for unique identification.

One of the interesting things about the multipeer networks is that unlike a traditional client/server network each node could be advertising and discovering at the same time. 

This lead me to one concept that I had to wrap my head around before I could really grok this concept: It's the **browsing** device that invites the *advertiser* to a session.

Initially, I was thinking of the advertiser as more of a server and the browser as a client. Wrong, wrong, wrong. Thinking like that made it even more difficult for me to really understand what was going on under the hood.

Let's describe the workflow:
- You declare a service identifier (just an NSString constant) so your app knows what to advertise/browse.
- The app starts both advertising and browsing for that service at the same time.
- If the app finds a peer, create a session and invite that peer to it.
- If the app receives an invitation to a session, accept it.
- Stop advertising or discovering if either of these things happens, restart is the peer is lost.
- Start sharing that sweet, sweet data.

As a warning, it's what my app's implementing is an exceptionally simplified version of what this framework can do. **It's assuming that there are only two peers that always want to connect to each other.**

- The app should be alerting users when you receive a peering invitation, allow them to decline.
- You probably keep a list of found peers stored so that you can act when the peer is lost.

In true Apple Framework fashion, there's the 'Simple to implement but boring looking' Apple standard and the 'Handle everything yourself with base classes' approach. A lot of the examples out there is using the Apple way, which is to use `MCAdvertiserAssistant` to handle the advertising and `MCBrowserViewController` to browse for available peers.

The issue with each of these is that I was hoping to implement more of a [SpaceTeam-esque](http://ampersandsoftworks.com/matchmaking/) method of matchmaking so I realized that I would have to roll my own.

# [Code - ASWASWLobbyInitViewController.m](https://github.com/brettohland/HotCold/blob/7d8552f796473bbfde8ade4e582f2cda5cdbc77e/HotCold/ASWLobbyInitViewController.m)

Everything is contained inside one view controller.

## Imports + Interface + Implementation stuff

```
@import MultipeerConnectivity;

static NSString * const HotColdServiceType = @"hotcold-service";

@interface ASWLobbyInitViewController () <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate>

@property IBOutlet UILabel *myDeviceName;
@property IBOutlet UILabel *theirDeviceName;
@property IBOutlet UILabel *theirButtonCounter;
@property IBOutlet UIButton *incrementCounterButton;

@property MCSession *session;
@property MCNearbyServiceAdvertiser *advertiser;
@property MCNearbyServiceBrowser *browser;
@property MCPeerID *localPeerID;
@property NSMutableArray *connectedPeers;

@end


@implementation ASWLobbyInitViewController {
    NSNumber *buttonCounter;
}

```

`HotColdServiceType` is simply a string we'll be using later as the service identifier.

We declare ourselves to be able to handle `MCNearbyServiceAdvertiserDelegate`, `MCSessionDelegate` and `MCNearbyServiceBrowserDelegate`delegate messages.

We have our outlets for our our labels and a few private properties to keep instances of our session, advertiser, browser, peerID and an array of connected peers.

One private variable is an NSNumber of the button counter. It's the value we'll be sending across.


## viewDidLoad
```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
    self.myDeviceName.text = @"";
    self.theirDeviceName.text = @"";
    self.theirButtonCounter.text = @"0 times";
    self.incrementCounterButton.enabled = NO;
    buttonCounter = [[NSNumber alloc] initWithInt:0];
    self.connectedPeers = [[NSMutableArray alloc] init];
    
    // Browser for others
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.localPeerID
                                                    serviceType:HotColdServiceType];
    self.browser.delegate = self;
    
    // Advertise to others
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.localPeerID
                                                        discoveryInfo:nil
                                                          serviceType:HotColdServiceType];
    self.advertiser.delegate = self;

}
```

Right now, I'm using the device name as the device's Peer ID. In the future I think I'll be generating something a bit more fun.

After that, we set some default values and initialize the browser and the advertiser.

We're ready to get this show on the road.

## viewWillAppear

```
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.myDeviceName.text = self.localPeerID.displayName;

    [self.browser startBrowsingForPeers];
    [self.advertiser startAdvertisingPeer];
}
```

We set our display name on the label and start both browsing and advertising. From here things get event based.

## MCNearbyServiceAdvertiserDelegates

```
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID
      withContext:(NSData *)context
invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler {
    // Creates a session anytime someone connects using the service.
    NSLog(@"Received Invitation from %@", peerID.displayName);
    
    if (!self.session) {
        self.session = [[MCSession alloc] initWithPeer:self.localPeerID
                                      securityIdentity:nil
                                  encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
        invitationHandler(YES, self.session);
        
        [self.advertiser stopAdvertisingPeer];
        [self.browser stopBrowsingForPeers];
    }
    
}
```

When a browsing peer sends you an invitation, this method will fire.

Locking it down with an `if (!self.session)` means that we won't respond if we've already connected to a session. Since we're purposefully locking this down to 2 peers, we're good.

When we initialize session property we pass it **our local peer id** this caused me a great deal of confusion. I assumed that you create your session with the peerID value being passed in by your peer.

[The docs are actually pretty clear about this:](https://developer.apple.com/library/ios/documentation/MultipeerConnectivity/Reference/MCSessionClassRef/Reference/Reference.html#//apple_ref/occ/cl/MCSession)

>Create an MCPeerID object that represents the local peer, and use it to initialize the session object.

After setting the delegate for the session to self, we then have to call the handler block with a true boolean and the session object as parameters and then stop both advertising and browsing.

## MCNearbyServiceBrowserDelegates

```

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    NSLog(@"FOUND PEER %@", peerID.displayName);
    
    if (!self.session){
        self.session = [[MCSession alloc] initWithPeer:self.localPeerID
                                      securityIdentity:nil
                                  encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
        
        [browser invitePeer:peerID toSession:self.session withContext:nil timeout:5];
        
        [self.advertiser stopAdvertisingPeer];
        [self.browser stopBrowsingForPeers];
    }
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    NSLog(@"LOST PEER %@", peerID);
    
    // Kill the session
    self.session = nil;

    // Start looking again.
    [self.advertiser startAdvertisingPeer];
    [self.browser startBrowsingForPeers];
}
```

On the browsing side, we're simply looking for any advertised services, inviting them to a session (Notice that on this end we're also initializing it with our local session ID) setting our delegate, and stopping both advertising and browsing once one is found.

Now, if we lose the peer after finding it, we're simply restarting the advertising and browsing services.

```
# pragma mark - MCSessionDelegate

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Message received: %@", message);
    dispatch_async(dispatch_get_main_queue(),^ {
        self.theirButtonCounter.text = message;
    });
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream
      withName:(NSString *)streamName
      fromPeer:(MCPeerID *)peerID {
    
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName
      fromPeer:(MCPeerID *)peerID
  withProgress:(NSProgress *)progress {
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName
      fromPeer:(MCPeerID *)peerID
         atURL:(NSURL *)localURL
     withError:(NSError *)error {
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSArray *stateStringRepresentation = @[@"MCSessionStateNotConnected", @"MCSessionStateConnecting", @"MCSessionStateConnected" ];

    NSLog(@"SESSION STATE CHANGE: %@", stateStringRepresentation[state] );
    
    if (state == MCSessionStateConnected) {
        NSLog(@"Connected to %@", peerID.displayName);

        [self.connectedPeers addObject:peerID];

        dispatch_async(dispatch_get_main_queue(),^ {
            self.theirDeviceName.text = peerID.displayName;
            self.incrementCounterButton.enabled = YES;
        });
        
        [self.view setNeedsDisplay];
    }
}
```

The two important delegate events are didReceiveData and didChangeState.

didReceiveData is simply called when some data is returned from your peer, It's sent as NSData, so you have to change it back to a NSString.

You also see that I'm setting the text on the label in the main thread using the main queue. If you want the UI to be updated immediately you need to make sure that you call those on the main thread.

Once a session has been created, you need to watch for MCSessionStateConnected to be returned in the didChangeState method. This means that you're good to go to begin sending information across.

I'm enabling the button and setting the peer label on the main queue once we're connected.


## 'Press This' Button Action
```
- (IBAction)incrementCounterAndSend:(UIButton *)sender {
    buttonCounter = @([buttonCounter intValue] + 1);
    NSString *message = [NSString stringWithFormat:@"%d times", [buttonCounter integerValue]];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    if (![self.session sendData:data
                        toPeers:self.connectedPeers
                       withMode:MCSessionSendDataReliable
                          error:&error]) {
        NSLog(@"[Error] %@", error);
    }
}
```

Pretty simple stuff. Just incrementing the button integer by one, creating a 'X times' string and sending that across the wire.

That's it! You end up with a 2 peer system as soon as you arrive on the view controller. I haven't tested it with more than 2 though.

Now I think I'll rewrite this in Swift.