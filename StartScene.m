//
//  StartScene.m
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2556/12/04.
//  Copyright (c) 仏暦2556年 betaescape. All rights reserved.
//

#import "StartScene.h"
#import "MyScene.h"

@implementation StartScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithWhite:0.92 alpha:1.0];
        
        
        SKSpriteNode *beginButton = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.5 alpha:0.7] size:CGSizeMake(80, 30)];//insert picture here?
        
        /*SKLabelNode *startText = [SKLabelNode labelNodeWithFontNamed:@"Helvatica"];
        startText.fontSize=15;
        startText.fontColor = [SKColor whiteColor];
        startText.text = @"Begin";
        startText.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        startText.zPosition = 1.1f;
        [self addChild:startText];*/

        beginButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        beginButton.name = @"beginButton";
        beginButton.zPosition = 1.0f;
        [self addChild:beginButton];
        
        SKSpriteNode *multiButton = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.7] size:CGSizeMake(80, 30)];//insert picture here?
        multiButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-50);
        multiButton.name = @"multiButton";
        multiButton.zPosition = 1.0f;
        [self addChild:multiButton];
        
        SKSpriteNode *redBrick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0] size:CGSizeMake(20, 20)];
        redBrick.position=CGPointMake(40,40);
        redBrick.name = @"redBrick";
        [self addChild:redBrick];
        
        SKSpriteNode *blueBrick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:1.0] size:CGSizeMake(20, 20)];
        blueBrick.position=CGPointMake(60,40);
        blueBrick.name = @"blueBrick";
        [self addChild:blueBrick];
        
        SKSpriteNode *greenBrick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:1.0] size:CGSizeMake(20, 20)];
        greenBrick.position=CGPointMake(80,40);
        greenBrick.name = @"greenBrick";
        [self addChild:greenBrick];
        
        SKSpriteNode *whiteBrick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] size:CGSizeMake(20, 20)];
        whiteBrick.position=CGPointMake(100,40);
        whiteBrick.name = @"whiteBrick";
        [self addChild:whiteBrick];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    
    if ([node.name isEqualToString:@"beginButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        
        [self nodesDisappear];
        MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        gameScene.multiMode = NO;
        gameScene.touchLocation = location;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65]];
        
    }else if ([node.name isEqualToString:@"multiButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood3.m4a" waitForCompletion:NO]];
        
        [self nodesDisappear];
        MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        gameScene.multiMode = YES;
        gameScene.touchLocation = location;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
        
    }
}

-(void)nodesDisappear{
    SKAction *scale = [SKAction scaleTo:0.1 duration:0.3];
    SKAction *color = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.8 duration:0.3];
    SKNode *player = [self childNodeWithName:@"beginButton"];
    SKNode *enemy  = [self childNodeWithName:@"multiButton"];
    [scale setTimingMode:SKActionTimingEaseInEaseOut];
    [color setTimingMode:SKActionTimingEaseInEaseOut];
    [player runAction:color];
    [enemy runAction:color];
    [player runAction:scale];
    [enemy runAction:scale];
}

-(void)brickDance:(NSInteger)brickNumber withTime:(CFTimeInterval*)currentTime{
    SKAction * dance = [SKAction sequence:@[[SKAction moveToY:50 duration:0.15],[SKAction moveToY:40 duration:0.15]]];
    NSString *brickName;
    switch (brickNumber) {
        case 0:
            brickName = @"redBrick";
            if((arc4random()%3)!=1){
                [self runAction:[SKAction playSoundFileNamed:@"D5.caf" waitForCompletion:YES]];
            }else{
                [self runAction:[SKAction playSoundFileNamed:@"C5.caf" waitForCompletion:YES]];
            }
            break;
        case 1:
            brickName = @"blueBrick";
            if((arc4random()%3)!=1){
                [self runAction:[SKAction playSoundFileNamed:@"F5.caf" waitForCompletion:YES]];
            }else{
                [self runAction:[SKAction playSoundFileNamed:@"E5.caf" waitForCompletion:YES]];
            }
            break;
        case 2:
            brickName = @"greenBrick";
            if((arc4random()%3)!=1){
                [self runAction:[SKAction playSoundFileNamed:@"A5.caf" waitForCompletion:YES]];
            }else{
                [self runAction:[SKAction playSoundFileNamed:@"G5.caf" waitForCompletion:YES]];
            }
            break;
        case 3:
            brickName = @"whiteBrick";
            if((arc4random()%3)!=1){
                [self runAction:[SKAction playSoundFileNamed:@"B5.caf" waitForCompletion:YES]];
            }else{
                [self runAction:[SKAction playSoundFileNamed:@"C6.caf" waitForCompletion:YES]];
            }
            break;
            
        default:
            break;
    }
    SKNode *brick = [self childNodeWithName:brickName];
    [brick runAction:dance];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self brickDance:((arc4random()% 400)) withTime:&currentTime];
}

@end
