//
//  StartScene.h
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2556/12/04.
//  Copyright (c) 仏暦2556年 betaescape. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface StartScene : SKScene

@property NSInteger maxLife;
@property BOOL breakAble;
@property NSMutableArray *saveArray;
@property NSInteger level;

@end


/*from .plist

0=live
1=shield
2=classic
3=level
*/