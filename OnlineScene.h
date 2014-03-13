//
//  MyScene.h
//  negative
//

//  Copyright (c) 仏暦2556年 betaescape. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GCHelper.h"

@interface OnlineScene : SKScene <SKPhysicsContactDelegate, GCHelperDelegate>

@property BOOL multiMode;
@property CGPoint touchLocation;
@property NSInteger maxLives;
@property BOOL guardBreak;
@property BOOL bgMusic;
@property NSInteger tutorial;
@property NSInteger level;
@property NSMutableArray *saveArray;

@end
