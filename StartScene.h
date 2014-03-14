//
//  StartScene.h
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2556/12/04.
//  Copyright (c) 仏暦2556年 betaescape. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>


@interface StartScene : SKScene <GKMatchDelegate, GKMatchmakerViewControllerDelegate,GKGameCenterControllerDelegate>

@property NSInteger maxLife;
@property BOOL breakAble;
@property NSMutableArray *saveArray;
@property NSInteger level;
@property GKMatch* myMatch;
@property BOOL matchStarted;
@property BOOL multiScreen;

@end


/*from .plist

0=live
1=shield
2=classic
3=level
*/