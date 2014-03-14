//
//  CGHelper.h
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2557/03/13.
//  Copyright (c) 仏暦2557年 betaescape. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "StartScene.h"

@protocol GCHelperDelegate
- (void)matchStartedHelper;
- (void)matchEndedHelper;
- (void)matchHelper:(GKMatch *)match didReceiveData:(NSData *)data
   fromPlayer:(NSString *)playerID;
@end

@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate> {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    
    UIViewController *presentingViewControllerHelper;
    GKMatch *matchHelper;
    BOOL matchStartedHelper;
    //id <GCHelperDelegate> delegate;
}

@property (assign, readonly) BOOL gameCenterAvailable;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;

@property (retain) UIViewController *presentingViewControllerHelper;
@property (retain) GKMatch *matchHelper;
@property (assign) id <GCHelperDelegate> delegate;

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GCHelperDelegate>)theDelegate;

@end