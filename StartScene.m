//
//  StartScene.m
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2556/12/04.
//  Copyright (c) 仏暦2556年 betaescape. All rights reserved.
//

#import "StartScene.h"
#import "MyScene.h"
#import "ClassicScene.h"
#import "OptionScene.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "OnlineScene.h"

#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen]bounds].size.height-(double)568)<DBL_EPSILON)

static inline float kSizeMultiply(){
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? 1:2 ;
}
static inline float kMenuY(){
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? IS_WIDESCREEN ? -20:20 :0 ;
}

@interface StartScene()

@property CGPoint location;
@property BOOL classic;
@property BOOL loadMusic;

@end

@implementation StartScene

@synthesize location,maxLife,breakAble,saveArray,classic,loadMusic,level;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self createPlistForFirstTime];
        [self readNumbersFromFile];
        
        
        classic = NO;
        loadMusic=NO;
        [self runAction:[SKAction waitForDuration:1.]completion:^{
            loadMusic=YES;
        }];
        [self checkClassic];
        
        SKSpriteNode *world = [SKSpriteNode spriteNodeWithImageNamed:@"LaunchImage.png"];
        world.size=CGSizeMake(self.frame.size.width, self.frame.size.height);
        world.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        world.zPosition=-1;
        //[self addChild:world];
        self.backgroundColor = [SKColor colorWithWhite:0.92 alpha:1.0];
        
        //preload to prevent bug
        SKAction *preloadC5 = [SKAction playSoundFileNamed:@"C5.caf" waitForCompletion:YES];preloadC5.speed=preloadC5.speed;
        
        SKSpriteNode *spinner = [SKSpriteNode spriteNodeWithImageNamed:@"mainLogo.png"];
        spinner.name = @"spinner";
        spinner.size = CGSizeMake(100*kSizeMultiply(), 100*kSizeMultiply());
        spinner.position=CGPointMake(70,self.size.height-spinner.size.height*1.5+kMenuY());
        spinner.zPosition=-.5;
        [spinner runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI*2 duration:3]]];
        [self addChild:spinner];
        
        SKSpriteNode *cover = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(self.frame.size.width, 90*kSizeMultiply())];
        cover.name = @"cover";
        cover.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height-spinner.size.height*1.6+kMenuY());
        cover.zPosition=-.4;
        cover.alpha=.0;
        [cover runAction:[SKAction group:@[[SKAction moveByX:0 y:-15 duration:.6],[SKAction fadeAlphaTo:.6 duration:.6]]]];
        [self addChild:cover];
        
        SKLabelNode* title = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Light"];
        title.name = @"title";
        title.fontSize = 21*kSizeMultiply();
        title.fontColor = [SKColor blackColor];
        title.text = [NSString stringWithFormat:@"N-egative"];
        title.position = CGPointMake(0,-title.frame.size.height/2);
        [cover addChild:title];
        
        
        SKSpriteNode *beginButton = [SKSpriteNode spriteNodeWithImageNamed:@"AId.png"];
        beginButton.size=CGSizeMake(80*kSizeMultiply(), 30*kSizeMultiply());
        [beginButton runAction:[SKAction colorizeWithColor:[UIColor colorWithWhite:.5 alpha:0.7] colorBlendFactor:1. duration:.2]];
        
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
        /*SKSpriteNode *beginLine = [SKSpriteNode spriteNodeWithImageNamed:@"startLine.png"];
        beginLine.size=CGSizeMake(80, 50);//insert picture here?
        beginLine.position = CGPointMake(0,0);
        beginLine.name = @"beginButton";
        beginLine.zPosition = 1.1f;
        [beginButton addChild:beginLine];*/
        SKLabelNode *startText = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Light"];
        startText.fontSize=15;
        startText.fontColor = [SKColor colorWithWhite:0.92 alpha:1.0];
        startText.text = @"AI";
        startText.position = CGPointMake(25,-10);
        startText.zPosition = 1.1f;
        //[beginButton addChild:startText];
        
        SKSpriteNode *multiButton = [SKSpriteNode spriteNodeWithImageNamed:@"HUd.png"];
        multiButton.size=CGSizeMake(80*kSizeMultiply(), 30*kSizeMultiply());//insert picture here?
        [multiButton runAction:[SKAction colorizeWithColor:[self randomColor] colorBlendFactor:1. duration:.2]];
        multiButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-50*kSizeMultiply());
        multiButton.name = @"multiButton";
        multiButton.zPosition = 1.0f;
        [self addChild:multiButton];
        /*SKSpriteNode *multiLine = [SKSpriteNode spriteNodeWithImageNamed:@"startLine.png"];
        multiLine.size=CGSizeMake(80, 50);//insert picture here?
        multiLine.position = CGPointMake(0,0);
        multiLine.name = @"multiButton";
        multiLine.zPosition = 1.1f;
        [multiButton addChild:multiLine];*/
        SKLabelNode *multiText = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Light"];
         multiText.fontSize=15;
         multiText.fontColor = [SKColor colorWithWhite:0.92 alpha:1.0];
         multiText.text = @"HU";
         multiText.position = CGPointMake(25,-10);
         multiText.zPosition = 1.1f;
         //[multiButton addChild:multiText];
        
        if (classic==YES){
        SKSpriteNode *classicButton = [SKSpriteNode spriteNodeWithImageNamed:@"AIC.png"];
        classicButton.size=CGSizeMake(30*kSizeMultiply(), 30*kSizeMultiply());//insert picture here?
        classicButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-120*kSizeMultiply());
        classicButton.name = @"classicButton";
        classicButton.zPosition = 1.0f;
        [self addChild:classicButton];
        
        SKSpriteNode *classicMButton = [SKSpriteNode spriteNodeWithImageNamed:@"HUC.png"];
        classicMButton.size=CGSizeMake(30*kSizeMultiply(), 30*kSizeMultiply());
        classicMButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-170*kSizeMultiply());
        classicMButton.name = @"classicMButton";
        classicMButton.zPosition = 1.0f;
        [self addChild:classicMButton];
        }
        
        SKSpriteNode *config = [SKSpriteNode spriteNodeWithImageNamed:@"configFrame.png"];
        config.size=CGSizeMake(20, 20);
        config.anchorPoint=CGPointMake(0, .5);
        config.position = CGPointMake(0, 70);
        config.name = @"config";
        config.zPosition = 1.0f;
        [self addChild:config];
        
        SKSpriteNode *configor = [SKSpriteNode spriteNodeWithImageNamed:@"configor.png"];
        configor.size=CGSizeMake(20, 20);
        configor.position = CGPointMake(10, 70);
        configor.name = @"configor";
        configor.zPosition = 1.0f;
        [self addChild:configor];
        [configor runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:-M_PI*2 duration:5]]];
        
        
        SKSpriteNode *musicor = [SKSpriteNode spriteNodeWithImageNamed:@"music.png"];
        musicor.size=CGSizeMake(30, 30);
        musicor.position = CGPointMake(musicor.frame.size.width/2, musicor.frame.size.width/2+10);
        musicor.name = @"musicor";
        musicor.zPosition = 1.0f;
        musicor.alpha=.3;
        [self addChild:musicor];
        
        if (maxLife <=0) {
            maxLife =2;
        }
        
        [self checkMusic];
    }
    return self;
}

#pragma mark - Data
-(NSString*)dataFilePath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"Property.plist"];
    //return [[NSBundle mainBundle] pathForResource:@"datafile" ofType:@"plist"];
}

-(void)createPlistForFirstTime{
    NSFileManager *defFM = [NSFileManager defaultManager];
	NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //..Stuff that is done only once when installing a new version....
	static NSString *AppVersionKey = @"MyAppVersion";
	int lastVersion = [userDefaults integerForKey: AppVersionKey];
	if( lastVersion != 1.0 )	//..do this only once after install..
	{
		[userDefaults setInteger: 1.0 forKey: AppVersionKey];
		NSString *appDir = [[NSBundle mainBundle] resourcePath];
		NSString *src = [appDir stringByAppendingPathComponent: @"Property.plist"];
		NSString *dest = [docsDir stringByAppendingPathComponent: @"Property.plist"];
		[defFM removeItemAtPath: dest error: NULL];  //..remove old copy
		[defFM copyItemAtPath: src toPath: dest error: NULL];
	}
    //..end of stuff done only once when installing a new version.
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
    
    maxLife = [[saveArray objectAtIndex:0]intValue];
    breakAble = [[saveArray objectAtIndex:1]intValue];
    level = [[saveArray objectAtIndex:3]intValue];
    
}

-(IBAction)saveData{
    
    [saveArray writeToFile:[self dataFilePath] atomically:YES];
}

-(void)checkClassic{
    if ([[saveArray objectAtIndex:2]intValue]==1) {
        //ANIMATION HERE
        [saveArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:2]];
        [self saveData];
        classic=YES;
    }if([[saveArray objectAtIndex:2]intValue]==2) {
        classic=YES;
        
    }
}

-(void)checkMusic{
    AppDelegate *delegate = ( AppDelegate *) [[UIApplication sharedApplication] delegate];
    if(delegate.bgMusic){
        SKNode *musicor=[self childNodeWithName:@"musicor"];
        [musicor runAction:[SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:1 duration:0.]];
    }
}

#pragma mark - Touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    
    if ([node.name isEqualToString:@"beginButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        
        [self nodesDisappearWith:node];
    }else if ([node.name isEqualToString:@"multiButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood3.m4a" waitForCompletion:NO]];
        [self nodesDisappearWith:node];
        
    }else if ([node.name isEqualToString:@"classicButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        [self nodesDisappearWith:node];
        
    }else if ([node.name isEqualToString:@"classicMButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood3.m4a" waitForCompletion:NO]];
        [self nodesDisappearWith:node];
        
    }else if ([node.name isEqualToString:@"configor"]) {
        OptionScene *optionS = [[OptionScene alloc]initWithSize:self.size];
        optionS.scaleMode = SKSceneScaleModeAspectFill;
        optionS.maxLives = maxLife;
        optionS.shield = breakAble;
        [self.view presentScene:optionS transition:[SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.8]];
    }else if ([node.name isEqualToString:@"musicor"]) {
        [self setMusic];
    }else if ([node.name isEqualToString:@"online"]) {
        [self nodesDisappearWith:node];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint dragLocation = [touch locationInNode:self];
    
    if (dragLocation.x-location.x>150) {
        OptionScene *optionS = [[OptionScene alloc]initWithSize:self.size];
        optionS.scaleMode = SKSceneScaleModeAspectFill;
        optionS.maxLives = maxLife;
        optionS.shield = breakAble;
        [self.view presentScene:optionS transition:[SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.8]];
    }
}

-(void)nodesDisappearWith:(SKNode*)node{
    SKAction *scale = [SKAction sequence:@[[SKAction scaleTo:.1 duration:.15],[SKAction scaleXTo:1. duration:.07],[SKAction scaleXTo:.1 duration:.05],[SKAction scaleTo:.0 duration:.05]]];
    SKAction *color = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1. duration:0.22];
    SKNode *player = [self childNodeWithName:@"beginButton"];
    SKNode *enemy  = [self childNodeWithName:@"multiButton"];
    [scale setTimingMode:SKActionTimingEaseInEaseOut];
    [color setTimingMode:SKActionTimingEaseInEaseOut];
    
    [player runAction:scale];
    
    AppDelegate *delegate =  ( AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [enemy runAction:scale completion:^{
        if ([node.name isEqualToString:@"beginButton"]) {
            MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            gameScene.multiMode = NO;
            gameScene.touchLocation = location;
            gameScene.guardBreak = breakAble;
            gameScene.maxLives = maxLife;
            gameScene.bgMusic=delegate.bgMusic;
            if(level==0)
gameScene.tutorial=1;
            [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65]];
            
        }else if ([node.name isEqualToString:@"multiButton"]) {
            MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            gameScene.multiMode = YES;
            gameScene.touchLocation = location;
            gameScene.guardBreak = breakAble;
            gameScene.maxLives = maxLife;
            gameScene.bgMusic=delegate.bgMusic;
            [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
            
        }else if ([node.name isEqualToString:@"classicButton"]) {
            ClassicScene* gameScene = [[ClassicScene alloc] initWithSize:self.size];
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            gameScene.multiMode = NO;
            gameScene.touchLocation = location;
            [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
            
        }else if ([node.name isEqualToString:@"classicMButton"]) {
            ClassicScene* gameScene = [[ClassicScene alloc] initWithSize:self.size];
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            gameScene.multiMode = YES;
            gameScene.touchLocation = location;
            [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
            
        }else if ([node.name isEqualToString:@"online"]) {
            OnlineScene* gameScene = [[OnlineScene alloc] initWithSize:self.size];
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            gameScene.multiMode = YES;
            gameScene.touchLocation = location;
            gameScene.guardBreak = breakAble;
            gameScene.maxLives = maxLife;
            gameScene.bgMusic=delegate.bgMusic;
            [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
            
        }
    }];
    [player runAction:color];
    [enemy runAction:color];
}

-(void)setMusic{
    AppDelegate *delegate =  ( AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    SKNode *musicor=[self childNodeWithName:@"musicor"];
    if (delegate.bgMusic) {
        delegate.bgMusic=NO;
        
        [musicor runAction:[SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1 duration:0.]];
    }else{
        delegate.bgMusic=YES;
        [musicor runAction:[SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:1 duration:0.]];
    }
    [musicor runAction:[SKAction sequence:@[[SKAction fadeAlphaTo:1. duration:.5],[SKAction fadeAlphaTo:.3 duration:.8]]]];
}

-(void)brickDance:(NSInteger)brickNumber withTime:(CFTimeInterval*)currentTime{
    if (!loadMusic) {
        return;
    }
    
    AppDelegate *delegate =  ( AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (delegate.bgMusic){
    switch (brickNumber) {
        case 0:
            //brickName = @"redBrick";
            if((arc4random()%3)!=1){
                [self runAction:[SKAction playSoundFileNamed:@"D5.caf" waitForCompletion:NO]];
            }else{
                [self runAction:[SKAction playSoundFileNamed:@"C5.caf" waitForCompletion:NO]];
            }
            break;
        case 1:
            //brickName = @"blueBrick";
            if((arc4random()%3)!=1){
                [self runAction:[SKAction playSoundFileNamed:@"F5.caf" waitForCompletion:NO]];
            }else{
                [self runAction:[SKAction playSoundFileNamed:@"E5.caf" waitForCompletion:NO]];
            }
            break;
        case 2:
            //brickName = @"greenBrick";
            if((arc4random()%3)!=1){
                [self runAction:[SKAction playSoundFileNamed:@"A5.caf" waitForCompletion:NO]];
            }else{
                [self runAction:[SKAction playSoundFileNamed:@"G5.caf" waitForCompletion:NO]];
            }
            break;
        case 3:
            //brickName = @"whiteBrick";
            if((arc4random()%3)!=1){
                [self runAction:[SKAction playSoundFileNamed:@"B5.caf" waitForCompletion:NO]];
            }else{
                [self runAction:[SKAction playSoundFileNamed:@"C6.caf" waitForCompletion:NO]];
            }
            break;
            
        case 4:
        {
            SKNode *multi=[self childNodeWithName:@"multiButton"];
            SKNode *begin=[self childNodeWithName:@"beginButton"];
            SKSpriteNode *beginButton2 = [SKSpriteNode spriteNodeWithImageNamed:@"AI.png"];
            beginButton2.size=CGSizeMake(80*kSizeMultiply(), 30*kSizeMultiply());
            beginButton2.alpha=.5;
            [beginButton2 runAction:[SKAction scaleTo:1.3 duration:1.0]];
            [beginButton2 runAction:[SKAction fadeAlphaTo:.0 duration:1.0]];
            
            beginButton2.position =begin.position;
            beginButton2.zPosition = 0.0f;
            [self addChild:beginButton2];
            
            SKSpriteNode *multiButton = [SKSpriteNode spriteNodeWithImageNamed:@"HU.png"];
            multiButton.size=CGSizeMake(80, 30);//insert picture here?
            multiButton.position = multi.position;
            multiButton.zPosition = 0.0f;
            multiButton.alpha=.5;
            [multiButton runAction:[SKAction colorizeWithColor:[UIColor lightGrayColor] colorBlendFactor:1. duration:.0]];
            [multiButton runAction:[SKAction scaleTo:1.3 duration:1.0]];
            [multiButton runAction:[SKAction fadeAlphaTo:.0 duration:1.0]];
            [self addChild:multiButton];
        }
            
        default:
            return;
            break;
    }
    }
    if(brickNumber>3){
        return;
    }
    SKAction * dance = [SKAction moveToY:self.frame.size.height duration:1.1];
    dance.timingMode=SKActionTimingEaseOut;
    SKAction * danceOut = [SKAction moveByX:0 y:self.frame.size.height duration:dance.duration];
    danceOut.timingMode=SKActionTimingEaseIn;
    
    double sizeX =((arc4random()%10)+10)*kSizeMultiply();
    SKSpriteNode *whiteBrick = [SKSpriteNode spriteNodeWithColor:[self randomColor] size:CGSizeMake(sizeX, self.frame.size.height)];
    whiteBrick.anchorPoint=CGPointMake(0, 1);
    
    double x =(arc4random()%(int)self.size.width);
    //NSLog(@"%f",x);
    
    whiteBrick.position=CGPointMake(x,0);
    whiteBrick.name = @"whiteBrick";
    whiteBrick.zPosition=-4;
    [whiteBrick runAction:[SKAction sequence:@[dance,[SKAction waitForDuration:1.9],danceOut,[SKAction removeFromParent]]]];
    [self addChild:whiteBrick];
    
    
    SKNode *beginButton=[self childNodeWithName:@"beginButton"];
    [beginButton runAction:[SKAction colorizeWithColor:[UIColor colorWithWhite:drand48() alpha:1.0] colorBlendFactor:1. duration:.2]];

    if (brickNumber==arc4random()%10) {
        SKNode *multiButton=[self childNodeWithName:@"multiButton"];
        [multiButton runAction:[SKAction colorizeWithColor:[self randomColor] colorBlendFactor:1. duration:.2]];
    }
}

-(UIColor*)randomColor{
    double r =(((double)arc4random() / 0x100000000));
    double b =(((double)arc4random() / 0x100000000));
    double g =(((double)arc4random() / 0x100000000));
    
    UIColor * randomColor = [UIColor colorWithCIColor:[CIColor colorWithRed:r green:g blue:b]];
    return randomColor;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self brickDance:((arc4random()% 400)) withTime:&currentTime];
}

@end
