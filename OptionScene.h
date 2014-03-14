//
//  OptionScene.h
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2557/01/24.
//  Copyright (c) 仏暦2557年 betaescape. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GCHelper.h"

@interface OptionScene : SKScene <GCHelperDelegate,GKGameCenterControllerDelegate>


@property NSInteger maxLives;
@property BOOL shield;
@property NSMutableArray *saveArray;

@end
