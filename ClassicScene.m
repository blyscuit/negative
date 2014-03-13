//
//  ClassicScene.m
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2557/01/13.
//  Copyright (c) 仏暦2557年 betaescape. All rights reserved.
//

#import "ClassicScene.h"
#import <AVFoundation/AVFoundation.h>


#import "MyScene.h"
//#import <CoreMotion/CoreMotion.h>
#import "StartScene.h"


#pragma mark - Custom Type Definitions

static inline CGSize kContainerSize()
{
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? CGSizeMake(60, 60):CGSizeMake(90,90) ;
}
static inline CGSize kPlayerSize(){
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? CGSizeMake(55, 55):CGSizeMake(82,82) ;
}
static inline float kContainerSpace(){
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? 20:30 ;
}
static inline CGSize kSecondPlayerSize(){
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? CGSizeMake(23, 23):CGSizeMake(32,32) ;
}
static inline float kSizeMultiply(){
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? 1:1.5 ;
}

#define kContainsCount 2
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


static const u_int32_t  kEnemyCategory              = 0x1 <<0;
static const u_int32_t  kPlayerCategory             = 0x1 <<1;
static const u_int32_t  kShieldCategory             = 0x1 <<2;
static const u_int32_t  kEnemyProjectileCategory    = 0x1 <<3;
static const u_int32_t  kPlayerProjectileCategory   = 0x1 <<4;


#pragma mark - Private GameScene Properties

@interface ClassicScene()

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
@property BOOL gameOver;

@property BOOL animationMode;

@property NSString *myParticlePath;
@property SKEmitterNode *magicParticle;

//Player1Property
@property NSInteger playerCharge;
@property BOOL playerGuardable;
@property CGPoint playerTouchLocation;
@property NSInteger playerShieldCharge;

@property BOOL eGuardable;
@property NSInteger eCharge;
@property CGPoint enemyTouchLocation;
@property NSInteger eShieldCharge;

@end

@implementation ClassicScene

@synthesize multiMode,touchLocation;

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
    [self setupContainers];
    
    self.timeOfLastMove =0.0;
    self.timePerMove=3.0;
    
    [self setupPlayer];
    self.playerPosition = 1;
    self.playerCharge = 0;
    self.playerGuardable = YES;
    self.playerShieldCharge = 0;
    
    [self setupPlayerButton];
    
    [self setupEnemy];
    self.enemyPosition = 2;
    self.eCharge = 0;
    self.eGuardable=YES;
    self.eShieldCharge=0;
    if(multiMode)[self setupEnemyButton];
    
    self.player1MoveType = none;
    self.eMoveType = none;
    
    self.gameBegin = NO;
    self.gameOver = NO;
    
    
    self.animationMode=NO;
    
    [self createBetaTester];
}


-(void)setupPlayer{
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:kPlayerSize()];
    [player setScale:0.3];
    [player setAlpha:0.01];
    player.zPosition=2.;
    player.position=touchLocation;
    SKAction *moveToStart = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame))+((kContainerSize().width+kContainerSpace())*(-1))) duration:0.45];
    SKAction *scale = [SKAction scaleTo:1.0 duration:0.2];
    SKAction *alpha = [SKAction fadeAlphaTo:1.0 duration:0.6];
    [alpha setTimingMode:SKActionTimingEaseIn];
    [moveToStart setTimingMode:SKActionTimingEaseIn];
    [scale setTimingMode:SKActionTimingEaseIn];
    player.name = @"player";
    [player runAction:[SKAction sequence:@[moveToStart,scale]] completion:^{
        player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:player.frame.size];
        player.physicsBody.dynamic = NO;
        player.physicsBody.categoryBitMask = kPlayerCategory;
        
        player.physicsBody.contactTestBitMask = kEnemyProjectileCategory;
    }];
    [player runAction:alpha];
    
    [self addChild:player];
}

-(void)setupPlayerButton{
    SKSpriteNode *playerControl = [SKSpriteNode spriteNodeWithImageNamed:@"battleC.png" ];
    playerControl.size=CGSizeMake(self.frame.size.width, self.size.width/6.4);
    playerControl.color =[UIColor blueColor];
    playerControl.alpha=.5;
    playerControl.position=CGPointMake(CGRectGetMidX(self.frame), -playerControl.size.height);
    playerControl.name = @"playerControl";
    [self addChild:playerControl];
}

-(void)setupEnemy{
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:kPlayerSize()];
    [enemy setScale:0.3];
    [enemy setAlpha:0.01];
    enemy.zPosition=2.;
    enemy.position=touchLocation;
    SKAction *moveToStart = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame))+((kContainerSize().width+kContainerSpace())*(1))) duration:0.45];
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
    }];[enemy runAction:alpha];
    enemy.name = @"enemy";
    [self addChild:enemy];
}

-(void)setupEnemyButton{
    SKSpriteNode *enemyControl = [SKSpriteNode spriteNodeWithImageNamed:@"battleC.png"];
    enemyControl.size=CGSizeMake(self.frame.size.width, self.size.width/6.4);
    enemyControl.color = [UIColor redColor];
    enemyControl.xScale = -1;
    enemyControl.yScale = -1;
    enemyControl.alpha=.5;
    enemyControl.position=CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height+enemyControl.size.height);
    enemyControl.name = @"enemyControl";
    [self addChild:enemyControl];
}

-(void)setupContainers{

    SKSpriteNode *world = [SKSpriteNode spriteNodeWithImageNamed:@"lightray.png"];
    world.size=CGSizeMake(self.frame.size.width, self.frame.size.height);
    world.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    world.zPosition=-1;
    world.name=@"world";
    [self addChild:world];

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
    if(self.gameOver){
        [self changeScene];
        return;
    }
    
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
            if(location.x<self.frame.size.width*1/3){
                if (self.player1MoveType != PlayerCharge){
                    self.player1MoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1PlusC.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/3){
                if (self.player1MoveType != PlayerFire){
                    self.player1MoveType = PlayerFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1NegC.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/3){
                if (self.player1MoveType != PlayerGuard){
                    if (!self.playerGuardable) {
                        return;
                    }
                    self.player1MoveType = PlayerGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1NeuC.png"]]];
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
            if (location.x<self.frame.size.width*1/3) {
                if (self.eMoveType != EGuard){
                    if (!self.eGuardable) {
                        return;
                    }
                    self.eMoveType = EGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2NeuC.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/3){
                if (self.eMoveType != EFire){
                    self.eMoveType = EFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2NegC.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/3){
                if (self.eMoveType != PlayerCharge){
                    self.eMoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2PlusC.png"]]];
                }
            }
            
        }
        
    }else{
        if (location.y<=self.frame.size.height) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            SKAction *moveIn = [SKAction moveToY:control.frame.size.height/2 duration:0.2];
            [control runAction:moveIn];
            self.playerTouchLocation = location;
            if(location.x<self.frame.size.width*1/3){
                if (self.player1MoveType != PlayerCharge){
                    self.player1MoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1PlusC.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/3){
                if (self.player1MoveType != PlayerFire){
                    self.player1MoveType = PlayerFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1NegC.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/3){
                if (self.player1MoveType != PlayerGuard){
                    if (!self.playerGuardable) {
                        return;
                    }
                    self.player1MoveType = PlayerGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1NeuC.png"]]];
                }
            }
        }
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    if(self.gameOver){
        return;
    }
    
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
    if(self.gameOver){
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if (multiMode) {
        if (location.y<=self.frame.size.height/2) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            if(location.x<self.frame.size.width*1/3){
                if (self.player1MoveType != PlayerCharge){
                    self.player1MoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1PlusC.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/3){
                if (self.player1MoveType != PlayerFire){
                    self.player1MoveType = PlayerFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1NegC.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/3){
                if (self.player1MoveType != PlayerGuard){
                    if (!self.playerGuardable) {
                        return;
                    }
                    self.player1MoveType = PlayerGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1NeuC.png"]]];
                }
            }
        }
        if (location.y>self.frame.size.height/2) {
            SKNode *control = [self childNodeWithName:@"enemyControl"];
            if (location.x<self.frame.size.width*1/3) {
                if (self.eMoveType != EGuard){
                    if (!self.eGuardable) {
                        return;
                    }
                    self.eMoveType = EGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2NeuC.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/3){
                if (self.eMoveType != EFire){
                    self.eMoveType = EFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2NegC.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/3){
                if (self.eMoveType != PlayerCharge){
                    self.eMoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"2PlusC.png"]]];
                }
            }
        }
        
    }else{
        if (location.y<=self.frame.size.height) {
            SKNode *control = [self childNodeWithName:@"playerControl"];
            if(location.x<self.frame.size.width*1/3){
                if (self.player1MoveType != PlayerCharge){
                    self.player1MoveType = PlayerCharge;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1PlusC.png"]]];
                }
            }else if(location.x<self.frame.size.width*2/3){
                if (self.player1MoveType != PlayerFire){
                    self.player1MoveType = PlayerFire;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1NegC.png"]]];
                }
            }else if(location.x<self.frame.size.width*3/3){
                if (self.player1MoveType != PlayerGuard){
                    if (!self.playerGuardable) {
                        return;
                    }
                    self.player1MoveType = PlayerGuard;
                    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"1NeuC.png"]]];
                }
            }
        }
    }
    
}

#pragma mark - Input

-(void)readPlayerFire{
    switch (self.playerUsingType) {
        case PlayerFire:
        {
            if(self.playerCharge<=0)return;
            
            SKNode *player = [self childNodeWithName:@"player"];
            SKNode *enemy = [self childNodeWithName:@"enemy"];
            
            SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1,1)];
            projectile.alpha = 1.0;
            projectile.position=CGPointMake(0,player.frame.size.height*2/3);
            projectile.name = @"pproj";
            projectile.zPosition =10.;
            
            SKAction *magicFade = [SKAction sequence:@[
                                                       //[SKAction moveTo:CGPointMake(enemy.position.x-player.position.x, enemy.position.y-player.position.y-60) duration:0.7],
                                                       [SKAction waitForDuration:0.9],
                                                       [SKAction removeFromParent]]];
            [magicFade setTimingMode:SKActionTimingEaseIn];
            [projectile runAction:magicFade completion:^{
                if (self.enemyPosition<=(self.playerPosition + self.playerCharge)) {
                    if (self.eUsingType==EGuard) {
                        if (self.playerCharge>1) {
                            self.eGuardable=NO;
                            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"shieldBreak" ofType:@"sks"];
                            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                            self.magicParticle.particlePosition = CGPointMake(0,-35*kSizeMultiply());
                            self.magicParticle.zPosition =1.5;
                            [enemy addChild:self.magicParticle];
                            self.eMoveType=ENone;
                            SKNode *control = [self childNodeWithName:@"enemyControl"];
                            [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battle.png"]]];
                        }
                        self.playerCharge =0;
                        return;
                    }
                    if (self.eUsingType==EFire&&self.eCharge==self.playerCharge) {
                        self.player1MoveType=PlayerGuard;
                        self.eCharge=0;
                    }else{
                        [self decreaseLifeOn:enemy];
                    }
                }
                self.playerCharge =0;
            }];
            
            projectile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:projectile.frame.size];
            projectile.physicsBody.dynamic = YES;
            projectile.physicsBody.affectedByGravity = NO;
            projectile.physicsBody.collisionBitMask = kShieldCategory;
            projectile.physicsBody.categoryBitMask = kPlayerProjectileCategory;
            
            projectile.physicsBody.contactTestBitMask = kEnemyProjectileCategory;
            
            
            projectile.physicsBody.friction = 0.0f;
            projectile.physicsBody.restitution = 1.0f;
            projectile.physicsBody.linearDamping = 0.0f;
            //projectile.physicsBody.allowsRotation = NO;
            
            [player addChild:projectile];
            
            [projectile.physicsBody applyImpulse:CGVectorMake(.0, .0065)];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"magicB" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.particlePosition = CGPointMake(0,0);
            self.magicParticle.zPosition =10.;
            self.magicParticle.particleAction = magicFade;
            self.magicParticle.targetNode=player;
            [projectile addChild:self.magicParticle];
            
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
            
        
        case PlayerCharge:
        {
            
            switch (self.playerCharge) {
                case 0:
                    [self runAction:[SKAction playSoundFileNamed:@"C5.m4a" waitForCompletion:NO]];
                    break;
                case 1:
                    [self runAction:[SKAction playSoundFileNamed:@"D5.m4a" waitForCompletion:NO]];
                    break;
                case 2:
                    [self runAction:[SKAction playSoundFileNamed:@"E5.m4a" waitForCompletion:NO]];
                    break;
                    
                default:
                    break;
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
            blank.alpha=0.7;blank.zPosition =2;
            SKAction *waitToRemove = [SKAction sequence:@[[SKAction waitForDuration:1],[SKAction removeFromParent]]];
            [blank runAction:waitToRemove];
            [player addChild:blank];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.zPosition =2;
            CGPoint point = CGPointMake(-44*kSizeMultiply(), 0);
            self.magicParticle.particlePosition = point;
            SKAction *magicFade2 = [SKAction sequence:@[[SKAction moveTo:CGPointZero duration:0.3],
                                                        [SKAction removeFromParent]]];
            [magicFade2 setTimingMode:SKActionTimingEaseOut];
            if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(-37*kSizeMultiply(), 37*kSizeMultiply());
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(00, 44*kSizeMultiply());
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(37*kSizeMultiply(), 37*kSizeMultiply());
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(44*kSizeMultiply(), 0);
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(37*kSizeMultiply(), -37*kSizeMultiply());
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(0, -44*kSizeMultiply());
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(-37*kSizeMultiply(), -37*kSizeMultiply());
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            if (self.playerCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            [blank addChild:self.magicParticle];
            
            break;
        }
        case PlayerGuard:
        {
            //if(self.playerCharge>0)self.playerCharge--;
            
            SKNode *player = [self childNodeWithName:@"player"];
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70, 5)];
            shield.alpha=0.7;
            shield.position = CGPointMake(0, 35*kSizeMultiply());
            shield.name = @"shield";
            [shield setScale:0.0];
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
            
            SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(1,1)];
            projectile.alpha = 1.0;
            projectile.position=CGPointMake(0,-player.frame.size.height*2/3);
            projectile.name = @"eproj";
            projectile.zPosition =10;
            
            SKAction *magicFade = [SKAction sequence:@[
                                                       //[SKAction moveTo:CGPointMake(0, enemy.position.y-player.position.y+60) duration:0.8],
                                                       [SKAction waitForDuration:0.9],
                                                       [SKAction removeFromParent]]];
            [magicFade setTimingMode:SKActionTimingEaseIn];
            [projectile runAction:magicFade completion:^{
                if (self.enemyPosition<=(self.playerPosition + self.eCharge)) {
                    if (self.playerUsingType==EGuard) {
                        if (self.eCharge>1) {
                            self.playerGuardable=NO;
                            self.player1MoveType=none;
                            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"shieldBreak" ofType:@"sks"];
                            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
                            self.magicParticle.particlePosition = CGPointMake(0,35*kSizeMultiply());
                            self.magicParticle.zPosition =1.5;
                            [enemy addChild:self.magicParticle];
                            SKNode *control = [self childNodeWithName:@"playerControl"];
                            [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battle.png"]]];
                            
                        }
                        self.eCharge=0;
                        return;
                    }
                    if (self.playerUsingType==PlayerFire&&self.eCharge==self.playerCharge) {
                        self.eUsingType=EGuard;
                        self.playerCharge=0;
                    }else{
                        [self decreaseLifeOn:enemy];
                    }
                }
                self.eCharge =0;
            }];
            
            projectile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:projectile.frame.size];
            projectile.physicsBody.dynamic = YES;
            projectile.physicsBody.affectedByGravity = NO;
            projectile.physicsBody.collisionBitMask = kShieldCategory;
            projectile.physicsBody.categoryBitMask = kEnemyProjectileCategory;
            
            
            projectile.physicsBody.friction = 0.0f;
            projectile.physicsBody.restitution = 1.0f;
            projectile.physicsBody.linearDamping = 0.0f;
            //projectile.physicsBody.allowsRotation = NO;
            
            [player addChild:projectile];
            
            [projectile.physicsBody applyImpulse:CGVectorMake(.0, -.0065)];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"magic" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.particlePosition = CGPointMake(0,0);
            self.magicParticle.zPosition =10;
            self.magicParticle.particleAction = magicFade;
            self.magicParticle.targetNode = player;
            [projectile addChild:self.magicParticle];
            
            break;
        }
        default:
            break;
    }
}


-(void)readEnermyMove{
    switch (self.eUsingType) {
            
        
        case ECharge:
        {
            switch (self.eCharge) {
                case 0:
                    [self runAction:[SKAction playSoundFileNamed:@"C5.m4a" waitForCompletion:NO]];
                    break;
                case 1:
                    [self runAction:[SKAction playSoundFileNamed:@"D5.m4a" waitForCompletion:NO]];
                    break;
                case 2:
                    [self runAction:[SKAction playSoundFileNamed:@"E5.m4a" waitForCompletion:NO]];
                    break;
                    
                default:
                    break;
            }
            if(self.eCharge>=3)return;
            self.eCharge++;
            
            SKNode *player = [self childNodeWithName:@"enemy"];
            SKSpriteNode *blank = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeZero];
            blank.position = CGPointZero;
            blank.alpha=0.7;blank.zPosition =2;
            SKAction *waitToRemove = [SKAction sequence:@[[SKAction waitForDuration:1],[SKAction removeFromParent]]];
            [blank runAction:waitToRemove];
            [player addChild:blank];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.zPosition =2;
            CGPoint point = CGPointMake(-44*kSizeMultiply(), 0);
            self.magicParticle.particlePosition = point;
            SKAction *magicFade2 = [SKAction sequence:@[[SKAction moveTo:CGPointZero duration:0.3],
                                                        [SKAction removeFromParent]]];
            if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            [magicFade2 setTimingMode:SKActionTimingEaseOut];
            
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(-37*kSizeMultiply(), 37*kSizeMultiply());if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(00, 44*kSizeMultiply());if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(37*kSizeMultiply(), 37*kSizeMultiply());if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(44*kSizeMultiply(), 0);if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(37*kSizeMultiply(), -37*kSizeMultiply());if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(0, -44*kSizeMultiply());if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"energy" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            point = CGPointMake(-37*kSizeMultiply(), -37*kSizeMultiply());if (self.eCharge==3)self.magicParticle.particleBlendMode =SKBlendModeSubtract;
            self.magicParticle.particlePosition = point;
            self.magicParticle.particleAction = magicFade2;
            [blank addChild:self.magicParticle];
            
            
            
            break;
        }
        case EGuard:
        {
            //if(self.eCharge>0)self.eCharge--;
            
            SKNode *player = [self childNodeWithName:@"enemy"];
            SKSpriteNode *shield = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70*kSizeMultiply(), 5*kSizeMultiply())];
            shield.alpha=0.7;
            shield.position = CGPointMake(0, -35*kSizeMultiply());
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
                shield.physicsBody.collisionBitMask = kPlayerProjectileCategory;
                shield.physicsBody.contactTestBitMask = kPlayerProjectileCategory;
                
                [shield runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],
                                                       [SKAction scaleXTo:0.0 duration:0.1],
                                                       [SKAction removeFromParent]]]];
            }];

            [player addChild:shield];
        }
            
        default:
            break;
    }
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
            shield.position = CGPointMake(0, 35*kSizeMultiply());
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
            shield.position = CGPointMake(0, -35*kSizeMultiply());
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

#pragma mark - enermy
-(void)enermyChoice{
    NSInteger random = ((arc4random()% 3)+2);
    switch (random) {
        case 0:
            if (self.enemyPosition>=5) {
                [self enermyChoice];
                break;
            }
            self.eMoveType = EMoveDown;
            break;
        case 1:
            if (self.playerPosition+1==self.enemyPosition) {
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
            if (self.eCharge>2||(!self.playerGuardable&&self.eCharge>1)) {
                [self enermyChoice];
                break;
            }
            self.eMoveType=ECharge;
            break;
        case 4:
            if (self.playerCharge+self.playerPosition>=self.enemyPosition&&self.eGuardable) {
                
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
    if (self.gameOver) {
        self.timeOfLastMove=currentTime;
        return;
    }
    if (!self.gameBegin) {
        self.gameBegin=YES;
        self.timeOfLastMove=currentTime;
        return;
    }
    
    if(!multiMode)
        [self enermyChoice];
    
    self.playerUsingType = self.player1MoveType;
    self.eUsingType = self.eMoveType;
    
    [self readPlayer1Move];
    
    [self readEnermyMove];
    
    [self readPlayerFire];
    
    [self readEnemyFire];
    
    [self checkShield];
    
    
    SKNode *control = [self childNodeWithName:@"playerControl"];
    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battleC.png"]]];
    control = [self childNodeWithName:@"enemyControl"];
    [control runAction:[SKAction setTexture:[SKTexture textureWithImageNamed:@"battleC.png"]]];
    self.player1MoveType = none;
    self.eMoveType = ENone;
    
    self.timeOfLastMove=currentTime;
    
    [self turnIndicatorGreen];
}

-(void)endGame{
    
    /*[self removeAllActions];
    [self removeAllChildren];
    
    GameOverScene *gameOverScene =[[GameOverScene alloc]initWithSize:self.size];
    
    [self.view presentScene:gameOverScene transition:[SKTransition doorsOpenHorizontalWithDuration:0.8]];*/
    
    if(self.gameOver)return;
    
    AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:@"Game Over"];
    [utterance setRate:.5];
    [av speakUtterance:utterance];
    
    self.gameOver=YES;
    
    SKAction *blink = [SKAction sequence:@[[SKAction fadeAlphaTo:1.0 duration:0.0],[SKAction waitForDuration:.5],[SKAction fadeAlphaTo:0.0 duration:.0],[SKAction waitForDuration:.5]]];
    
    if (!multiMode) {
        SKLabelNode* overLabel;
        overLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
        
        overLabel.name = @"playerSpeech";
        overLabel.fontSize = 30;
        
        overLabel.fontColor = [SKColor blackColor];
        overLabel.text = [NSString stringWithFormat:@"GAME OVER"];
        
        overLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:overLabel];
        [overLabel runAction:[SKAction repeatActionForever:blink]];

    }else{
        for (int i=1; i<=2; i++) {
            SKLabelNode* overLabel;
            overLabel = [SKLabelNode labelNodeWithFontNamed:kFontMissionGothicName];
            
            overLabel.name = @"playerSpeech";
            overLabel.fontSize = 30;
            
            overLabel.fontColor = [SKColor blackColor];
            overLabel.text = [NSString stringWithFormat:@"GAME OVER"];
            
            overLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)+(pow(-1, i)/2*CGRectGetMidY(self.frame)));
            [overLabel setScale:pow(-1, i)];
            [self addChild:overLabel];
            [overLabel runAction:[SKAction repeatActionForever:blink]];
        }
    }
    
    
}

-(void)changeScene{
    //[self removeAllActions];
    //[self removeAllChildren];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    StartScene* gameScene = [[StartScene alloc] initWithSize:self.size];
    gameScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:gameScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.8]];
}

#pragma mark Object Lifecycle Management
-(void)extraAnimation{
    self.animationMode=YES;
    [self setSpeed:0.03];
    [self runAction:[SKAction playSoundFileNamed:@"C6.m4a" waitForCompletion:NO]];
    [self runAction:[SKAction waitForDuration:0.02] completion:^{
        [self setSpeed:1.];
        self.animationMode=NO;
    }];
}

-(void)decreaseLifeOn:(SKNode*)Enemy{
    
    
    SKAction *hit = [SKAction sequence:@[[SKAction fadeAlphaTo:.0 duration:0.0],
                                         [SKAction waitForDuration:.1],
                                         [SKAction fadeAlphaTo:1.0 duration:.0],
                                         [SKAction waitForDuration:.1]]];
    
    [Enemy runAction:[SKAction repeatAction:hit count:5] completion:^{
        [self endGame];
        [Enemy removeFromParent];
    }];
    
}

#pragma mark - Scene Update

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (self.animationMode) {
        self.timeOfLastMove = currentTime;
    }else{
        
        [self updateForTurnEnds:currentTime];
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
    
    
    double r =(((double)arc4random() / 0x100000000));
    double b =(((double)arc4random() / 0x100000000));
    double g =(((double)arc4random() / 0x100000000));
    
    SKNode*world=[self childNodeWithName:@"world"];
    UIColor *randomC =[UIColor colorWithCIColor:[CIColor colorWithRed:r green:g blue:b]];
    [world runAction:[SKAction sequence:@[[SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1. duration:0.],[SKAction colorizeWithColor:randomC colorBlendFactor:.7 duration:1.]]]];
}

#pragma mark - Contact

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    NSArray* nodeNames = @[contact.bodyA.node.name, contact.bodyB.node.name];
    if ([nodeNames containsObject:@"pproj"]&&[nodeNames containsObject:@"eproj"]) {
        if (self.playerCharge>self.eCharge) {
            
            SKNode* fire = [self childNodeWithName:@"eproj"];
            if(contact.bodyA.node!=fire){[contact.bodyB.node removeFromParent];}
            else{[contact.bodyA.node removeFromParent];}
            
            self.eCharge =0;
            
        }else if (self.playerCharge<self.eCharge){
            
            SKNode* fire = [self childNodeWithName:@"pproj"];
            if(contact.bodyA.node!=fire){[contact.bodyA.node removeFromParent];}
            else{[contact.bodyB.node removeFromParent];}
            
            self.playerCharge =0;
            
        }else if(self.playerCharge==self.eCharge){
            [contact.bodyA.node removeFromParent];
            [contact.bodyB.node removeFromParent];
            self.playerCharge =0;
            self.eCharge =0;
        }
    }
    
    else if ([nodeNames containsObject:@"pproj"]&&[nodeNames containsObject:@"shield"]) {
        [self runAction:[SKAction playSoundFileNamed:@"moveE.m4a" waitForCompletion:NO]];
    }
    else if ([nodeNames containsObject:@"eproj"]&&[nodeNames containsObject:@"shield"]) {
        [self runAction:[SKAction playSoundFileNamed:@"moveE.m4a" waitForCompletion:NO]];
    }
    else if ([nodeNames containsObject:@"eproj"]&&[nodeNames containsObject:@"player"]&&self.playerUsingType!=PlayerGuard) {
        
        contact.bodyA.node.zPosition=-1;
        //NSLog(@"%f %f",contact.bodyB.node.zPosition,contact.bodyA.node.zPosition);
        [self extraAnimation];
    }else if ([nodeNames containsObject:@"pproj"]&&[nodeNames containsObject:@"enemy"]&&self.eUsingType!=EGuard) {
        contact.bodyA.node.zPosition=-1;
        //NSLog(@"%f %f",contact.bodyB.node.zPosition,contact.bodyA.node.zPosition);
        [self extraAnimation];
    }
    
}

@end
