//
//  MyScene.m
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2556/12/03.
//  Copyright (c) 仏暦2556年 betaescape. All rights reserved.
//

#import "MyScene.h"
//#import <CoreMotion/CoreMotion.h>
#import "GameOverScene.h"


#pragma mark - Custom Type Definitions

#define kContainerSize CGSizeMake (60,60)
#define kContainerSpace 20
#define kContainsCount 5
#define kFontMissionGothicName @"MissionGothic-Light"

typedef enum MoveType{
    PlayerMoveUp,
    PlayerMoveDown,
    PlayerFire,
    PlayerCharge,
    PlayerGuard,
    none,
}Player1MoveType;

typedef enum EnermyMoveType{
    EMoveUp,
    EMoveDown,
    EFire,
    ECharge,
    EGuard,
    ENone,
}EnermyMoveType;


#pragma mark - Private GameScene Properties

@interface MyScene()

@property BOOL contentCreated;
@property NSInteger playerPosition;
@property NSInteger enemyPosition;
@property NSTimeInterval timeOfLastMove;
@property NSTimeInterval timePerMove;
@property Player1MoveType player1MoveType;
@property EnermyMoveType eMoveType;

@property Player1MoveType playerUsingType;
@property EnermyMoveType eUsingType;

@property BOOL gameBegin;

@property NSString *myParticlePath;
@property SKEmitterNode *magicParticle;
@property SKEmitterNode *followParticle;

//Player1Property
@property NSInteger playerCharge;
@property BOOL playerGuardable;
@property CGPoint playerTouchLocation;
@property NSString *playerWords;
@property NSInteger playerLive;

@property BOOL eGuardable;
@property NSInteger eCharge;
@property CGPoint enemyTouchLocation;
@property NSString *eWords;
@property NSInteger eLive;

@end

@implementation MyScene

@synthesize multiMode,touchLocation,maxLives,guardBreak;

-(void)didMoveToView:(SKView *)view{
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    }
}

-(void)resetStat{
    
}

-(void)createContent{
    if (maxLives<=0) {
        maxLives=2;
    }
    
    [self setupContainers];
    
    self.timeOfLastMove =0.0;
    self.timePerMove=3.0;
    
    [self setupPlayer];
    self.playerPosition = 1;
    self.playerCharge = 0;
    self.playerGuardable = YES;
    self.playerLive=2;
    self.playerLive=maxLives;
    
    [self setupPlayerButton];
    
    [self setupEnemy];
    self.enemyPosition = 5;
    self.eCharge = 0;
    self.eGuardable=YES;
    self.eLive=2;
    self.eLive=maxLives;
    if(multiMode)[self setupEnemyButton];
    
    self.player1MoveType = none;
    self.eMoveType = none;
    
    self.gameBegin = NO;
    
    
    [self createBetaTester];
}


-(void)setupPlayer{
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(55, 55)];
    [player setScale:0.3];
    [player setAlpha:0.01];
    player.position=touchLocation;
    SKAction *moveToStart = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame))+((60.0+kContainerSpace)*(-2))) duration:0.45];
    SKAction *scale = [SKAction scaleTo:1.0 duration:0.2];
    SKAction *alpha = [SKAction fadeAlphaTo:1.0 duration:0.6];
    [alpha setTimingMode:SKActionTimingEaseIn];
    [moveToStart setTimingMode:SKActionTimingEaseIn];
    [scale setTimingMode:SKActionTimingEaseIn];
    player.name = @"player";
    [player runAction:[SKAction sequence:@[moveToStart,scale]]];
    [player runAction:alpha];
    [self addChild:player];
    
    SKLabelNode* playerSpeech = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    
    playerSpeech.name = @"playerSpeech";
    playerSpeech.fontSize = 15;
    
    self.playerWords = [NSString stringWithFormat:@"test"];
    playerSpeech.fontColor = [SKColor grayColor];
    playerSpeech.text = [NSString stringWithFormat:@"%@",self.playerWords];
    
    playerSpeech.position = CGPointMake(player.frame.size.width*4,-playerSpeech.frame.size.height/2);
    [player addChild:playerSpeech];

}

-(void)setupPlayerButton{
    /*
    SKLabelNode* playerFireLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    
    playerFireLabel.name = @"1Fire";
    playerFireLabel.fontSize = 15;
    
    playerFireLabel.fontColor = [SKColor blueColor];
    playerFireLabel.text = [NSString stringWithFormat:@"Fire"];
    
    playerFireLabel.position = CGPointMake(0+playerFireLabel.frame.size.width,40);
    [self addChild:playerFireLabel];
    
    SKLabelNode* playerUpLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    playerUpLabel.name=@"1Up";
    playerUpLabel.fontSize=15;
    playerUpLabel.fontColor = [SKColor blueColor];
    playerUpLabel.text = [NSString stringWithFormat:@"Up"];
    
    playerUpLabel.position = CGPointMake(self.frame.size.width/4,40);
    [self addChild:playerUpLabel];
    
    SKLabelNode* playerDownLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    playerDownLabel.name=@"1Down";
    playerDownLabel.fontSize=15;
    playerDownLabel.fontColor = [SKColor blueColor];
    playerDownLabel.text = [NSString stringWithFormat:@"Down"];
    
    playerDownLabel.position = CGPointMake(self.frame.size.width/4*2-playerDownLabel.frame.size.width,40);
    [self addChild:playerDownLabel];
    
    SKLabelNode* playerChargeLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    playerChargeLabel.name=@"1Charge";
    playerChargeLabel.fontSize=15;
    playerChargeLabel.fontColor = [SKColor blueColor];
    playerChargeLabel.text = [NSString stringWithFormat:@"Charge"];
    
    playerChargeLabel.position = CGPointMake(self.frame.size.width/4*3-playerChargeLabel.frame.size.width,40);
    [self addChild:playerChargeLabel];
    
    SKLabelNode* playerGuardLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    playerGuardLabel.name=@"1Guard";
    playerGuardLabel.fontSize=15;
    playerGuardLabel.fontColor = [SKColor blueColor];
    playerGuardLabel.text = [NSString stringWithFormat:@"Guard"];
    
    playerGuardLabel.position = CGPointMake(self.frame.size.width-playerGuardLabel.frame.size.width,40);
    [self addChild:playerGuardLabel];
    */
    SKSpriteNode *playerControl = [SKSpriteNode spriteNodeWithImageNamed:@"battle.png" ];
    playerControl.size=CGSizeMake(self.frame.size.width, 50);
    playerControl.color =[UIColor blueColor];
    playerControl.alpha=.5;
    playerControl.position=CGPointMake(CGRectGetMidX(self.frame), -playerControl.size.height);
    playerControl.name = @"playerControl";
    [self addChild:playerControl];
}

-(void)setupEnemy{
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(55, 55)];
    [enemy setScale:0.3];
    [enemy setAlpha:0.01];
    enemy.position=touchLocation;
    SKAction *moveToStart = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame))+((60.0+kContainerSpace)*(2))) duration:0.45];
    SKAction *scale = [SKAction scaleTo:1.0 duration:0.2];
    SKAction *alpha = [SKAction fadeAlphaTo:1.0 duration:0.6];
    [alpha setTimingMode:SKActionTimingEaseIn];
    [moveToStart setTimingMode:SKActionTimingEaseIn];
    [scale setTimingMode:SKActionTimingEaseIn];
    [enemy runAction:[SKAction sequence:@[moveToStart,scale]]];
    [enemy runAction:alpha];
    enemy.name = @"enemy";
    
    [self addChild:enemy];
    
    SKLabelNode* playerSpeech = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    
    playerSpeech.name = @"eSpeech";
    playerSpeech.fontSize = 15;
    
    self.eWords = [NSString stringWithFormat:@"test"];
    playerSpeech.fontColor = [SKColor grayColor];
    playerSpeech.text = [NSString stringWithFormat:@"%@",self.eWords];
    [playerSpeech setScale:-1];
    playerSpeech.position = CGPointMake(-enemy.frame.size.width*4,+playerSpeech.frame.size.height/2);
    [enemy addChild:playerSpeech];
}

-(void)setupEnemyButton{
    /*
    SKLabelNode* playerFireLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    
    playerFireLabel.name = @"2Fire";
    playerFireLabel.fontSize = 15;
    
    playerFireLabel.fontColor = [SKColor blueColor];
    playerFireLabel.text = [NSString stringWithFormat:@"Fire"];
    
    playerFireLabel.position = CGPointMake(0+playerFireLabel.frame.size.width,self.frame.size.height-40);
    [self addChild:playerFireLabel];
    
    SKLabelNode* playerUpLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    playerUpLabel.name=@"2Up";
    playerUpLabel.fontSize=15;
    playerUpLabel.fontColor = [SKColor blueColor];
    playerUpLabel.text = [NSString stringWithFormat:@"Up"];
    
    playerUpLabel.position = CGPointMake(self.frame.size.width/4,self.frame.size.height-40);
    [self addChild:playerUpLabel];
    
    SKLabelNode* playerDownLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    playerDownLabel.name=@"2Down";
    playerDownLabel.fontSize=15;
    playerDownLabel.fontColor = [SKColor blueColor];
    playerDownLabel.text = [NSString stringWithFormat:@"Down"];
    
    playerDownLabel.position = CGPointMake(self.frame.size.width/4*2-playerDownLabel.frame.size.width,self.frame.size.height-40);
    [self addChild:playerDownLabel];
    
    SKLabelNode* playerChargeLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    playerChargeLabel.name=@"2Charge";
    playerChargeLabel.fontSize=15;
    playerChargeLabel.fontColor = [SKColor blueColor];
    playerChargeLabel.text = [NSString stringWithFormat:@"Charge"];
    
    playerChargeLabel.position = CGPointMake(self.frame.size.width/4*3-playerChargeLabel.frame.size.width,self.frame.size.height-40);
    [self addChild:playerChargeLabel];
    
    SKLabelNode* playerGuardLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    playerGuardLabel.name=@"2Guard";
    playerGuardLabel.fontSize=15;
    playerGuardLabel.fontColor = [SKColor blueColor];
    playerGuardLabel.text = [NSString stringWithFormat:@"Guard"];
    
    playerGuardLabel.position = CGPointMake(self.frame.size.width-playerGuardLabel.frame.size.width,self.frame.size.height-40);
    [self addChild:playerGuardLabel];
    */
    SKSpriteNode *enemyControl = [SKSpriteNode spriteNodeWithImageNamed:@"battle.png"];
    enemyControl.size=CGSizeMake(self.frame.size.width, 50);
    enemyControl.color = [UIColor redColor];
    enemyControl.xScale = -1;
    enemyControl.yScale = -1;
    enemyControl.alpha=.5;
    enemyControl.position=CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height+enemyControl.size.height);
    enemyControl.name = @"enemyControl";
    [self addChild:enemyControl];
}

-(void)setupContainers{
    for (NSUInteger count=0; count<kContainsCount; count++) {
        SKSpriteNode *container = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:kContainerSize];
        
        [container setScale:0.1];
        [container setAlpha:0.0];
        
        NSInteger temp = count-2;
        NSTimeInterval randomTime =((arc4random()% 2)/1.5+0.5)+(0.15*temp);
        SKAction *appear = [SKAction fadeAlphaTo:0.5 duration:randomTime];
        SKAction *pop = [SKAction scaleTo:0.2 duration:randomTime];
        [appear setTimingMode:SKActionTimingEaseIn];
        [pop setTimingMode:SKActionTimingEaseInEaseOut];
                                                                                    
        [container runAction:appear];
        [container runAction:pop];
        container.position = CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame))+((60.0+kContainerSpace)*(temp)));
        
        [self addChild:container];
    }
}



-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithWhite:0.92 alpha:1.0];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
     */
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    /*SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"1Fire"]) {
        self.player1MoveType = PlayerFire;
    }else if([node.name isEqualToString:@"1Up"]){
        self.player1MoveType=PlayerMoveUp;
    }else if([node.name isEqualToString:@"1Down"]){
        self.player1MoveType=PlayerMoveDown;
    }else if([node.name isEqualToString:@"1Charge"]){
        self.player1MoveType=PlayerCharge;
    }else if([node.name isEqualToString:@"1Guard"]){
        self.player1MoveType=PlayerGuard;
    }
    
    if ([node.name isEqualToString:@"2Fire"]) {
        self.eMoveType = EFire;
    }else if([node.name isEqualToString:@"2Up"]){
        self.eMoveType=EMoveUp;
    }else if([node.name isEqualToString:@"2Down"]){
        self.eMoveType=EMoveDown;
    }else if([node.name isEqualToString:@"2Charge"]){
        self.eMoveType=ECharge;
    }else if([node.name isEqualToString:@"2Guard"]){
        self.eMoveType=EGuard;
    }*/
    
    if (multiMode) {
        if (location.y<=self.frame.size.height/2) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            SKAction *moveIn = [SKAction moveToY:control.frame.size.height/2 duration:0.2];
            SKAction *fade = [SKAction fadeAlphaTo:.5 duration:0.1];
            [control runAction:fade];
            [control runAction:moveIn];
            self.playerTouchLocation = location;
            if (location.x<self.frame.size.width*1/5) {
                if (self.player1MoveType!=PlayerMoveDown) {
                    self.player1MoveType = PlayerMoveDown;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Down.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/5){
                if (self.player1MoveType != PlayerMoveUp) {
                    self.player1MoveType = PlayerMoveUp;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Up.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/5){
                if (self.player1MoveType != PlayerCharge){
                    self.player1MoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Plus.png"]]];
                }
            }else if(location.x<self.frame.size.width*4/5){
                if (self.player1MoveType != PlayerFire){
                    self.player1MoveType = PlayerFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Neg.png"]]];
                }
            }else if(location.x<self.frame.size.width*5/5){
                if (self.player1MoveType != PlayerGuard){
                    self.player1MoveType = PlayerGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Neu.png"]]];
                }
            }
        }
        if (location.y>self.frame.size.height/2) {
            SKNode *control = [self childNodeWithName:@"enemyControl"];
            SKAction *moveIn = [SKAction moveToY:self.frame.size.height-control.frame.size.height/2 duration:0.2];
            SKAction *fade = [SKAction fadeAlphaTo:.5 duration:0.1];
            [control runAction:fade];
            [control runAction:moveIn];
            self.playerTouchLocation = location;
            if (location.x<self.frame.size.width*1/5) {
                if (self.eMoveType != EGuard){
                    self.eMoveType = EGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Neu.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/5){
                if (self.eMoveType != EFire){
                    self.eMoveType = EFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Neg.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/5){
                if (self.eMoveType != PlayerCharge){
                    self.eMoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Plus.png"]]];
                }
            }else if(location.x<self.frame.size.width*4/5){
                if (self.eMoveType != EMoveDown){
                    self.eMoveType = EMoveDown;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Up.png"]]];
                }
            }else if(location.x<self.frame.size.width*5/5){
                if (self.eMoveType != EMoveUp){
                    self.eMoveType = EMoveUp;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Down.png"]]];
                }
            }

        }

    }else{
        if (location.y<=self.frame.size.height) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            SKAction *moveIn = [SKAction moveToY:control.frame.size.height/2 duration:0.2];
            [control runAction:moveIn];
            self.playerTouchLocation = location;
            if (location.x<self.frame.size.width*1/5) {
                if (self.player1MoveType!=PlayerMoveDown) {
                    self.player1MoveType = PlayerMoveDown;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Down.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/5){
                if (self.player1MoveType != PlayerMoveUp) {
                    self.player1MoveType = PlayerMoveUp;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Up.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/5){
                if (self.player1MoveType != PlayerCharge){
                    self.player1MoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Plus.png"]]];
                }
            }else if(location.x<self.frame.size.width*4/5){
                if (self.player1MoveType != PlayerFire){
                    self.player1MoveType = PlayerFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Neg.png"]]];
                }
            }else if(location.x<self.frame.size.width*5/5){
                if (self.player1MoveType != PlayerGuard){
                    self.player1MoveType = PlayerGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Neu.png"]]];
                }
            }
        }
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    if (multiMode) {
        if (location.y<=self.frame.size.height/2) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            SKAction *moveIn = [SKAction moveToY:-control.frame.size.height/2 duration:0.1];
            SKAction *fade = [SKAction fadeAlphaTo:.0 duration:0.1];
            [control runAction:fade];
            [control runAction:moveIn];
            self.playerTouchLocation = location;
        }
        if (location.y>self.frame.size.height/2) {
            SKNode *control = [self childNodeWithName:@"enemyControl"];
            SKAction *moveIn = [SKAction moveToY:self.frame.size.height+control.frame.size.height/2 duration:0.1];
            SKAction *fade = [SKAction fadeAlphaTo:.0 duration:0.1];
            [control runAction:fade];
            [control runAction:moveIn];
            self.enemyTouchLocation = location;
        }
        
    }else{
        if (location.y<=self.frame.size.height) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            SKAction *moveIn = [SKAction moveToY:-control.frame.size.height/2 duration:0.1];
            [control runAction:moveIn];
            self.playerTouchLocation = location;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if (multiMode) {
        if (location.y<=self.frame.size.height/2) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            if (location.x<self.frame.size.width*1/5) {
                if (self.player1MoveType!=PlayerMoveDown) {
                    self.player1MoveType = PlayerMoveDown;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Down.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/5){
                if (self.player1MoveType != PlayerMoveUp) {
                    self.player1MoveType = PlayerMoveUp;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Up.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/5){
                if (self.player1MoveType != PlayerCharge){
                    self.player1MoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Plus.png"]]];
                }
            }else if(location.x<self.frame.size.width*4/5){
                if (self.player1MoveType != PlayerFire){
                    self.player1MoveType = PlayerFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Neg.png"]]];
                }
            }else if(location.x<self.frame.size.width*5/5){
                if (self.player1MoveType != PlayerGuard){
                    self.player1MoveType = PlayerGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Neu.png"]]];
                }
            }
        }
        if (location.y>self.frame.size.height/2) {
            SKNode *control = [self childNodeWithName:@"enemyControl"];
            if (location.x<self.frame.size.width*1/5) {
                if (self.eMoveType != EGuard){
                    self.eMoveType = EGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Neu.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/5){
                if (self.eMoveType != EFire){
                    self.eMoveType = EFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Neg.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/5){
                if (self.eMoveType != PlayerCharge){
                    self.eMoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Plus.png"]]];
                }
            }else if(location.x<self.frame.size.width*4/5){
                if (self.eMoveType != EMoveDown){
                    self.eMoveType = EMoveDown;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Up.png"]]];
                }
            }else if(location.x<self.frame.size.width*5/5){
                if (self.eMoveType != EMoveUp){
                    self.eMoveType = EMoveUp;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2Down.png"]]];
                }
            }
        }
        
    }else{
        if (location.y<=self.frame.size.height) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            if (location.x<self.frame.size.width*1/5) {
                if (self.player1MoveType!=PlayerMoveDown) {
                    self.player1MoveType = PlayerMoveDown;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Down.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/5){
                if (self.player1MoveType != PlayerMoveUp) {
                    self.player1MoveType = PlayerMoveUp;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Up.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/5){
                if (self.player1MoveType != PlayerCharge){
                    self.player1MoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Plus.png"]]];
                }
            }else if(location.x<self.frame.size.width*4/5){
                if (self.player1MoveType != PlayerFire){
                    self.player1MoveType = PlayerFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Neg.png"]]];
                }
            }else if(location.x<self.frame.size.width*5/5){
                if (self.player1MoveType != PlayerGuard){
                    self.player1MoveType = PlayerGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Neu.png"]]];
                }
            }
        }
    }

}

#pragma mark - Input

-(void)decreaseLifeOn:(SKNode*)Enemy{
    SKAction *hit = [SKAction sequence:@[[SKAction scaleBy:0.49 duration:0.05],
                                         [SKAction scaleTo:1. duration:0.05],
                                         [SKAction scaleBy:0.49 duration:0.07],
                                         [SKAction scaleTo:1. duration:0.07],
                                         [SKAction scaleBy:0.49 duration:0.1],
                                         [SKAction scaleTo:1. duration:0.1],
                                         [SKAction scaleBy:0.49 duration:0.15]]];
    
    self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"self" ofType:@"sks"];
    self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
    self.magicParticle.particlePosition = Enemy.position;
    self.magicParticle.zPosition =0.1;
    [self.magicParticle runAction:[SKAction sequence:@[[SKAction waitForDuration:.6],[SKAction removeFromParent]]]];
    //self.magicParticle.particleAction = shoot;
    
    [self addChild:self.magicParticle];
    
    [Enemy runAction:hit completion:^{
        
        SKSpriteNode *newE;
        
        if ([Enemy.name isEqualToString:@"player"]) {
            newE= [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(23, 23)];
            self.playerLive--;
            if (self.playerLive<=0) {
                [self endGame];
                return;
            }
        }else if ([Enemy.name isEqualToString:@"enemy"]){
            newE= [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(23, 23)];
            self.eLive--;
            if (self.eLive<=0) {
                [self endGame];
                return;
            }
        }
        newE.position=Enemy.position;
        newE.name = Enemy.name;
        
        
        [Enemy removeFromParent];
        [self addChild:newE];
    }];
    
}

-(void)readPlayerFire{
    switch (self.playerUsingType) {
        case PlayerFire:
        {
            if(self.playerCharge<=0)return;
            
            
            [self runAction:[SKAction playSoundFileNamed:@"repel.m4a" waitForCompletion:NO]];
            
            
            SKNode *player = [self childNodeWithName:@"player"];
            SKNode *enemy = [self childNodeWithName:@"enemy"];
            
            SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(0,0)];
            projectile.alpha = 1.0;
            projectile.position=CGPointMake(0,0);
            projectile.name = @"proj";
            projectile.zPosition =0;
            
            int maxFire = self.playerCharge;
            
            SKAction *magicFade = [SKAction sequence:@[
                                                       [SKAction waitForDuration:1.2],
                                                       [SKAction removeFromParent]]];
            [magicFade setTimingMode:SKActionTimingEaseIn];
            [projectile runAction:magicFade completion:^{
                if (self.enemyPosition<=(self.playerPosition + self.playerCharge)&&self.eUsingType!=EGuard) {
                    if (self.eUsingType==EFire&&self.enemyPosition<=(self.playerPosition + self.eCharge)) {
                        self.playerUsingType=PlayerGuard;
                    }else{
                        [self decreaseLifeOn:enemy];
                    }
                }
                self.playerCharge =0;
            }];
            
            [player addChild:projectile];
            
            
            SKAction *moveSound;
            
            switch (maxFire) {
                case 1:
                    moveSound=[SKAction playSoundFileNamed:@"moveC.m4a" waitForCompletion:NO];
                    break;
                case 2:
                    moveSound=[SKAction playSoundFileNamed:@"moveD.m4a" waitForCompletion:NO];
                    break;
                case 3:
                    moveSound=[SKAction playSoundFileNamed:@"moveE.m4a" waitForCompletion:NO];
                    break;
                default:
                    break;
            }
            
            for (int i=0; i<maxFire; i++) {
                NSInteger x =(arc4random()% 100)+50;
                NSInteger y =((arc4random()% 100)-50);
                
                SKSpriteNode *projectile2 = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(0,0)];
                projectile2.alpha = 1.0;
                projectile2.position=CGPointMake(0,0);
                projectile2.name = @"proj2";
                projectile2.zPosition =0;
                
                CGFloat angle = tanf(   (x-(pow(-1, i+1)*x)/4)   /   ((80+(80*i)+15)-y)   );
                
                SKAction* shoot = [SKAction sequence:@[[SKAction moveTo:CGPointMake((pow(-1, i)*x),y) duration:0.2],
                                                 [SKAction waitForDuration:(i*0.2)],[SKAction rotateByAngle:(pow(-1, i)*angle) duration:0.15],moveSound,
                                                 [SKAction moveTo:CGPointMake((pow(-1, i+1)*x)/4, 80+(80*i)+15) duration:0.2+(i*0.07)],[SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1.0 duration:0.0],[SKAction fadeAlphaTo:0. duration:.2],
                                                 [SKAction removeFromParent]]];
                [shoot setTimingMode:SKActionTimingEaseIn];
                
                [projectile2 runAction:shoot];
                [projectile addChild:projectile2];
                
                self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"projectile" ofType:@"sks"];
                self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                self.magicParticle.particlePosition = CGPointMake(0,0);
                self.magicParticle.zPosition =2;
                //self.magicParticle.particleAction = shoot;
                
                [projectile2 addChild:self.magicParticle];
                
                self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"triangles" ofType:@"sks"];
                self.followParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                
                self.followParticle.particlePosition = CGPointMake(0,-10);
                self.followParticle.particleAction = shoot;
                self.followParticle.targetNode = player;
                
                [projectile2 addChild:self.followParticle];
                
                self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"Tail" ofType:@"sks"];
                self.followParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                
                self.followParticle.particlePosition = CGPointMake(0,10);
                self.followParticle.particleAction = shoot;
                self.followParticle.targetNode = player;
                self.followParticle.zPosition=1.8;
                
                [projectile2 addChild:self.followParticle];
                
                
            }
            
            
            /*
            SKSpriteNode *projectile2 = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(0,0)];
            projectile2.alpha = 1.0;
            projectile2.position=CGPointMake(0,-player.frame.size.height/2);
            projectile2.name = @"proj2";
            projectile2.zPosition =0;
            
            SKAction *magicFade2 = [SKAction sequence:@[[SKAction moveTo:CGPointMake(-x,y) duration:0.3],
                                                        [SKAction waitForDuration:0.1],
                                                        [SKAction moveTo:CGPointMake(enemy.position.x-player.position.x, enemy.position.y-player.position.y) duration:0.6],
                                                        [SKAction waitForDuration:0.1],
                                                        [SKAction removeFromParent]]];
            [magicFade2 setTimingMode:SKActionTimingEaseIn];
            [projectile2 runAction:magicFade2];
            
            [player addChild:projectile2];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"projectile" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.particlePosition = CGPointMake(0,0);
            self.magicParticle.zPosition =2;
            flip = [SKAction scaleYTo:1 duration:0];
            //[magicFade setTimingMode:SKActionTimingEaseInEaseOut];
            [self.magicParticle runAction:flip];
            
            [projectile2 addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"triangles" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            
            self.magicParticle.particlePosition = CGPointMake(0,10);
            self.magicParticle.particleAction = magicFade;
            self.magicParticle.targetNode = player;
            
            [projectile2 addChild:self.magicParticle];
            */
            
            break;

        }
            default:
            break;
    }
}


-(void)moveToSameSpot{
    self.playerUsingType=none;
    self.eUsingType=none;
    //Animation here
    SKAction *scale = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.11],
                                        [SKAction scaleTo:1.0 duration:0.15]]];
    SKNode *player = [self childNodeWithName:@"player"];
    SKNode *enemy  = [self childNodeWithName:@"enemy"];
    [scale setTimingMode:SKActionTimingEaseInEaseOut];
    [player runAction:scale];
    [enemy runAction:scale];
}

-(void)readPlayer1Move{
    
    
    switch (self.playerUsingType) {
        
        case PlayerMoveUp:
        {
            if (self.playerPosition>=4)return;
            if((self.playerPosition)+1==self.enemyPosition&&self.eUsingType!=EMoveUp)return;
            
            if((self.playerPosition)+2==self.enemyPosition&&self.eUsingType==EMoveDown){
                [self moveToSameSpot];
                return;
            }
            
            SKNode *player = [self childNodeWithName:@"player"];
            SKAction *up = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.11],
                                                   [SKAction moveByX:0. y:80.f duration:0.],
                                                   [SKAction scaleTo:1.0 duration:0.15]]];
            [up setTimingMode:SKActionTimingEaseInEaseOut];
            
            [player runAction:up];
            
            self.playerPosition++;
            
            break;
        }
        case PlayerMoveDown:
        {
            if (self.playerPosition<=1)return;
            SKNode *player = [self childNodeWithName:@"player"];
            SKAction *down = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.11],
                                                   [SKAction moveByX:0. y:-80.f duration:0.],
                                                   [SKAction scaleTo:1.0 duration:0.15]]];
            [down setTimingMode:SKActionTimingEaseInEaseOut];
            
            [player runAction:down];
            
            self.playerPosition--;
            
            break;
        }
        case PlayerCharge:
        {
            if(self.playerCharge>=3)return;
            self.playerCharge++;
            
            SKNode *player = [self childNodeWithName:@"player"];
            /*for (i=0; i<8; i++) {
             self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
             self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
             CGPoint point = CGPointMake(, <#CGFloat y#>);
             self.magicParticle.particlePosition = point;
             self.magicParticle.zPosition =2;
             SKAction *magicFade2 = [SKAction sequence:@[[SKAction moveTo:player.position duration:0.3],
             [SKAction waitForDuration:0.3],
             [SKAction removeFromParent]]];
             [magicFade2 setTimingMode:SKActionTimingEaseIn];
             }*/
            SKSpriteNode *blank = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeZero];
            blank.position = CGPointZero;
            blank.alpha=0.7;
            SKAction *waitToRemove = [SKAction sequence:@[[SKAction waitForDuration:0.8],[SKAction scaleTo:0 duration:0.3],[SKAction fadeAlphaTo:0 duration:0.1],[SKAction removeFromParent]]];
            [blank runAction:waitToRemove];
            [player addChild:blank];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.zPosition =2;
            CGPoint point = CGPointMake(-44, 0);if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            SKAction *magicFade2 = [SKAction sequence:@[[SKAction moveTo:CGPointZero duration:0.3]]];
            [magicFade2 setTimingMode:SKActionTimingEaseOut];
            
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(-37, 37);if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(00, 44);if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(37, 37);if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(44, 0);if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(37, -37);if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(0, -44);if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(-37, -37);if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            
            break;
        }
        case PlayerGuard:
        {
            if(self.playerCharge>0)self.playerCharge--;
            
            SKNode *player = [self childNodeWithName:@"player"];
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70, 5)];
            shield.alpha=0.7;
            shield.position = CGPointMake(0, 33);
            [shield setScale:0.0];
            SKAction *switchOn = [SKAction sequence:@[[SKAction scaleXTo:0.3 y:1.0 duration:0.1],
                                                      [SKAction scaleXTo:1.0 duration:0.1],
                                                      [SKAction waitForDuration:1.0],
                                                      [SKAction scaleXTo:0 duration:0.1],
                                                      [SKAction removeFromParent]]];
            [switchOn setTimingMode:SKActionTimingEaseInEaseOut];
            [shield runAction:switchOn];
            [player addChild:shield];
        }
            
        default:
            break;
    }
    
}

-(void)readEnemyFire{
    switch (self.eUsingType) {
        case EFire:
        {
            if(self.eCharge<=0)return;
            
            SKNode *player = [self childNodeWithName:@"enemy"];
            SKNode *enemy = [self childNodeWithName:@"player"];
            
            SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(0,0)];
            projectile.alpha = 1.0;
            projectile.position=CGPointMake(0,0);
            projectile.name = @"proj";
            projectile.zPosition =0;
            
            int maxFire = self.eCharge;
            
            SKAction *magicFade = [SKAction sequence:@[
                                                       [SKAction waitForDuration:1.2],
                                                       [SKAction removeFromParent]]];
            [magicFade setTimingMode:SKActionTimingEaseIn];
            [projectile runAction:magicFade completion:^{
                if (self.enemyPosition<=(self.playerPosition + self.eCharge)&&self.playerUsingType!=PlayerGuard) {
                    [self decreaseLifeOn:enemy];
                }
                self.eCharge =0;
            }];
            
            [player addChild:projectile];
            
            for (int i=0; i<maxFire; i++) {
                NSInteger x =(arc4random()% 100)+50;
                NSInteger y =((arc4random()% 100)-50);
                
                SKSpriteNode *projectile2 = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(0,0)];
                projectile2.alpha = 1.0;
                projectile2.position=CGPointMake(0,0);
                projectile2.name = @"proj2";
                projectile2.zPosition =0;
                
                CGFloat angle = tanf(   (x-(pow(-1, i)*x)/4)   /   (y-(80+(80*i)+15))   );
                
                SKAction* shoot = [SKAction sequence:@[[SKAction moveTo:CGPointMake((pow(-1, (i+1))*x),y) duration:0.2],
                                                       [SKAction waitForDuration:(i*0.2)],[SKAction rotateByAngle:(pow(-1, (i+1))*angle) duration:0.15],
                                                       [SKAction moveTo:CGPointMake((pow(-1, (i))*x)/4, -80-(80*i)-15) duration:0.2+(i*0.07)],[SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1.0 duration:0.0],[SKAction fadeAlphaTo:0. duration:.2],
                                                       [SKAction removeFromParent]]];
                [shoot setTimingMode:SKActionTimingEaseIn];
                
                [projectile2 runAction:shoot];
                [projectile addChild:projectile2];
                
                self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"projectile" ofType:@"sks"];
                self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                self.magicParticle.particlePosition = CGPointMake(0,0);
                self.magicParticle.zPosition =2;
                SKAction *flip = [SKAction scaleYTo:-1 duration:0];
                //[magicFade setTimingMode:SKActionTimingEaseInEaseOut];
                [self.magicParticle runAction:flip];

                //self.magicParticle.particleAction = shoot;
                
                [projectile2 addChild:self.magicParticle];
                
                self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"triangles" ofType:@"sks"];
                self.followParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                
                self.followParticle.particlePosition = CGPointMake(0,10);
                self.followParticle.particleAction = shoot;
                self.followParticle.targetNode = player;
                
                [projectile2 addChild:self.followParticle];
                
                self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"Tail" ofType:@"sks"];
                self.followParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                
                self.followParticle.particlePosition = CGPointMake(0,-10);
                self.followParticle.particleAction = shoot;
                self.followParticle.targetNode = player;
                self.followParticle.zPosition=1.8;
                
                [projectile2 addChild:self.followParticle];
            }
            
            break;
        }
        default:
            break;
    }
}

-(void)readEnermyMove{
    switch (self.eUsingType) {
        
        case EMoveUp:
        {
            if (self.enemyPosition>=5)return;
            SKNode *player = [self childNodeWithName:@"enemy"];
            SKAction *up = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.11],
                                                [SKAction moveByX:0. y:80.f duration:0.],
                                                [SKAction scaleTo:1.0 duration:0.15]]];
            [up setTimingMode:SKActionTimingEaseInEaseOut];
            
            [player runAction:up];
            
            self.enemyPosition++;
            
            break;
        }
        case EMoveDown:
        {
            if (self.enemyPosition<=2)return;
            if((self.enemyPosition)-1==self.playerPosition)return;
            
            SKNode *player = [self childNodeWithName:@"enemy"];
            SKAction *down = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.11],
                                                  [SKAction moveByX:0. y:-80.f duration:0.],
                                                  [SKAction scaleTo:1.0 duration:0.15]]];
            [down setTimingMode:SKActionTimingEaseInEaseOut];
            
            [player runAction:down];
            
            self.enemyPosition--;
            
            break;
        }
        case ECharge:
        {
            if(self.eCharge>=3)return;
            self.eCharge++;
            
            SKNode *player = [self childNodeWithName:@"enemy"];
            /*for (i=0; i<8; i++) {
             self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
             self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
             CGPoint point = CGPointMake(, <#CGFloat y#>);
             self.magicParticle.particlePosition = point;
             self.magicParticle.zPosition =2;
             SKAction *magicFade2 = [SKAction sequence:@[[SKAction moveTo:player.position duration:0.3],
             [SKAction waitForDuration:0.3],
             [SKAction removeFromParent]]];
             [magicFade2 setTimingMode:SKActionTimingEaseIn];
             }*/
            SKSpriteNode *blank = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeZero];
            blank.position = CGPointZero;
            blank.alpha=0.7;
            SKAction *waitToRemove = [SKAction sequence:@[[SKAction waitForDuration:0.8],[SKAction scaleTo:0 duration:0.3],[SKAction fadeAlphaTo:0 duration:0.1],[SKAction removeFromParent]]];
            [blank runAction:waitToRemove];
            [player addChild:blank];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.zPosition =2;
            CGPoint point = CGPointMake(-44, 0);if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            SKAction *magicFade2 = [SKAction sequence:@[[SKAction moveTo:CGPointZero duration:0.3],
                                                        [SKAction removeFromParent]]];
            [magicFade2 setTimingMode:SKActionTimingEaseOut];
            
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(-37, 37);if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(00, 44);if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(37, 37);if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(44, 0);if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(37, -37);if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(0, -44);if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(-37, -37);if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            
            break;
        }
        case EGuard:
        {
            if(self.eCharge>0)self.eCharge--;
        
            SKNode *player = [self childNodeWithName:@"enemy"];
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70, 5)];
            shield.alpha=0.7;
            shield.position = CGPointMake(0, -35);
            [shield setScale:0.0];
            SKAction *switchOn = [SKAction sequence:@[[SKAction scaleXTo:0.3 y:1.0 duration:0.1],
                                                      [SKAction scaleXTo:1.0 duration:0.1],
                                                      [SKAction waitForDuration:1.0],
                                                      [SKAction scaleXTo:0.0 duration:0.1],
                                                      [SKAction removeFromParent]]];
            [switchOn setTimingMode:SKActionTimingEaseInEaseOut];
            [shield runAction:switchOn];
            [player addChild:shield];
        }
            
        default:
            break;
    }
}

#pragma mark - enermy
-(void)enermyChoice{
    NSInteger random = ((arc4random()% 5));
    switch (random) {
        case 0:
            if (self.playerPosition+1==self.enemyPosition) {
                [self enermyChoice];
                break;
            }
            self.eMoveType = EMoveDown;
            break;
        case 1:
            if (self.enemyPosition>=5) {
                [self enermyChoice];
                break;
            }
            self.eMoveType = EMoveUp;
            break;
        case 2:
            if (self.eCharge<1||self.playerPosition+1<self.enemyPosition-self.eCharge) {
                [self enermyChoice];
                break;
            }
            self.eMoveType = EFire;
            break;
        case 3:
            if (self.eCharge>2) {
                [self enermyChoice];
                break;
            }
            self.eMoveType=ECharge;
            break;
        case 4:
            if (self.playerCharge+self.playerPosition>=self.enemyPosition) {
                
                self.eMoveType=EGuard;
            }else{
                [self enermyChoice];
                break;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - turn helper
-(void)updateForTurnEnds:(NSTimeInterval)currentTime{
#pragma mark Debug Mode
    self.timePerMove =2.;
    if (currentTime - self.timeOfLastMove < self.timePerMove) return;
    if (!self.gameBegin) {
        self.gameBegin=YES;
        self.timeOfLastMove=currentTime;
        return;
    }
    
    if(!multiMode)
    [self enermyChoice];
    
    self.playerUsingType=self.player1MoveType;
    self.eUsingType=self.eMoveType;
    
    [self readPlayer1Move];
    
    [self readEnermyMove];
    
    [self readPlayerFire];
    
    [self readEnemyFire];
    
    
    SKNode *control = [self childNodeWithName:@"playerControl"];
    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battle.png"]]];
    control = [self childNodeWithName:@"enemyControl"];
    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battle.png"]]];
    
    self.player1MoveType = none;
    self.eMoveType = ENone;
    
    self.timeOfLastMove=currentTime;
    
    [self turnIndicatorGreen];
}

-(void)endGame{
    [self removeAllActions];
    [self removeAllChildren];
    
    GameOverScene *gameOverScene =[[GameOverScene alloc]initWithSize:self.size];
    
    [self.view presentScene:gameOverScene transition:[SKTransition doorsOpenHorizontalWithDuration:0.8]];
    
}

#pragma mark Object Lifecycle Management
-(void)extraAnimation{
    
}

#pragma mark - Scene Update

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self updateForTurnEnds:currentTime];
}

#pragma mark Beta Testing

-(void)createBetaTester{
    SKSpriteNode *turnIndicator = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(self.frame.size.width, self.frame.size.height*3/4)];
    turnIndicator.alpha = 0.0;
    turnIndicator.position=CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame)));
    turnIndicator.name = @"indicator";
    turnIndicator.zPosition =0.5;
    
    [self addChild:turnIndicator];
}

-(void)turnIndicatorGreen{
    SKNode *indicator = [self childNodeWithName:@"indicator"];
    SKAction *change = [SKAction sequence:@[[SKAction colorizeWithColor:[UIColor greenColor] colorBlendFactor:1.0 duration:0.001],
                                            [SKAction fadeAlphaTo:0.7 duration:0.001],
                                            [SKAction fadeAlphaTo:0.0 duration:0.4],
                                            [SKAction waitForDuration:0.6],
                                            [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1.0 duration:0.001],
                                            [SKAction fadeAlphaTo:0.7 duration:0.001],
                                            [SKAction fadeAlphaTo:0.0 duration:0.4],
                                            [SKAction waitForDuration:0.6]]];
    
    [indicator runAction:change];
}

@end
