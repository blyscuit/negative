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

@property BOOL gameBegin;

@property NSString *myParticlePath;
@property SKEmitterNode *magicParticle;

//Player1Property
@property NSInteger playerCharge;
@property BOOL playerGuardable;
@property CGPoint playerTouchLocation;

@property BOOL eGuardable;
@property NSInteger eCharge;
@property CGPoint enemyTouchLocation;

@end

@implementation MyScene

@synthesize multiMode,touchLocation;

-(void)didMoveToView:(SKView *)view{
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    }
}

-(void)resetStat{
    
}

-(void)createContent{
    [self setupContainers];
    
    self.timeOfLastMove =0.0;
    self.timePerMove=3.0;
    
    [self setupPlayer];
    self.playerPosition = 1;
    self.playerCharge = 0;
    self.playerGuardable = YES;
    
    [self setupPlayerButton];
    
    [self setupEnemy];
    self.enemyPosition = 5;
    self.eCharge = 0;
    self.eGuardable=YES;
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
    SKAction *rotate = [SKAction scaleXTo:-1. y:-1. duration:0.0];
    enemyControl.alpha=.5;
    enemyControl.position=CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height+enemyControl.size.height);
    enemyControl.name = @"enemyControl";
    [enemyControl runAction:rotate];
    [self addChild:enemyControl];
}

-(void)setupContainers{
    for (NSUInteger count=0; count<kContainsCount; count++) {
        SKSpriteNode *container = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:kContainerSize];
        
        [container setScale:0.1];
        [container setAlpha:0.0];
        
        NSInteger temp = count-2;
        NSTimeInterval randomTime =((arc4random()% 2)/1.5+0.5)+(0.15*temp);
        SKAction *appear = [SKAction fadeAlphaTo:1.0 duration:randomTime];
        SKAction *pop = [SKAction scaleTo:1.0 duration:randomTime];
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
                self.player1MoveType = PlayerMoveDown;
            }else if(location.x<self.frame.size.width*2/5){
                self.player1MoveType = PlayerMoveUp;
            }else if(location.x<self.frame.size.width*3/5){
                self.player1MoveType = PlayerCharge;
            }else if(location.x<self.frame.size.width*4/5){
                self.player1MoveType = PlayerFire;
            }else if(location.x<self.frame.size.width*5/5){
                self.player1MoveType = PlayerGuard;
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
                self.eMoveType = EGuard;
            }else if(location.x<self.frame.size.width*2/5){
                self.eMoveType = EFire;
            }else if(location.x<self.frame.size.width*3/5){
                self.eMoveType = PlayerCharge;
            }else if(location.x<self.frame.size.width*4/5){
                self.eMoveType = EMoveDown;
            }else if(location.x<self.frame.size.width*5/5){
                self.eMoveType = EMoveUp;
            }

        }

    }else{
        if (location.y<=self.frame.size.height) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            SKAction *moveIn = [SKAction moveToY:control.frame.size.height/2 duration:0.2];
            [control runAction:moveIn];
            self.playerTouchLocation = location;
            if (location.x<self.frame.size.width*1/5) {
                self.player1MoveType = PlayerMoveDown;
            }else if(location.x<self.frame.size.width*2/5){
                self.player1MoveType = PlayerMoveUp;
            }else if(location.x<self.frame.size.width*3/5){
                self.player1MoveType = PlayerCharge;
            }else if(location.x<self.frame.size.width*4/5){
                self.player1MoveType = PlayerFire;
            }else if(location.x<self.frame.size.width*5/5){
                self.player1MoveType = PlayerGuard;
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
            if (location.x<self.frame.size.width*1/5) {
                self.player1MoveType = PlayerMoveDown;
            }else if(location.x<self.frame.size.width*2/5){
                self.player1MoveType = PlayerMoveUp;
            }else if(location.x<self.frame.size.width*3/5){
                self.player1MoveType = PlayerCharge;
            }else if(location.x<self.frame.size.width*4/5){
                self.player1MoveType = PlayerFire;
            }else if(location.x<self.frame.size.width*5/5){
                self.player1MoveType = PlayerGuard;
            }
        }
        if (location.y>self.frame.size.height/2) {
            if (location.x<self.frame.size.width*1/5) {
                self.eMoveType = EGuard;
            }else if(location.x<self.frame.size.width*2/5){
                self.eMoveType = EFire;
            }else if(location.x<self.frame.size.width*3/5){
                self.eMoveType = PlayerCharge;
            }else if(location.x<self.frame.size.width*4/5){
                self.eMoveType = EMoveDown;
            }else if(location.x<self.frame.size.width*5/5){
                self.eMoveType = EMoveUp;
            }
        }
        
    }else{
        if (location.y<=self.frame.size.height) {
            if (location.x<self.frame.size.width*1/5) {
                self.player1MoveType = PlayerMoveDown;
            }else if(location.x<self.frame.size.width*2/5){
                self.player1MoveType = PlayerMoveUp;
            }else if(location.x<self.frame.size.width*3/5){
                self.player1MoveType = PlayerCharge;
            }else if(location.x<self.frame.size.width*4/5){
                self.player1MoveType = PlayerFire;
            }else if(location.x<self.frame.size.width*5/5){
                self.player1MoveType = PlayerGuard;
            }
        }
    }

}

#pragma mark - Input

-(void)readPlayerFire{
    switch (self.player1MoveType) {
        case PlayerFire:
        {
            if(self.playerCharge<=0)return;
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"magic" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.particlePosition = CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame))+((60.0+kContainerSpace)*(self.playerPosition-2)));
            SKAction *magicFade = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.4],
                                                       [SKAction removeFromParent]]];
            self.magicParticle.zPosition =2;
            //[magicFade setTimingMode:SKActionTimingEaseInEaseOut];
            [self.magicParticle runAction:magicFade];
            [self addChild:self.magicParticle];
            
            
            
            
            if (self.enemyPosition<=(self.playerPosition + self.playerCharge)&&self.eMoveType!=EGuard) {
                if (self.eMoveType==EFire&&self.enemyPosition<=(self.playerPosition + self.eCharge)) {
                    self.player1MoveType=PlayerGuard;
                }else{
                    [self endGame];
                }
            }
            
            self.playerCharge =0;
            break;
        }
            default:
            break;
    }
}

-(void)moveToSameSpot{
    self.player1MoveType=none;
    self.eMoveType=none;
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
    
    switch (self.player1MoveType) {
        
        case PlayerMoveUp:
        {
            if (self.playerPosition>=5)return;
            if((self.playerPosition)+1==self.enemyPosition&&self.eMoveType!=EMoveUp)return;
            
            if((self.playerPosition)+2==self.enemyPosition&&self.eMoveType==EMoveDown){
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
            break;
        }
        case PlayerGuard:
        {
            if(self.playerCharge>0)self.playerCharge--;
        }
            
        default:
            break;
    }
    
}

-(void)readEnemyFire{
    switch (self.eMoveType) {
        case EFire:
        {
            if(self.eCharge<=0)return;
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"magic" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.particlePosition = CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame))+((60.0+kContainerSpace)*(self.enemyPosition-4)));
            SKAction *magicFade = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.4],
                                                       [SKAction removeFromParent]]];
            self.magicParticle.zPosition =2;
            //[magicFade setTimingMode:SKActionTimingEaseInEaseOut];
            [self.magicParticle runAction:magicFade];
            [self addChild:self.magicParticle];
            
            
            
            if (self.enemyPosition<=(self.playerPosition + self.eCharge)&&self.player1MoveType!=PlayerGuard) {
                [self endGame];
            }
            
            self.eCharge =0;
            break;
        }
        default:
            break;
    }
}

-(void)readEnermyMove{
    switch (self.eMoveType) {
        
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
            if (self.enemyPosition<=1)return;
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
            break;
        }
        case EGuard:
        {
            if(self.eCharge>0)self.eCharge--;
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
            self.eMoveType = EMoveDown;
            break;
        case 1:
            self.eMoveType = EMoveUp;
            break;
        case 2:
            self.eMoveType = EFire;
            break;
        case 3:
            self.eMoveType=ECharge;
            break;
        case 4:
            self.eMoveType=EGuard;
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
    
    [self readPlayer1Move];
    
    [self readEnermyMove];
    
    [self readPlayerFire];
    
    [self readEnemyFire];
    
    self.player1MoveType = none;
    self.eMoveType = ENone;
    
    self.timeOfLastMove=currentTime;
    
    [self turnIndicatorGreen];
}

-(void)endGame{
    
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
