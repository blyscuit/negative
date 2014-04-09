//
//  OptionScene.m
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2557/01/24.
//  Copyright (c) 仏暦2557年 betaescape. All rights reserved.
//

#import "OptionScene.h"
#import "StartScene.h"
#import "MyScene.h"
#import "AppDelegate.h"



#define kBackGroundColor [UIColor colorWithWhite:0.92 alpha:1.0];

#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen]bounds].size.height-(double)568)<DBL_EPSILON)

static inline CGSize kContainerSize()
{
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? CGSizeMake(60, 60):CGSizeMake(90,90) ;
}
static inline CGSize kPlayerSize(){
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? CGSizeMake(23, 23):CGSizeMake(32,32) ;
}
static inline float kContainerSpace(){
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? IS_WIDESCREEN ? 20:5 :30 ;
}
static inline float kSizeMultiply(){
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? 1:1.5 ;
}


static const u_int32_t  kShieldCategory             = 0x1 <<2;
static const u_int32_t  kPlayerProjectileCategory   = 0x1 <<4;

@interface OptionScene()
@property CGPoint location;
@property SKLabelNode *live;
@property BOOL dragLock;
@property int intCry;


@property NSString *myParticlePath;
@property SKEmitterNode *magicParticle;
@property SKEmitterNode *followParticle;

@end

@implementation OptionScene
@synthesize location,maxLives,live,shield,saveArray;


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self readNumbersFromFile];
        self.intCry=0;
        
//        SKSpriteNode *world = [SKSpriteNode spriteNodeWithImageNamed:@"LaunchImage.png"];
//        world.size=CGSizeMake(self.frame.size.width, self.frame.size.height);
//        world.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//        world.zPosition=-1;
//        [self addChild:world];
        self.backgroundColor = kBackGroundColor;
        
        
        SKSpriteNode *redBrick = [SKSpriteNode spriteNodeWithImageNamed:@"PlayerMin.png"];
        [redBrick runAction:[SKAction colorizeWithColor:[UIColor colorWithRed:1. green:0.5 blue:.5 alpha:1.0] colorBlendFactor:.1 duration:1]];
        redBrick.size=CGSizeMake(40, 40);
        redBrick.position=CGPointMake(CGRectGetMidX(self.frame)-100,CGRectGetMidY(self.frame));
        redBrick.name = @"redBrick1";
        [self addChild:redBrick];
        
        for (int i=0; i<4; i++) {
            SKSpriteNode *over = [SKSpriteNode spriteNodeWithImageNamed:@"overB.png"];
            over.size =redBrick.size;
            [over runAction:[SKAction rotateByAngle:(M_PI/2)*i duration:0]];
            double random =(((double)arc4random() / 0x100000000)/2);
            over.alpha =0;
            SKAction *flick = [SKAction fadeAlphaTo:(((double)arc4random() / 0x100000000)/2) duration:(random+0.5)];
            //[over runAction:[SKAction repeatActionForever:flick]];
            [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[flick,[SKAction fadeAlphaTo:0 duration:flick.duration/2]]]]];
            [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:flick.duration],[SKAction rotateByAngle:-M_PI/2 duration:0]]]]];
            [redBrick addChild:over];
        }
        SKSpriteNode *redBrickO = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(40, 40)];
        redBrickO.name=@"redBrick";
        [redBrick addChild:redBrickO];
        
        SKSpriteNode *blueBrick = [SKSpriteNode spriteNodeWithImageNamed:@"PlayerPlus.png"];
        [blueBrick runAction:[SKAction colorizeWithColor:[UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:1.0] colorBlendFactor:.1 duration:1]];
        blueBrick.size=CGSizeMake(40, 40);
        blueBrick.position=CGPointMake(CGRectGetMidX(self.frame)+100,CGRectGetMidY(self.frame));
        blueBrick.name = @"blueBrick1";
        [self addChild:blueBrick];
        
        for (int i=0; i<4; i++) {
            SKSpriteNode *over = [SKSpriteNode spriteNodeWithImageNamed:@"overB.png"];
            over.size =blueBrick.size;
            [over runAction:[SKAction rotateByAngle:(M_PI/2)*i duration:0]];
            double random =(((double)arc4random() / 0x100000000)/2);
            over.alpha =0;
            SKAction *flick = [SKAction fadeAlphaTo:(((double)arc4random() / 0x100000000)/2) duration:(random+0.5)];
            //[over runAction:[SKAction repeatActionForever:flick]];
            [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[flick,[SKAction fadeAlphaTo:0 duration:flick.duration/2]]]]];
            [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:flick.duration],[SKAction rotateByAngle:M_PI/2 duration:0]]]]];
            [blueBrick addChild:over];
        }
        SKSpriteNode *blueBrickO = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(40, 40)];
        blueBrickO.name=@"blueBrick";
        [blueBrick addChild:blueBrickO];
        
        live = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Light"];
        live.name = @"live";
        live.fontSize = 15*kSizeMultiply();
        live.fontColor = [SKColor grayColor];
        live.text = [NSString stringWithFormat:@" "];
        live.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:live];
        
        SKLabelNode *maxLabel = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
        maxLabel.name = @"maxWord";
        maxLabel.fontSize = 15*kSizeMultiply();
        maxLabel.fontColor = [SKColor grayColor];
        maxLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        maxLabel.text = [NSString stringWithFormat:@"Max lives"];
        maxLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-(live.frame.size.height+maxLabel.frame.size.height));
        [self addChild:maxLabel];
        
        SKSpriteNode *greenBrick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:1.0] size:CGSizeMake(20*kSizeMultiply(), 20*kSizeMultiply())];
        greenBrick.position=CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-(40+30*kSizeMultiply()));
        greenBrick.name = @"greenBrick";
        SKAction *gray;
        if (!shield) {
            gray = [SKAction colorizeWithColor:[UIColor grayColor] colorBlendFactor:1.0 duration:0.1];
        }else{            gray = [SKAction colorizeWithColor:[UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:1.0] colorBlendFactor:1.0 duration:0.1];
        }
        [greenBrick runAction:gray];
        [self addChild:greenBrick];
        
        SKSpriteNode *greenBrick2 = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.9 green:.9 blue:0.9 alpha:1.0] size:CGSizeMake(19*kSizeMultiply(), 19*kSizeMultiply())];
        greenBrick2.position=greenBrick.position;
        greenBrick2.name = @"greenBrick2";
        [greenBrick2 setScale:.0];
        SKAction *zoom;
        if (shield) {
            zoom = [SKAction scaleTo:.0 duration:0.2];
        }else{
            zoom = [SKAction scaleTo:1.0 duration:0.2];
        }
        [zoom setTimingMode:SKActionTimingEaseInEaseOut];
        [greenBrick2 runAction:zoom];
        [self addChild:greenBrick2];
        
        SKSpriteNode *tutorialBrick =[SKSpriteNode spriteNodeWithImageNamed:@"tutorial.png"];
                                       tutorialBrick.size=CGSizeMake(80*kSizeMultiply(), 30*kSizeMultiply());//insert picture here?
        tutorialBrick.position=CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)*4/5);
        tutorialBrick.name = @"tutorial";
        [self addChild:tutorialBrick];
        
        SKShapeNode *whiteBall = [[SKShapeNode alloc] init];
        
        CGMutablePathRef myPath = CGPathCreateMutable();
        CGPathAddArc(myPath, NULL, 0,0, 11, 0, M_PI*2, YES);
        whiteBall.path = myPath;
        whiteBall.name=@"whiteBrick";
        whiteBall.lineWidth = .0;
        whiteBall.fillColor = [SKColor colorWithCIColor:[CIColor colorWithRed:.5 green:.5 blue:.5]];
        whiteBall.strokeColor = [SKColor clearColor];
        whiteBall.zPosition=2.;
        whiteBall.position=CGPointMake(100, 10);
        
        /*SKSpriteNode *whiteBrick = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(20, 20)];
        whiteBrick.position=CGPointMake(100,10);
        whiteBrick.name = @"whiteBrick";
        whiteBrick.zPosition=2.;*/
        SKSpriteNode *over = [SKSpriteNode spriteNodeWithImageNamed:@"tri2.png"];
        over.size =CGSizeMake(20, 20);
        over.position=whiteBall.position;
        over.zPosition=3.0;
        [over runAction:[SKAction rotateByAngle:(M_PI/2)*3 duration:0]];
        double random =(((double)arc4random() / 0x100000000)/2);
        over.alpha =0;
        SKAction *flick = [SKAction fadeAlphaTo:(((double)arc4random() / 0x100000000)) duration:((random+0.5)*4)];
        //[over runAction:[SKAction repeatActionForever:flick]];
        [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[flick,[SKAction fadeAlphaTo:0 duration:flick.duration/2]]]]];
        
        SKSpriteNode *whiteWhite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(30, 30)];
        whiteWhite.position=whiteBall.position;
        whiteWhite.zPosition=4.;
        whiteWhite.name = @"whiteBrick";

        
        SKSpriteNode *front = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.92 alpha:1.0] size:CGSizeMake(self.frame.size.width, 80)];
        front.position=CGPointMake(0,30);
        front.anchorPoint=CGPointZero;
        front.name = @"back1";
        front.zPosition=1.2;
        [self addChild:front];
        [front addChild:whiteBall];
        [front addChild:over];
        [front addChild:whiteWhite];
        
        SKSpriteNode *back = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:51./255. green:50./255. blue:52./255. alpha:1.] size:CGSizeMake(self.frame.size.width, 80)];
        back.position=CGPointMake((self.frame.size.width/2),70);
        back.name = @"back2";
        [self addChild:back];
        
        SKSpriteNode *shade = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:219./255. green:219./255. blue:219./255. alpha:1.] size:CGSizeMake(1, 80)];
        shade.name=@"shade";
        shade.position=CGPointMake(-.5, front.frame.size.height/2);
        shade.zPosition=1.1;
        [front addChild:shade];
        
        SKSpriteNode *bird = [SKSpriteNode spriteNodeWithImageNamed:@"logo-01.png"];
        bird.size = CGSizeMake(60, 60);
        bird.name=@"bird";
        bird.position=CGPointMake(back.frame.size.width/2-100, -5);
        bird.alpha=1.0;
        [back addChild:bird];
        
        
        self.physicsWorld.contactDelegate = self;
        
        /*SKSpriteNode *achievement = [SKSpriteNode spriteNodeWithImageNamed:@"GC.png"];
        achievement.size=CGSizeMake(30, 30);
        achievement.position = CGPointMake(achievement.frame.size.width/2, 200);
        achievement.name = @"achievement";
        achievement.zPosition = 1.0f;
        [self addChild:achievement];*/
        
            [self reportAchievementIdentifier:@"option" percentComplete:1.];
        
        
    }
    return self;
}

-(NSString*)dataFilePath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"Property.plist"];
    //return [[NSBundle mainBundle] pathForResource:@"datafile" ofType:@"plist"];
}

-(IBAction)saveData{
    
    [saveArray writeToFile:[self dataFilePath] atomically:YES];
}

-(void)readNumbersFromFile{
    //NSLog(@"content= %@ from %@",[NSArray arrayWithContentsOfFile:[self dataFilePath]],[self dataFilePath]);
    if(!saveArray){
        //NSLog(@"created");
        saveArray = [NSMutableArray array];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: [self dataFilePath]])
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"datafile" ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath: [self dataFilePath] error:nil];
    }
    saveArray = [NSMutableArray arrayWithContentsOfFile:[self dataFilePath]];
    
    maxLives = [[saveArray objectAtIndex:0]intValue];
    shield = [[saveArray objectAtIndex:1]intValue];
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    
    
    __block SKAction *effectPop = [SKAction group:@[[SKAction sequence:@[[SKAction scaleTo:.7 duration:.0],[SKAction scaleTo:1.1 duration:.18],[SKAction scaleTo:1. duration:.12]]],[SKAction sequence:@[[SKAction fadeAlphaTo:0.0 duration:0],[SKAction fadeAlphaTo:1.0 duration:.3]]]]];
    
    if ([node.name isEqualToString:@"redBrick"]) {
        //[self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        if(maxLives>1){
            maxLives--;
            SKNode *new = [self childNodeWithName:@"redBrick1"];
            SKAction *whitening = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.1 duration:.3];
            [new runAction:[SKAction sequence:@[whitening.reversedAction,whitening]]];
        }
        //live.text = [NSString stringWithFormat:@"%i",maxLives];
        
    }else if([node.name isEqualToString:@"blueBrick"]) {
        //[self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        maxLives++;
        
        SKNode *new = [self childNodeWithName:@"blueBrick1"];
        SKAction *whitening = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.1 duration:.3];
        [new runAction:[SKAction sequence:@[whitening.reversedAction,whitening]]];
    
        //live.text = [NSString stringWithFormat:@"%i",maxLives];
    }else if ([node.name isEqualToString:@"whiteBrick"]){
        /*SKAction *in = [SKAction group:@[[SKAction fadeAlphaTo:1. duration:0.4],[SKAction moveToX:CGRectGetMidX(self.frame)+100 duration:.3]]];
        SKAction *out = [SKAction group:@[[SKAction fadeAlphaTo:0. duration:.3],[SKAction moveToX:-100 duration:0.4]]];
        in.timingMode = SKActionTimingEaseInEaseOut;
        out.timingMode = SKActionTimingEaseInEaseOut;
        SKNode *bird = [self childNodeWithName:@"bird"];
        [bird runAction:in];
        [node runAction:out];
        */
        
        self.dragLock = YES;
    }else if ([node.name isEqualToString:@"greenBrick"]){
        SKAction *gray;
            shield=NO;
            gray = [SKAction colorizeWithColor:[UIColor grayColor] colorBlendFactor:1.0 duration:0.05];
        [node runAction:gray];
        SKNode *white = [self childNodeWithName:@"greenBrick2"];
        SKAction *zoom= [SKAction scaleTo:1.0 duration:0.25];
        [zoom setTimingMode:SKActionTimingEaseInEaseOut];
        [white runAction:zoom];
        [self shieldAnimation];
    }else if ([node.name isEqualToString:@"greenBrick2"]){
        SKAction *gray;
        shield=YES;
        SKNode *white = [self childNodeWithName:@"greenBrick"];
        SKAction *zoom= [SKAction scaleTo:0.0 duration:0.25];
        gray = [SKAction colorizeWithColor:[UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:1.0] colorBlendFactor:1.0 duration:0.05];
        [zoom setTimingMode:SKActionTimingEaseInEaseOut];
        [white runAction:gray];
        [node runAction:zoom];
        [self shieldAnimation];
    }else if ([node.name isEqualToString:@"bird"]){
        
        if ([node hasActions]) {
            return;
        }
        
        SKNode *back2 = [self childNodeWithName:@"back2"];
        SKAction *jump = [SKAction sequence:@[[SKAction moveByX:0 y:20 duration:0.12],[SKAction moveByX:0 y:-20 duration:.12],[SKAction moveByX:0 y:20 duration:0.12],[SKAction moveByX:0 y:-20 duration:.12],[SKAction waitForDuration:0.17]]];
        if (self.intCry<2) {
            
            
            if (self.intCry==0) {
                
                SKLabelNode *credit = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                credit.name = @"credit1";
                credit.fontSize = 9;
                credit.fontColor = [SKColor whiteColor];
                credit.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                credit.text = [NSString stringWithFormat:@"© 2014 CONFUSIAN"];
                credit.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-80);
                credit.alpha=.0;
                [back2 addChild:credit];
                
                SKLabelNode *credit2 = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                credit2.name = @"credit2";
                credit2.fontSize = 14;
                credit2.fontColor = [SKColor whiteColor];
                credit2.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                credit2.text = [NSString stringWithFormat:@"Negative"];
                credit2.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-22);
                credit2.alpha=.0;
                [back2 addChild:credit2];
                
                SKLabelNode *credit3 = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                credit3.name = @"credit3";
                credit3.fontSize = 12;
                credit3.fontColor = [SKColor whiteColor];
                credit3.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                credit3.text = [NSString stringWithFormat:@"@blyscuit"];
                credit3.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-55);
                credit3.alpha=.0;
                [back2 addChild:credit3];
                
                SKLabelNode *credit8 = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                credit8.name = @"credit8";
                credit8.fontSize = 10;
                credit8.fontColor = [SKColor whiteColor];
                credit8.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                credit8.text = [NSString stringWithFormat:@"designed & directed by"];
                credit8.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-40);
                credit8.alpha=.0;
                [back2 addChild:credit8];
                
                SKLabelNode *credit4 = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                credit4.name = @"credit4";
                credit4.fontSize = 10;
                credit4.fontColor = [SKColor whiteColor];
                credit4.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                credit4.text = [NSString stringWithFormat:@"thanks"];
                credit4.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-30);
                credit4.alpha=.0;
                [back2 addChild:credit4];
                
                SKLabelNode *credit5 = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                credit5.name = @"credit5";
                credit5.fontSize = 12;
                credit5.fontColor = [SKColor whiteColor];
                credit5.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                credit5.text = [NSString stringWithFormat:@"Lost Type Co-op(fonts)"];
                credit5.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-42);
                credit5.alpha=.0;
                [back2 addChild:credit5];
                
                SKLabelNode *credit6 = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                credit6.name = @"credit6";
                credit6.fontSize = 12;
                credit6.fontColor = [SKColor whiteColor];
                credit6.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                credit6.text = [NSString stringWithFormat:@"friends & families"];
                credit6.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-54);
                credit6.alpha=.0;
                [back2 addChild:credit6];
                
                SKLabelNode *credit7 = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                credit7.name = @"credit7";
                credit7.fontSize = 12;
                credit7.fontColor = [SKColor whiteColor];
                credit7.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                credit7.text = [NSString stringWithFormat:@"YOU"];
                credit7.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-66);
                credit7.alpha=.0;
                [back2 addChild:credit7];
                
                [[back2 childNodeWithName:@"credit2"] runAction:effectPop];
                [[back2 childNodeWithName:@"credit3"] runAction:effectPop];
                [[back2 childNodeWithName:@"credit1"] runAction:effectPop];
                [[back2 childNodeWithName:@"credit8"] runAction:effectPop];
            }else if(self.intCry==1){
                [[back2 childNodeWithName:@"credit4"] runAction:effectPop];
                [[back2 childNodeWithName:@"credit5"] runAction:effectPop];
                [[back2 childNodeWithName:@"credit6"] runAction:effectPop];
                [[back2 childNodeWithName:@"credit7"] runAction:effectPop];
                [[back2 childNodeWithName:@"credit2"] runAction:[SKAction fadeAlphaTo:0. duration:0.2]];
                [[back2 childNodeWithName:@"credit3"] runAction:[SKAction fadeAlphaTo:0. duration:0.2]];
                [[back2 childNodeWithName:@"credit8"] runAction:[SKAction fadeAlphaTo:0. duration:0.2]];
            }
            
            [self runAction:[SKAction playSoundFileNamed:@"birdcry.m4a" waitForCompletion:YES]];
            jump.timingMode = SKActionTimingEaseInEaseOut;
            [node runAction:[SKAction repeatAction:jump count:2] completion:^{
                self.intCry++;
            }];
            
        }else if(self.intCry==2){
            self.intCry++;
            [[back2 childNodeWithName:@"credit4"] runAction:[SKAction removeFromParent]];
            [[back2 childNodeWithName:@"credit5"] runAction:[SKAction removeFromParent]];
            [[back2 childNodeWithName:@"credit1"] runAction:[SKAction removeFromParent]];
            [[back2 childNodeWithName:@"credit2"] runAction:[SKAction removeFromParent]];
            [[back2 childNodeWithName:@"credit3"] runAction:[SKAction removeFromParent]];
            [[back2 childNodeWithName:@"credit6"] runAction:[SKAction removeFromParent]];
            [[back2 childNodeWithName:@"credit7"] runAction:[SKAction removeFromParent]];
            [[back2 childNodeWithName:@"credit8"] runAction:[SKAction removeFromParent]];
            [node runAction:[SKAction group:@[[SKAction sequence:@[[SKAction playSoundFileNamed:@"wood1A.m4a" waitForCompletion:NO],[SKAction moveByX:10 y:0 duration:0.12],[SKAction waitForDuration:.2],[SKAction playSoundFileNamed:@"wood1A.m4a" waitForCompletion:NO],[SKAction moveByX:10 y:0 duration:.12]]],jump]]completion:^{
            }];
            [node runAction:[SKAction scaleTo:0.8 duration:0]];
            [node runAction:[SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"logoR.png"]] timePerFrame:.0]];
        }else if (self.intCry>2){
            self.intCry=0;
            [node runAction:[SKAction sequence:@[[SKAction moveByX:-10 y:10 duration:0.12],[SKAction moveTo:CGPointMake(self.frame.size.width/2-100, -5) duration:.12]]]completion:^{
            }];
            [node runAction:[SKAction scaleTo:1. duration:0]];
            [node runAction:[SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"logo-01.png"]] timePerFrame:.0]];
        }
        
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint dragLocation = [touch locationInNode:self];
    
    if (location.x-dragLocation.x>150){
        
        [saveArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:maxLives]];
        [saveArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:shield]];
        if (self.intCry>2 && [[saveArray objectAtIndex:3]integerValue]<=1) {
            [saveArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInteger:1]];
        }
        [self saveData];
        SKNode*back=[self childNodeWithName:@"whiteBrick1"];
        
        StartScene *startS = [[StartScene alloc]initWithSize:self.size];
        startS.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:startS transition:[SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.8]];
    }
    
    if (self.dragLock) {
        if (dragLocation.x-location.x>0) {
            SKNode *back = [self childNodeWithName:@"back1"];
            [back runAction:[SKAction moveToX:((dragLocation.x-location.x)) duration:0]];
        }
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    
    UITouch *touch = [touches anyObject];
    location = [touch locationInNode:self];
    
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"twitter"]){
        [self companyPressed:self];
    }else if ([node.name isEqualToString:@"tutorial"]){
        [self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        gameScene.multiMode = NO;
        gameScene.touchLocation = location;
        AppDelegate *delegate =  ( AppDelegate *) [[UIApplication sharedApplication] delegate];
        gameScene.bgMusic=delegate.bgMusic;
        gameScene.tutorial=1;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65]];
    }else if ([node.name isEqualToString:@"achievement"]){
        [self reportAchievementIdentifier:@"manual" percentComplete:1.];
        [self loadAchievement];
    }
    
    if (self.dragLock) {
        
        SKNode *back = [self childNodeWithName:@"back1"];
        if (back.position.x>self.frame.size.width/2) {
            SKAction *moveIn = [SKAction moveToX:((self.frame.size.width)+1) duration:0.3];
            moveIn.timingMode = SKActionTimingEaseOut;
            [back runAction:moveIn completion:^{
                
                [self runAction:[SKAction playSoundFileNamed:@"wood1B.m4a" waitForCompletion:NO]];
                
                SKSpriteNode *grey =[SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:93/255. green:91/255. blue:93/255. alpha:1.] size:CGSizeMake(self.frame.size.width, 25)];
                grey.anchorPoint = CGPointMake(.5,1.);
                [grey setYScale:0];
                [grey setAlpha:1];
                grey.position = CGPointMake(0,-(40));
                SKAction *pop = [SKAction group:@[[SKAction fadeAlphaTo:1. duration:.1],[SKAction scaleYTo:1. duration:0.1]]];
                pop.timingMode = SKActionTimingEaseOut;
                [grey runAction:pop];
                
                
                SKNode *back2 = [self childNodeWithName:@"back2"];
                
                [back2 addChild:grey];
                
                
                
                __block SKAction *effectPop = [SKAction group:@[[SKAction sequence:@[[SKAction scaleTo:.7 duration:.0],[SKAction scaleTo:1.1 duration:.18],[SKAction scaleTo:1. duration:.12]]],[SKAction sequence:@[[SKAction fadeAlphaTo:0.0 duration:0],[SKAction fadeAlphaTo:1.0 duration:.3]]]]];
                
                pop = [SKAction sequence:@[[SKAction moveByX:0 y:22 duration:0.1],[SKAction moveByX:0 y:-2 duration:.03]]];
                [back2 runAction:pop completion:^{
                    SKSpriteNode *twitter = [SKSpriteNode spriteNodeWithImageNamed:@"twitterForNegative.png"];
                    twitter.size = CGSizeMake(100, 20);
                    twitter.position = CGPointMake(0, -13);
                    twitter.name=@"twitter";
                    [grey addChild:twitter];
                    
                    [twitter setScale:.0];
                    [twitter runAction:effectPop];
                    
                    SKLabelNode *credit8 = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                    credit8.name = @"credit8";
                    credit8.fontSize = 10;
                    credit8.fontColor = [SKColor whiteColor];
                    credit8.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                    credit8.text = [NSString stringWithFormat:@"designed & directed by"];
                    credit8.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-40);
                    credit8.alpha=.0;
                    [back2 addChild:credit8];
                    
                    SKLabelNode *credit3 = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Regular"];
                    credit3.name = @"credit3";
                    credit3.fontSize = 12;
                    credit3.fontColor = [SKColor whiteColor];
                    credit3.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
                    credit3.text = [NSString stringWithFormat:@"@blyscuit"];
                    credit3.position = CGPointMake(CGRectGetMidX(self.frame)-200,CGRectGetMidY(back2.frame)/2-55);
                    credit3.alpha=.0;
                    [back2 addChild:credit3];
                    
                    [credit8 runAction:effectPop];
                    [credit3 runAction:effectPop];
                    
                    [self reportAchievementIdentifier:@"credit" percentComplete:1.];
                }];
            }];
        }else{
            SKAction *moveIn = [SKAction moveToX:(0) duration:0.3];
            moveIn.timingMode = SKActionTimingEaseOut;
            [back runAction:moveIn];
        }
    }
    
    self.dragLock = NO;
}

-(IBAction)companyPressed:(id)sender{
    NSArray *urls = [NSArray arrayWithObjects:
                     @"twitter://user?screen_name={handle}", // Twitter
                     @"tweetbot:///user_profile/{handle}", // TweetBot
                     @"echofon:///user_timeline?{handle}", // Echofon
                     @"twit:///user?screen_name={handle}", // Twittelator Pro
                     @"x-seesmic://twitter_profile?twitter_screen_name={handle}", // Seesmic
                     @"x-birdfeed://user?screen_name={handle}", // Birdfeed
                     @"tweetings:///user?screen_name={handle}", // Tweetings
                     @"simplytweet:?link=http://twitter.com/{handle}", // SimplyTweet
                     @"icebird://user?screen_name={handle}", // IceBird
                     @"fluttr://user/{handle}", // Fluttr
                     @"http://twitter.com/{handle}",
                     nil];
    
    UIApplication *application = [UIApplication sharedApplication];
    
    for (NSString *candidate in urls) {
        NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{handle}" withString:@"confusians"]];
        if ([application canOpenURL:url]) {
            [application openURL:url];
            
            return;
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (!([live.text isEqualToString:[NSString stringWithFormat:@"%i",maxLives]])) {
        SKAction *fade = [SKAction fadeAlphaTo:0.0 duration:0.2];
        [live runAction:fade completion:^{
            live.text =[NSString stringWithFormat:@"%i",maxLives];
            SKAction *fade2 = [SKAction fadeAlphaTo:1.0 duration:0.2];
            [live runAction:fade2];
        }];
    }
}

#pragma mark - Game Center
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
    
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

-(void)loadAchievement{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
        UIViewController *vc = self.view.window.rootViewController;
        [vc presentViewController: gameCenterController animated: YES completion:nil];
    }
}

- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    if (achievement)
    {
        achievement.percentComplete = percent*100.;
        
        achievement.showsCompletionBanner = YES;    //Indicate that a banner should be shown
        
        NSArray *achievements = @[achievement];
        [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"Error in reporting achievements: %@", error);
             }
         }];
    }
}

-(void)shieldAnimation{
    
    SKNode *enemy = [self childNodeWithName:@"greenBrick"];
    
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(0,0)];
    projectile.alpha = 1.0;
    projectile.position=CGPointMake(self.frame.size.width/2,0);
    projectile.name = @"proj";
    projectile.zPosition =0;
    
    NSInteger maxFire = 3;
    
    BOOL willBreakGuard=NO;
    
    
    if(!shield){
        willBreakGuard=YES;
    }
    
    SKAction *magicFade = [SKAction sequence:@[
                                               [SKAction waitForDuration:1.2],
                                               [SKAction removeFromParent]]];
    [magicFade setTimingMode:SKActionTimingEaseIn];
    [projectile runAction:magicFade completion:^{
        if(willBreakGuard){
            [self runAction:[SKAction playSoundFileNamed:@"moveC.m4a" waitForCompletion:NO]];
            self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"shieldBreak" ofType:@"sks"];
            self.magicParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
            self.magicParticle.particlePosition = CGPointMake(0,-20*kSizeMultiply());
            self.magicParticle.zPosition =1.5;
            [enemy addChild:self.magicParticle];
            [self.magicParticle runAction:[SKAction sequence:@[[SKAction waitForDuration:.8],[SKAction removeFromParent]]]];
        }
    }];
    
    [self addChild:projectile];
    
    
    SKSpriteNode *shooter = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(0,0)];
    shooter.position=CGPointMake(self.frame.size.width/2,0);
    [self addChild:shooter];
    
    
    for (int i=0; i<maxFire; i++) {
        NSInteger x =((arc4random()% 100)+50)*kSizeMultiply();
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
        
        CGFloat angle = tanf(   (x-(pow(-1, i+1)*x)/4)   /   (((kContainerSize().height+kContainerSpace())+((kContainerSize().height+kContainerSpace())*i)+15)-y)   );
        
        SKAction* shoot = [SKAction sequence:@[[SKAction moveTo:CGPointMake((pow(-1, i)*x),y) duration:0.2],
                                               [SKAction waitForDuration:(i*0.2)],[SKAction rotateByAngle:(pow(-1, i)*angle) duration:0.15],//moveSound,
                                               [SKAction moveTo:CGPointMake((pow(-1, i+1)*x)/4, (kContainerSize().height+kContainerSpace())+((kContainerSize().height+kContainerSpace())*2)+30*kSizeMultiply()) duration:0.2+(3*0.07)],[SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1.0 duration:0.0],[SKAction fadeAlphaTo:0. duration:.2],
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
        
        self.followParticle.particlePosition = CGPointMake(0,-10*kSizeMultiply());
        self.followParticle.particleAction = shoot;
        self.followParticle.targetNode = shooter;
        
        [projectile2 addChild:self.followParticle];
        
        self.myParticlePath = [[NSBundle mainBundle] pathForResource:@"Tail" ofType:@"sks"];
        self.followParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:self.myParticlePath];
        
        self.followParticle.particlePosition = CGPointMake(0,10*kSizeMultiply());
        self.followParticle.particleAction = shoot;
        self.followParticle.targetNode = shooter;
        self.followParticle.zPosition=1.8;
        
        [projectile2 addChild:self.followParticle];
        
        
    }

    
    SKNode *player = [self childNodeWithName:@"greenBrick"];
    
    SKSpriteNode *guard;
    
    guard = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(70*kSizeMultiply(), 5*kSizeMultiply())];
    
    
    guard.alpha=0.7;
    guard.position = CGPointMake(0, -20*kSizeMultiply());
    [guard setScale:0.0];
    guard.name = @"shield";
    
    SKAction *switchOn = [SKAction sequence:@[[SKAction scaleXTo:0.3 y:1.0 duration:0.1],
                                              [SKAction scaleXTo:1.0 duration:0.1]]];
    [switchOn setTimingMode:SKActionTimingEaseInEaseOut];
    [guard runAction:switchOn completion:^{
        guard.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:guard.frame.size];
        guard.physicsBody.dynamic = YES;
        guard.physicsBody.affectedByGravity = NO;
        guard.physicsBody.categoryBitMask = kShieldCategory;
        guard.physicsBody.contactTestBitMask = kPlayerProjectileCategory;
        guard.physicsBody.collisionBitMask = kPlayerProjectileCategory;
        
        [guard runAction:[SKAction sequence:@[[SKAction waitForDuration:1.0],
                                               [SKAction scaleXTo:0.0 duration:0.1],
                                               [SKAction removeFromParent]]]];
    }];
    
    [guard runAction:switchOn];
    [player addChild:guard];
    
    SKSpriteNode *shieldIn = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(50, 50)];
    shieldIn.alpha=0.0;
    shieldIn.position = CGPointMake(0,0);
    shieldIn.zPosition=0.1;
    shieldIn.name = @"shield";
    shieldIn.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:kPlayerSize()];
    shieldIn.physicsBody.dynamic = NO;
    shieldIn.physicsBody.categoryBitMask = kShieldCategory;
    shieldIn.physicsBody.contactTestBitMask = kPlayerProjectileCategory;
    shieldIn.physicsBody.collisionBitMask = kPlayerProjectileCategory;
    [shieldIn runAction:[SKAction sequence:@[[SKAction waitForDuration:1.3],
                                             [SKAction removeFromParent]]]];
    [player addChild:shieldIn];
    
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    NSArray* nodeNames = @[contact.bodyA.node.name, contact.bodyB.node.name];
    if ([nodeNames containsObject:@"pproj2"]&&[nodeNames containsObject:@"shield"]) {
        if([contact.bodyA.node.name isEqualToString:@"pproj2"]){[contact.bodyA.node setSpeed:(-.5)];}
        else{[contact.bodyB.node setSpeed:(-.5)];}
        
        
        SKNode *guard = [self childNodeWithName:@"shield"];
        SKAction *flick =[SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1.0 duration:0.5];
        [guard runAction:[SKAction sequence:@[flick,flick.reversedAction]]];
        
        SKNode *player = [self childNodeWithName:@"greenBrick"];
        
        SKShapeNode *ball = [[SKShapeNode alloc] init];
        
        CGMutablePathRef myPath = CGPathCreateMutable();
        CGPathAddArc(myPath, NULL, 0,0, kPlayerSize().width*2*kSizeMultiply(), 0, M_PI*2, YES);
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
    }
}

@end
