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
#define kPlayerSize CGSizeMake (55,55)
#define kSecondPlayerSize CGSizeMake (23,23)
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



static const u_int32_t  kEnemyCategory              = 0x1 << 0;
static const u_int32_t  kPlayerCategory             = 0x1 <<1;
static const u_int32_t  kShieldCategory             = 0x1 <<2;
static const u_int32_t  kEnemyProjectileCategory    = 0x1 <<3;
static const u_int32_t  kPlayerProjectileCategory   = 0x1 <<4;


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

@property BOOL animationMode;

@property NSInteger turnPassed;

@property NSString *myParticlePath;
@property SKEmitterNode *magicParticle;
@property SKEmitterNode *followParticle;

//Player1Property
@property NSInteger playerCharge;
@property BOOL playerGuardable;
@property CGPoint playerTouchLocation;
@property NSString *playerWords;
@property NSInteger playerLive;
@property NSInteger playerShieldCharge;
@property UIColor *playerColor;
@property SKLabelNode* playerSpeech;

@property BOOL eGuardable;
@property NSInteger eCharge;
@property CGPoint enemyTouchLocation;
@property NSString *eWords;
@property NSInteger eLive;
@property NSInteger eShieldCharge;
@property UIColor *eColor;
@property SKLabelNode* eSpeech;

@end

@implementation MyScene

@synthesize multiMode,touchLocation,maxLives,guardBreak,playerSpeech,eSpeech;

-(void)didMoveToView:(SKView *)view{
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
        
        
        self.physicsWorld.contactDelegate = self;
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
    self.timePerMove=2.0;
    
    
    double r =(((double)arc4random() / 0x100000000));
    double b =(((double)arc4random() / 0x100000000));
    double g =(((double)arc4random() / 0x100000000));
    
    self.playerColor = [UIColor colorWithCIColor:[CIColor colorWithRed:r green:g blue:b]];
    
    self.eColor = [UIColor colorWithCIColor:[CIColor colorWithRed:1.-r green:1.-g blue:1.-b]];
    
    [self setupPlayerWithSize:kPlayerSize Location:touchLocation];
    self.playerPosition = 1;
    self.playerCharge = 0;
    self.playerGuardable = YES;
    self.playerLive=2;
    self.playerLive=maxLives;
    
    
    
    [self setupPlayerButton];
    
    [self setupEnemyWithSize:kPlayerSize Location:touchLocation];
    self.enemyPosition = 5;
    self.eCharge = 0;
    self.eGuardable=YES;
    self.eLive=2;
    self.eLive=maxLives;
    if(multiMode)[self setupEnemyButton];
    
    self.player1MoveType = none;
    self.eMoveType = none;
    
    self.gameBegin = NO;
    
    self.animationMode=NO;
    
    self.turnPassed = 0;
    
    [self createBetaTester];
}


-(void)setupPlayerWithSize:(CGSize)size Location:(CGPoint)place{
    
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithImageNamed:@"PlayerWhite.png"];
    [player runAction:[SKAction colorizeWithColor:self.playerColor colorBlendFactor:.6 duration:0]];
    player.size =size;
    player.position=place;
    player.name = @"player";
    if (player.size.height==kPlayerSize.height) {
        [player setScale:0.3];
        [player setAlpha:0.01];
        SKAction *moveToStart = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame))+((60.0+kContainerSpace)*(-2))) duration:0.45];
        SKAction *scale = [SKAction scaleTo:1.0 duration:0.2];
        SKAction *alpha = [SKAction fadeAlphaTo:1.0 duration:0.6];
        [alpha setTimingMode:SKActionTimingEaseIn];
        [moveToStart setTimingMode:SKActionTimingEaseIn];
        [scale setTimingMode:SKActionTimingEaseIn];
        [player runAction:[SKAction sequence:@[moveToStart,scale]] completion:^{
            player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:player.frame.size];
            player.physicsBody.dynamic = NO;
            player.physicsBody.categoryBitMask = kPlayerCategory;
            
            player.physicsBody.contactTestBitMask = kEnemyProjectileCategory;
        }];
        [player runAction:alpha];
    }else{
        player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(40, 40)];
        player.physicsBody.dynamic = NO;
        player.physicsBody.categoryBitMask = kPlayerCategory;
        
        player.physicsBody.contactTestBitMask = kEnemyProjectileCategory;
    }
    
    [self addChild:player];
    
    for (int i=0; i<4; i++) {
        SKSpriteNode *over = [SKSpriteNode spriteNodeWithImageNamed:@"over.png"];
        over.size =size;
        [over runAction:[SKAction rotateByAngle:(M_PI/2)*i duration:0]];
        double random =(((double)arc4random() / 0x100000000)/2);
        over.alpha =0;
        SKAction *flick = [SKAction fadeAlphaTo:(((double)arc4random() / 0x100000000)/2) duration:(random+0.5)];
        //[over runAction:[SKAction repeatActionForever:flick]];
        [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[flick,[SKAction fadeAlphaTo:0 duration:flick.duration/2]]]]];
        [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:flick.duration],[SKAction rotateByAngle:M_PI/2 duration:0]]]]];
        [player addChild:over];
    }
    
    playerSpeech = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    
    playerSpeech.name = @"playerSpeech";
    playerSpeech.fontSize = 15;
    
    self.playerWords = [NSString stringWithFormat:@""];
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
    
    //[playerControl runAction:[SKAction colorizeWithColor:self.playerColor colorBlendFactor:.2 duration:0]];
}

-(void)setupEnemyWithSize:(CGSize)size Location:(CGPoint)place{
    
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PlayerWhite.png"];
    [enemy runAction:[SKAction colorizeWithColor:self.eColor colorBlendFactor:.6 duration:0]];
    enemy.size =size;
    enemy.position=place;
    enemy.name = @"enemy";
    if (enemy.size.height==kPlayerSize.height) {
        [enemy setScale:0.3];
        [enemy setAlpha:0.01];
        SKAction *moveToStart = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame))+((60.0+kContainerSpace)*(2))) duration:0.45];
        SKAction *scale = [SKAction scaleTo:1.0 duration:0.2];
        SKAction *alpha = [SKAction fadeAlphaTo:1.0 duration:0.6];
        [alpha setTimingMode:SKActionTimingEaseIn];
        [moveToStart setTimingMode:SKActionTimingEaseIn];
        [scale setTimingMode:SKActionTimingEaseIn];
        [enemy runAction:[SKAction sequence:@[moveToStart,scale]] completion:^{
            enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.frame.size];
            enemy.physicsBody.dynamic = NO;
            enemy.physicsBody.categoryBitMask = kEnemyCategory;
            
            enemy.physicsBody.contactTestBitMask = kPlayerProjectileCategory;
        }];
        [enemy runAction:alpha];
    }else{
        enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(40, 40)];
        enemy.physicsBody.dynamic = NO;
        enemy.physicsBody.categoryBitMask = kEnemyCategory;
        
        enemy.physicsBody.contactTestBitMask = kPlayerProjectileCategory;
    }
    
    [self addChild:enemy];
    
    for (int i=0; i<4; i++) {
        SKSpriteNode *over = [SKSpriteNode spriteNodeWithImageNamed:@"over.png"];
        over.size =size;
        [over runAction:[SKAction rotateByAngle:(M_PI/2)*i duration:0]];
        double random =(((double)arc4random() / 0x100000000)/2);
        over.alpha =0;
        SKAction *flick = [SKAction fadeAlphaTo:(((double)arc4random() / 0x100000000)/2) duration:(random+0.5)];
        //[over runAction:[SKAction repeatActionForever:flick]];
        [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[flick,[SKAction fadeAlphaTo:0 duration:flick.duration/2]]]]];
        [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:flick.duration],[SKAction rotateByAngle:-M_PI/2 duration:0]]]]];
        [enemy addChild:over];
    }

    
    eSpeech = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
    
    eSpeech.name = @"eSpeech";
    eSpeech.fontSize = 15;
    
    self.eWords = [NSString stringWithFormat:@" "];
    eSpeech.fontColor = [SKColor grayColor];
    eSpeech.text = [NSString stringWithFormat:@"%@",self.eWords];
    [eSpeech setScale:-1];
    eSpeech.position = CGPointMake(-enemy.frame.size.width*4,+playerSpeech.frame.size.height/2);
    [enemy addChild:eSpeech];
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
    
    //[enemyControl runAction:[SKAction colorizeWithColor:self.eColor colorBlendFactor:.2 duration:0]];
}

-(void)setupContainers{
    
//    SKSpriteNode *world = [SKSpriteNode spriteNodeWithImageNamed:@"LaunchImage.png"];
//    world.size=CGSizeMake(self.frame.size.width, self.frame.size.height);
//    world.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//    world.zPosition=-1;
//    [self addChild:world];

    
    for (NSUInteger count=0; count<kContainsCount; count++) {
        SKShapeNode *container = [[SKShapeNode alloc] init];
        
        CGMutablePathRef myPath = CGPathCreateMutable();
        CGPathAddArc(myPath, NULL, 0,0, (kContainerSize.width)/2, 0, M_PI*2, YES);
        container.path = myPath;
        container.name=@"pball";
        container.lineWidth = 1.0;
        container.fillColor = [SKColor lightGrayColor];
        container.strokeColor = [SKColor clearColor];
        container.glowWidth = 0.5;
        
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
    
    self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"line" ofType:@"sks"];
    self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
    self.magicParticle.particlePosition = CGPointZero;
    self.magicParticle.zPosition =0.1;
    
    [self addChild:self.magicParticle];
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
                if (!self.playerGuardable) {
                    return;
                }
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
                if (!self.eGuardable) {
                    return;
                }
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
                if (!self.playerGuardable) {
                    return;
                }
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
                if (!self.playerGuardable) {
                    return;
                }
                if (self.player1MoveType != PlayerGuard){
                    self.player1MoveType = PlayerGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1Neu.png"]]];
                }
            }
        }
        if (location.y>self.frame.size.height/2) {
            SKNode *control = [self childNodeWithName:@"enemyControl"];
            if (location.x<self.frame.size.width*1/5) {
                if (!self.eGuardable) {
                    return;
                }
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
                if (!self.playerGuardable) {
                    return;
                }
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
        
        if ([Enemy.name isEqualToString:@"player"]) {
            
            [self setupPlayerWithSize:kSecondPlayerSize Location:Enemy.position];
            
            self.playerLive--;
            if (self.playerLive<=0) {
                [self endGame];
                return;
            }
        }else if ([Enemy.name isEqualToString:@"enemy"]){
            
            [self setupEnemyWithSize:kSecondPlayerSize Location:Enemy.position];
            
            self.eLive--;
            if (self.eLive<=0) {
                [self endGame];
                return;
            }
        }
        [Enemy removeFromParent];
    }];
    
}

-(void)checkShield{
    if (self.playerGuardable == NO) {
        if (self.playerShieldCharge<7) {
            self.playerShieldCharge++;
        }else{
            self.playerShieldCharge=0;
            self.playerGuardable=YES;
            
            SKNode *player = [self childNodeWithName:@"player"];
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70, 5)];
            shield.alpha=0.7;
            shield.name=@"shield";
            shield.position = CGPointMake(0, 35);
            [shield setScale:0.0];
            SKAction *switchOn = [SKAction sequence:@[[SKAction scaleXTo:0.3 y:1.0 duration:0.1],
                                                      [SKAction scaleXTo:1.0 duration:0.1]]];
            [switchOn setTimingMode:SKActionTimingEaseInEaseOut];
            [shield runAction:switchOn completion:^{
                shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shield.frame.size];
                shield.physicsBody.dynamic = YES;
                shield.physicsBody.affectedByGravity = NO;
                shield.physicsBody.categoryBitMask = kShieldCategory;
                shield.physicsBody.collisionBitMask = kEnemyProjectileCategory;
                
                [shield runAction:[SKAction sequence:@[[SKAction waitForDuration:.2],
                                                       [SKAction scaleXTo:0.0 duration:0.1],
                                                       [SKAction removeFromParent]]]];
            }];
            
            [player addChild:shield];
        }
    }
    if (self.eGuardable == NO) {
        if (self.eShieldCharge<7) {
            self.eShieldCharge++;
        }else{
            self.eShieldCharge=0;
            self.eGuardable=YES;
            
            SKNode *player = [self childNodeWithName:@"enemy"];
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70, 5)];
            shield.alpha=0.7;
            shield.name = @"shield";
            shield.position = CGPointMake(0, -35);
            [shield setScale:0.0];
            SKAction *switchOn = [SKAction sequence:@[[SKAction scaleXTo:0.3 y:1.0 duration:0.1],
                                                      [SKAction scaleXTo:1.0 duration:0.1]]];
            [switchOn setTimingMode:SKActionTimingEaseInEaseOut];
            [shield runAction:switchOn completion:^{
                shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shield.frame.size];
                shield.physicsBody.dynamic = YES;
                shield.physicsBody.affectedByGravity = NO;
                shield.physicsBody.categoryBitMask = kShieldCategory;
                shield.physicsBody.collisionBitMask = kPlayerProjectileCategory;
                
                [shield runAction:[SKAction sequence:@[[SKAction waitForDuration:.2],
                                                       [SKAction scaleXTo:0.0 duration:0.1],
                                                       [SKAction removeFromParent]]]];
            }];
            
            [player addChild:shield];
        }
    }
}


-(void)readPlayerFire{
    switch (self.playerUsingType) {
        case PlayerFire:
        {
            if(self.playerCharge<=0){
                self.playerCharge=0;
                return;
            }
            
            
            [self runAction:[SKAction playSoundFileNamed:@"repel.m4a" waitForCompletion:NO]];
            
            
            SKNode *player = [self childNodeWithName:@"player"];
            SKNode *enemy = [self childNodeWithName:@"enemy"];
            
            SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(0,0)];
            projectile.alpha = 1.0;
            projectile.position=CGPointMake(0,0);
            projectile.name = @"proj";
            projectile.zPosition =0;
            
            NSInteger maxFire = self.playerCharge;
            
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
                    moveSound=[SKAction playSoundFileNamed:@"wood3B.m4a" waitForCompletion:NO];
                    break;
                case 2:
                    moveSound=[SKAction playSoundFileNamed:@"wood3C.m4a" waitForCompletion:NO];
                    break;
                case 3:
                    moveSound=[SKAction playSoundFileNamed:@"wood3E.m4a" waitForCompletion:NO];
                    break;
                default:
                    break;
            }
            
            for (int i=0; i<maxFire; i++) {
                NSInteger x =(arc4random()% 100)+50;
                NSInteger y =((arc4random()% 100)-50);
                
                SKSpriteNode *projectile2 = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1,1)];
                projectile2.alpha = 1.0;
                projectile2.position=CGPointMake(0,0);
                projectile2.name = @"pproj2";
                projectile2.zPosition =0;
                
                projectile2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:projectile2.frame.size];
                projectile2.physicsBody.dynamic = YES;
                projectile2.physicsBody.affectedByGravity = NO;
                projectile2.physicsBody.collisionBitMask = kShieldCategory;
                projectile2.physicsBody.categoryBitMask = kPlayerProjectileCategory;
                
                //projectile2.physicsBody.contactTestBitMask = kEnemyProjectileCategory;
                
                
                projectile2.physicsBody.friction = 0.0f;
                projectile2.physicsBody.restitution = 1.0f;
                projectile2.physicsBody.linearDamping = 0.0f;
                projectile2.physicsBody.allowsRotation = NO;
                
                CGFloat angle = tanf(   (x-(pow(-1, i+1)*x)/4)   /   ((80+(80*i)+15)-y)   );
                
                SKAction* shoot = [SKAction sequence:@[[SKAction moveTo:CGPointMake((pow(-1, i)*x),y) duration:0.2],
                                                 [SKAction waitForDuration:(i*0.2)],[SKAction rotateByAngle:(pow(-1, i)*angle) duration:0.15],//moveSound,
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
            if(self.playerCharge<=0){
                self.playerCharge=0;
            }
            
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
            if(self.playerCharge<=0){
                self.playerCharge=0;
            }
            
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
            if (self.playerCharge<0) {
                self.playerCharge=0;
            }
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
            
            SKNode *player = [self childNodeWithName:@"player"];
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70, 5)];
            
            if (self.playerCharge>(-2)) {
                shield = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70, 5)];
                self.playerCharge--;
            }else if (self.playerCharge==(-2)){
                shield = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(70, 5)];
                self.playerCharge--;
            }else if (self.playerCharge<(-2)){
                self.playerGuardable=NO;
                self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"shieldBreak" ofType:@"sks"];
                self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                self.magicParticle.particlePosition = CGPointMake(0,35);
                self.magicParticle.zPosition =1.5;
                [player addChild:self.magicParticle];
                self.playerUsingType=none;
                self.player1MoveType=none;
                SKNode *control = [self childNodeWithName:@"playerControl"];
                [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battle.png"]]];
                self.playerCharge=0;
                
                return;
            }
            
            
            shield.alpha=0.7;
            shield.position = CGPointMake(0, 33);
            [shield setScale:0.0];
            shield.name = @"shield";
            
            SKAction *switchOn = [SKAction sequence:@[[SKAction scaleXTo:0.3 y:1.0 duration:0.1],
                                                      [SKAction scaleXTo:1.0 duration:0.1]]];
            [switchOn setTimingMode:SKActionTimingEaseInEaseOut];
            [shield runAction:switchOn completion:^{
                shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shield.frame.size];
                shield.physicsBody.dynamic = YES;
                shield.physicsBody.affectedByGravity = NO;
                shield.physicsBody.categoryBitMask = kShieldCategory;
                shield.physicsBody.contactTestBitMask = kEnemyProjectileCategory;
                shield.physicsBody.collisionBitMask = kEnemyProjectileCategory;
                
                [shield runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],
                                                       [SKAction scaleXTo:0.0 duration:0.1],
                                                       [SKAction removeFromParent]]]];
            }];
            
            [shield runAction:switchOn];
            [player addChild:shield];
            
            SKSpriteNode *shieldIn = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:player.frame.size];
            shieldIn.alpha=0.0;
            shieldIn.position = CGPointMake(0,0);
            shieldIn.zPosition=0.1;
            shieldIn.name = @"shield";
            shieldIn.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(55, 55)];
            shieldIn.physicsBody.dynamic = NO;
            shieldIn.physicsBody.categoryBitMask = kShieldCategory;
            shieldIn.physicsBody.contactTestBitMask = kEnemyProjectileCategory;
            shieldIn.physicsBody.collisionBitMask = kEnemyProjectileCategory;
            [shieldIn runAction:[SKAction sequence:@[[SKAction waitForDuration:1.3],
                                                     [SKAction removeFromParent]]]];
            [player addChild:shieldIn];
            
        }
            
        default:
            break;
    }
    
}

-(void)readEnemyFire{
    switch (self.eUsingType) {
        case EFire:
        {
            if(self.eCharge<=0){
                self.eCharge=0;
                return;
            }
            
            [self runAction:[SKAction playSoundFileNamed:@"repel.m4a" waitForCompletion:NO]];
            
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
                
                SKSpriteNode *projectile2 = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1,1)];
                projectile2.alpha = 1.0;
                projectile2.position=CGPointMake(0,0);
                projectile2.name = @"eproj2";
                projectile2.zPosition =0;
                
                projectile2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:projectile2.frame.size];
                projectile2.physicsBody.dynamic = YES;
                projectile2.physicsBody.affectedByGravity = NO;
                projectile2.physicsBody.collisionBitMask = kShieldCategory;
                projectile2.physicsBody.categoryBitMask = kEnemyProjectileCategory;
                
                //projectile2.physicsBody.contactTestBitMask = kPlayerProjectileCategory;
                
                
                projectile2.physicsBody.friction = 0.0f;
                projectile2.physicsBody.restitution = 1.0f;
                projectile2.physicsBody.linearDamping = 0.0f;
                projectile2.physicsBody.allowsRotation = NO;
                
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
            if(self.eCharge<=0){
                self.eCharge=0;
            }
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
            if(self.eCharge<=0){
                self.eCharge=0;
            }
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
            if (self.eCharge<=0) {
                self.eCharge=0;
            }
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
        
            SKNode *player = [self childNodeWithName:@"enemy"];
            
            SKSpriteNode *shield;
            
            if (self.eCharge>(-2)) {
                shield = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70, 5)];
                self.eCharge--;
            }else if (self.eCharge==(-2)){
                shield = [SKSpriteNode spriteNodeWithColor:[UIColor brownColor] size:CGSizeMake(70, 5)];
                self.eCharge--;
            }else if (self.eCharge<(-2)){
                self.eGuardable=NO;
                self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"shieldBreak" ofType:@"sks"];
                self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                self.magicParticle.particlePosition = CGPointMake(0,-35);
                self.magicParticle.zPosition =1.5;
                [player addChild:self.magicParticle];
                self.eUsingType=ENone;
                self.eMoveType=ENone;
                SKNode *control = [self childNodeWithName:@"enemyControl"];
                [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battle.png"]]];
                self.eCharge=0;
                
                return;
            }
            
            
            shield.alpha=0.7;
            shield.position = CGPointMake(0, -35);
            [shield setScale:0.0];
            shield.name = @"shield";
            
            SKAction *switchOn = [SKAction sequence:@[[SKAction scaleXTo:0.3 y:1.0 duration:0.1],
                                                      [SKAction scaleXTo:1.0 duration:0.1]]];
            [switchOn setTimingMode:SKActionTimingEaseInEaseOut];
            [shield runAction:switchOn completion:^{
                shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:shield.frame.size];
                shield.physicsBody.dynamic = YES;
                shield.physicsBody.affectedByGravity = NO;
                shield.physicsBody.categoryBitMask = kShieldCategory;
                shield.physicsBody.contactTestBitMask = kPlayerProjectileCategory;
                shield.physicsBody.collisionBitMask = kPlayerProjectileCategory;
                
                [shield runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],
                                                       [SKAction scaleXTo:0.0 duration:0.1],
                                                       [SKAction removeFromParent]]]];
            }];
            
            [shield runAction:switchOn];
            [player addChild:shield];
            
            SKSpriteNode *shieldIn = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:player.frame.size];
            shieldIn.alpha=0.0;
            shieldIn.position = CGPointMake(0,0);
            shieldIn.zPosition=0.1;
            shieldIn.name = @"shield";
            shieldIn.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(55, 55)];
            shieldIn.physicsBody.dynamic = NO;
            shieldIn.physicsBody.categoryBitMask = kShieldCategory;
            shieldIn.physicsBody.contactTestBitMask = kPlayerProjectileCategory;
            shieldIn.physicsBody.collisionBitMask = kPlayerProjectileCategory;
            [shieldIn runAction:[SKAction sequence:@[[SKAction waitForDuration:1.3],
                                                     [SKAction removeFromParent]]]];
            [player addChild:shieldIn];
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
            if (self.playerCharge+self.playerPosition>=self.enemyPosition&&self.eGuardable==YES) {
                
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

-(void)playerChoice{
    NSInteger random = ((arc4random()% 5));
    switch (random) {
        case 0:
            if (self.playerPosition+1==self.enemyPosition) {
                [self playerChoice];
                break;
            }
            self.player1MoveType = PlayerMoveUp;
            break;
        case 1:
            if (self.enemyPosition>=5) {
                [self playerChoice];
                break;
            }
            self.player1MoveType = PlayerMoveDown;
            break;
        case 2:
            if (self.playerCharge<1||self.playerPosition+1<self.enemyPosition-self.playerCharge) {
                [self playerChoice];
                break;
            }
            self.player1MoveType = PlayerFire;
            break;
        case 3:
            if (self.playerCharge>2) {
                [self playerChoice];
                break;
            }
            self.player1MoveType=PlayerCharge;
            break;
        case 4:
            if (self.eCharge+self.playerPosition>=self.enemyPosition) {
                
                self.player1MoveType=PlayerGuard;
            }else{
                [self playerChoice];
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
    //self.timePerMove =2.;
    if (currentTime - self.timeOfLastMove < self.timePerMove) return;
    if (!self.gameBegin) {
        self.gameBegin=YES;
        self.timeOfLastMove=currentTime;
        return;
    }
    
    
#pragma mark Player AI
    if(self.player1MoveType==none)
    [self playerChoice];
    
    if(!multiMode)
    [self enermyChoice];
    
    self.playerUsingType=self.player1MoveType;
    self.eUsingType=self.eMoveType;
    
    [self readPlayer1Move];
    
    [self readEnermyMove];
    
    [self readPlayerFire];
    
    [self readEnemyFire];
    
    [self checkShield];
    
    
    SKNode *control = [self childNodeWithName:@"playerControl"];
    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battle.png"]]];
    control = [self childNodeWithName:@"enemyControl"];
    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battle.png"]]];
    
    self.player1MoveType = none;
    self.eMoveType = ENone;
    
    self.timeOfLastMove=currentTime;
    
    self.turnPassed++;
    
    [self adjustTimePerMove];
    
    [self turnIndicatorGreen];
    
}

-(void)adjustTimePerMove{
    if (self.timePerMove<1.) {
        return;
    }
    else if (self.timePerMove<1.2){
        self.speed=self.speed*1.001;
        self.timePerMove = self.timePerMove/self.speed;
        
        NSLog(@"%f",self.timePerMove);

        return;
    }
    self.speed=self.speed*pow(1.0005,self.turnPassed);
    self.timePerMove = self.timePerMove/self.speed;
    NSLog(@"%f",self.timePerMove);
}

-(void)endGame{
    [self removeAllActions];
    [self removeAllChildren];
    
    GameOverScene *gameOverScene =[[GameOverScene alloc]initWithSize:self.size];
    
    [self.view presentScene:gameOverScene transition:[SKTransition doorsOpenHorizontalWithDuration:0.8]];
    
}

#pragma mark - Contact

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    NSArray* nodeNames = @[contact.bodyA.node.name, contact.bodyB.node.name];
    if ([nodeNames containsObject:@"pproj2"]&&[nodeNames containsObject:@"shield"]) {
        if([contact.bodyA.node.name isEqualToString:@"pproj2"]){[contact.bodyA.node setSpeed:(-.5)];}
        else{[contact.bodyB.node setSpeed:(-.5)];}
        
        [self runAction:[SKAction playSoundFileNamed:@"moveE.m4a" waitForCompletion:NO]];
        
        SKNode *shield = [self childNodeWithName:@"shield"];
        SKAction *flick =[SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1.0 duration:0.5];
        [shield runAction:[SKAction sequence:@[flick,flick.reversedAction]]];
        
        SKNode *player = [self childNodeWithName:@"enemy"];
        
        SKShapeNode *ball = [[SKShapeNode alloc] init];
        
        CGMutablePathRef myPath = CGPathCreateMutable();
        CGPathAddArc(myPath, NULL, 0,0, 50, 0, M_PI*2, YES);
        ball.path = myPath;
        ball.name=@"eball";
        ball.lineWidth = 1.0;
        ball.fillColor = [SKColor cyanColor];
        ball.strokeColor = [SKColor whiteColor];
        ball.glowWidth = 0.5;
        ball.alpha=.3;
        
        if (![player childNodeWithName:ball.name]) {
            [ball runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0.2 duration:0.1],[SKAction fadeAlphaTo:0.0 duration:0.5],[SKAction removeFromParent]]]];
            [player addChild:ball];
        }
        
    }else if ([nodeNames containsObject:@"eproj2"]&&[nodeNames containsObject:@"shield"]) {
        if([contact.bodyA.node.name isEqualToString:@"eproj2"]){[contact.bodyA.node setSpeed:(-.5)];}
        else{[contact.bodyB.node setSpeed:(-.5)];}
        
        [self runAction:[SKAction playSoundFileNamed:@"moveE.m4a" waitForCompletion:NO]];
        
        SKNode *player = [self childNodeWithName:@"player"];
        
        SKShapeNode *ball = [[SKShapeNode alloc] init];
        
        CGMutablePathRef myPath = CGPathCreateMutable();
        CGPathAddArc(myPath, NULL, 0,0, 50, 0, M_PI*2, YES);
        ball.path = myPath;
        ball.name=@"pball";
        ball.lineWidth = 1.0;
        ball.fillColor = [SKColor cyanColor];
        ball.strokeColor = [SKColor whiteColor];
        ball.glowWidth = 0.5;
        ball.alpha=.2;
        
        if (![player childNodeWithName:ball.name]) {
            [ball runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0.2 duration:0.1],[SKAction fadeAlphaTo:0.0 duration:0.5],[SKAction removeFromParent]]]];
            [player addChild:ball];
        }
        
    }else if ([nodeNames containsObject:@"eproj2"]&&[nodeNames containsObject:@"player"]&&self.playerUsingType!=PlayerGuard) {
        contact.bodyA.node.zPosition=3.1;
        contact.bodyB.node.zPosition=3.1;
        [self textAnimationOn:eSpeech WithText:1];
        [self extraAnimation];
    }else if ([nodeNames containsObject:@"pproj2"]&&[nodeNames containsObject:@"enemy"]&&self.eUsingType!=EGuard) {
        contact.bodyA.node.zPosition=3.1;
        contact.bodyB.node.zPosition=3.1;
        [self textAnimationOn:playerSpeech WithText:1];
        [self extraAnimation];
    }

}

#pragma mark Object Lifecycle Management
-(void)extraAnimation{
    self.animationMode=YES;
    SKSpriteNode *back = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(self.frame.size.width*2, self.frame.size.height*2)];
    back.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    back.alpha=0.0;
    back.zPosition = 3.;
    if (![self childNodeWithName:@"black"]) {
        [self addChild:back];
        [back runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:0.65 duration:0.004],[SKAction waitForDuration:.025],[SKAction fadeAlphaTo:0.0 duration:0.2],[SKAction removeFromParent]]]];
    }
    [self setSpeed:0.03];
    double x =((double)arc4random() / 0x100000000);
    double y =((double)arc4random() / 0x100000000);
    [self runAction:[SKAction repeatAction:[SKAction sequence:@[[SKAction moveByX:8*x y:8*y duration:0.0005],[SKAction moveByX:-16*x y:-16*y duration:0.0005],[SKAction moveTo:CGPointZero duration:0.0005]]] count:3]];
    [self runAction:[SKAction playSoundFileNamed:@"C6.m4a" waitForCompletion:NO]];
    [self runAction:[SKAction waitForDuration:.025] completion:^{
        [self setSpeed:1.];
        self.animationMode=NO;
    }];
    
}

#pragma mark - Scene Update

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered*/
    if (self.animationMode) {
        self.timeOfLastMove = currentTime;
    }else{
    
        [self updateForTurnEnds:currentTime];
    }
    //[self playerAnimation];
}

-(void)playerAnimation{
    SKNode *player = [self childNodeWithName:@"player"];
    [player runAction:[SKAction rotateByAngle:(1/(M_2_PI)) duration:0.1]];
}

-(void)textAnimationOn:(SKNode*)text WithText:(NSInteger)textNumber{
    if ([text.name isEqualToString:@"playerSpeech"]){
        //NSString *text = textNumber
        
        self.playerWords = [NSString stringWithFormat:@"wahaha!"];
        playerSpeech.fontColor = [SKColor grayColor];
        playerSpeech.text = [NSString stringWithFormat:@"%@",self.playerWords];
    }else if ([text.name isEqualToString:@"eSpeech"]){
        
        self.eWords = [NSString stringWithFormat:@"bam!"];
        eSpeech.fontColor = [SKColor grayColor];
        eSpeech.text = [NSString stringWithFormat:@"%@",self.eWords];
    }
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
