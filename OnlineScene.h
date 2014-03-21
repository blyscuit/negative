//
//  MyScene.h
//  negative
//

//  Copyright (c) 仏暦2556年 betaescape. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>

@interface OnlineScene : SKScene <SKPhysicsContactDelegate, GKMatchDelegate,GKMatchmakerViewControllerDelegate>{
    uint32_t ourRandom;
    BOOL receivedRandom;
    NSString *otherPlayerID;
}

@property BOOL multiMode;
@property CGPoint touchLocation;
@property NSInteger maxLives;
@property BOOL guardBreak;
@property BOOL bgMusic;
@property NSInteger tutorial;
@property NSInteger level;
@property NSMutableArray *saveArray;
@property NSInteger score;

@property GKMatch* myMatch;
@property BOOL matchStarted;
@property BOOL invite;


@property (retain) NSMutableDictionary *playersDict;

@end
