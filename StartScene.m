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
static inline CGSize kContainerSize()
{
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? CGSizeMake(60, 60):CGSizeMake(90,90) ;
}

@interface StartScene()

@property CGPoint location;
@property BOOL classic;
@property BOOL loadMusic;
@property BOOL zooming;

@end

@implementation StartScene

@synthesize location,maxLife,breakAble,saveArray,classic,loadMusic,level,multiScreen;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self createPlistForFirstTime];
        [self readNumbersFromFile];
        
        self.zooming=NO;
        classic = NO;
        loadMusic=NO;
        [self runAction:[SKAction waitForDuration:1.]completion:^{
            loadMusic=YES;
        }];
        [self checkClassic];
        
        SKSpriteNode *world = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:self.size];
        world.position=CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        world.zPosition=0;
        world.name=@"world";
        [self addChild:world];
        
        self.backgroundColor = [SKColor colorWithWhite:0.92 alpha:1.0];
        
        //preload to prevent bug
        SKAction *preloadC5 = [SKAction playSoundFileNamed:@"C5.caf" waitForCompletion:YES];preloadC5.speed=preloadC5.speed;
        
        SKSpriteNode *spinner = [SKSpriteNode spriteNodeWithImageNamed:@"mainLogo.png"];
        spinner.name = @"spinner";
        spinner.size = CGSizeMake(100*kSizeMultiply(), 100*kSizeMultiply());
        spinner.position=CGPointMake(70-CGRectGetMidX(self.frame),self.size.height-spinner.size.height*1.5+kMenuY()-CGRectGetMidY(self.frame));
        spinner.zPosition=-.5;
        [spinner runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI*2 duration:3]]];
        [world addChild:spinner];
        
        SKSpriteNode *cover = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(self.frame.size.width, 90*kSizeMultiply())];
        cover.name = @"cover";
        cover.position = CGPointMake(CGRectGetMidX(self.frame)-CGRectGetMidX(self.frame), self.size.height-spinner.size.height*1.6+kMenuY()-CGRectGetMidY(self.frame));
        cover.zPosition=-.4;
        cover.alpha=.0;
        [cover runAction:[SKAction group:@[[SKAction moveByX:0 y:-15 duration:.6],[SKAction fadeAlphaTo:.6 duration:.6]]]];
        [world addChild:cover];
        
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

        beginButton.position = CGPointMake(CGRectGetMidX(self.frame)-CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-CGRectGetMidY(self.frame));
        beginButton.name = @"beginButton";
        beginButton.zPosition = 1.0f;
        [world addChild:beginButton];
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
        multiButton.position = CGPointMake(CGRectGetMidX(self.frame)-CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-50*kSizeMultiply()-CGRectGetMidY(self.frame));
        multiButton.name = @"multiButton";
        multiButton.zPosition = 1.0f;
        [world addChild:multiButton];
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
        classicButton.position = CGPointMake(CGRectGetMidX(self.frame)-CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-120*kSizeMultiply()-CGRectGetMidY(self.frame));
        classicButton.name = @"classicButton";
        classicButton.zPosition = 1.0f;
        [world addChild:classicButton];
        
        SKSpriteNode *classicMButton = [SKSpriteNode spriteNodeWithImageNamed:@"HUC.png"];
        classicMButton.size=CGSizeMake(30*kSizeMultiply(), 30*kSizeMultiply());
        classicMButton.position = CGPointMake(CGRectGetMidX(self.frame)-CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-170*kSizeMultiply()-CGRectGetMidY(self.frame));
        classicMButton.name = @"classicMButton";
        classicMButton.zPosition = 1.0f;
        [world addChild:classicMButton];
            
            
            
            [self reportAchievementIdentifier:@"classic" percentComplete:1.];
        }
        
        SKSpriteNode *config = [SKSpriteNode spriteNodeWithImageNamed:@"configFrame.png"];
        config.size=CGSizeMake(20, 20);
        config.anchorPoint=CGPointMake(0, .5);
        config.position = CGPointMake(0-CGRectGetMidX(self.frame), 70-CGRectGetMidY(self.frame));
        config.name = @"config";
        config.zPosition = 1.0f;
        [world addChild:config];
        
        SKSpriteNode *configor = [SKSpriteNode spriteNodeWithImageNamed:@"configor.png"];
        configor.size=CGSizeMake(20, 20);
        configor.position = CGPointMake(10-CGRectGetMidX(self.frame), 70-CGRectGetMidY(self.frame));
        configor.name = @"configor";
        configor.zPosition = 1.0f;
        [world addChild:configor];
        [configor runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:-M_PI*2 duration:5]]];
        
        SKSpriteNode *GCF = [SKSpriteNode spriteNodeWithImageNamed:@"GCFrame.png"];
        GCF.size=CGSizeMake(20, 20);
        GCF.anchorPoint=CGPointMake(0.5, .0);
        GCF.position = CGPointMake(70-CGRectGetMidX(self.frame), 0-CGRectGetMidY(self.frame));
        GCF.name = @"GC";
        GCF.zPosition = .99f;
        [world addChild:GCF];
        
        SKSpriteNode *GC = [SKSpriteNode spriteNodeWithImageNamed:@"GC.png"];
        GC.size=CGSizeMake(20, 20);
        GC.position = CGPointMake(70-CGRectGetMidX(self.frame), 9-CGRectGetMidY(self.frame));
        GC.name = @"GC";
        GC.zPosition = 1.0f;
        [world addChild:GC];
        //SKAction *fly = [SKAction moveByX:((double)arc4random() / 0x100000000) y:((double)arc4random() / 0x100000000) duration:((double)arc4random() / 0x100000000)];
        [GC runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:.0 y:2 duration:1.1],[SKAction waitForDuration:((double)arc4random() / 0x100000000) withRange:((double)arc4random() / 0x100000000)/2],[SKAction moveByX:-.0 y:-2 duration:1.1],[SKAction waitForDuration:((double)arc4random() / 0x100000000) withRange:((double)arc4random() / 0x100000000)/2]]]]];
        [GC runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:0.92 duration:1.1],[SKAction waitForDuration:((double)arc4random() / 0x100000000) withRange:((double)arc4random() / 0x100000000)/2],[SKAction scaleTo:1.0 duration:1.1],[SKAction waitForDuration:((double)arc4random() / 0x100000000) withRange:((double)arc4random() / 0x100000000)/2]]]]];
        
        
        SKSpriteNode *musicor = [SKSpriteNode spriteNodeWithImageNamed:@"music.png"];
        musicor.size=CGSizeMake(30, 30);
        musicor.position = CGPointMake(musicor.frame.size.width/2-CGRectGetMidX(self.frame), musicor.frame.size.width/2+10-CGRectGetMidY(self.frame));
        musicor.name = @"musicor";
        musicor.zPosition = 1.0f;
        musicor.alpha=.3;
        [world addChild:musicor];
        
        if (maxLife <=0) {
            maxLife =2;
        }
        
        [self checkMusic];
        
        multiScreen=YES;
        //NSLog(@"%d",multiScreen);
        //if (multiScreen==0) {
        //    multiScreen=YES;
        //    [self zoomMulti];
        //}
        
        [self runAction:[SKAction waitForDuration:3.] completion:^{
        [self reportAchievementIdentifier:@"welcome" percentComplete:1.];
        }];
        
        
        [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
            // Insert game-specific code here to clean up any game in progress.
            
            
            OnlineScene* gameScene = [[OnlineScene alloc] initWithSize:self.size];
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            gameScene.multiMode = NO;
            gameScene.touchLocation = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
            gameScene.guardBreak = YES;
            gameScene.maxLives = 2;
            gameScene.invite=YES;
            AppDelegate *delegate =  ( AppDelegate *) [[UIApplication sharedApplication] delegate];
            gameScene.bgMusic=delegate.bgMusic;
            [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
            
            if (acceptedInvite)
            {
                gameScene.invite=YES;
                GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
                mmvc.matchmakerDelegate = gameScene;
                UIViewController *vc = self.view.window.rootViewController;
                [vc presentViewController:mmvc animated:YES completion:nil];
                
            }
            else if (playersToInvite)
            {
                gameScene.invite=YES;
                GKMatchRequest *request = [[GKMatchRequest alloc] init];
                request.minPlayers = 2;
                request.maxPlayers = 2;
                request.playersToInvite = playersToInvite;
                
                GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
                mmvc.matchmakerDelegate = gameScene;
                UIViewController *vc = self.view.window.rootViewController;
                [vc presentViewController:mmvc animated:YES completion:nil];
            }
            
        };
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
        SKNode *world=[self childNodeWithName:@"world"];
        SKNode *musicor=[world childNodeWithName:@"musicor"];
        [musicor runAction:[SKAction colorizeWithColor:[UIColor blackColor] colorBlendFactor:1 duration:0.]];
    }
}


#pragma mark - Touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    if (self.zooming) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"beginButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        
        [self nodesDisappearWith:node];
    }else if ([node.name isEqualToString:@"multiButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood3.m4a" waitForCompletion:NO]];
        //[self nodesDisappearWith:node];
        [self zoomMulti];
        
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
    }else if ([node.name isEqualToString:@"wired"]) {
        MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        gameScene.multiMode = YES;
        gameScene.touchLocation = location;
        gameScene.guardBreak = breakAble;
        gameScene.maxLives = maxLife;
        AppDelegate *delegate =  ( AppDelegate *) [[UIApplication sharedApplication] delegate];
        gameScene.bgMusic=delegate.bgMusic;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
    }else if ([node.name isEqualToString:@"wireless"]) {
        if ([GKLocalPlayer localPlayer].isAuthenticated == YES) {
                // authentication successful
                OnlineScene* gameScene = [[OnlineScene alloc] initWithSize:self.size];
                gameScene.scaleMode = SKSceneScaleModeAspectFill;
                gameScene.multiMode = NO;
                gameScene.touchLocation = location;
                gameScene.guardBreak = YES;
                gameScene.maxLives = 2;
                AppDelegate *delegate =  ( AppDelegate *) [[UIApplication sharedApplication] delegate];
                gameScene.bgMusic=delegate.bgMusic;
                [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
        }else{
            
            GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
            gameCenterController.gameCenterDelegate = self;
            // player not logged in yet, present the vc
            UIViewController *vc = self.view.window.rootViewController;
            [vc presentViewController: gameCenterController animated: YES completion:nil];
        }
        
    }else if ([node.name isEqualToString:@"multiWorld"]) {
        [self zoomMulti];
    }else if ([node.name isEqualToString:@"GC"]) {
        [self loadAchievement];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.zooming||!multiScreen) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint dragLocation = [touch locationInNode:self];
    
    if (dragLocation.x-location.x>150&&multiScreen) {
        OptionScene *optionS = [[OptionScene alloc]initWithSize:self.size];
        optionS.scaleMode = SKSceneScaleModeAspectFill;
        optionS.maxLives = maxLife;
        optionS.shield = breakAble;
        [self.view presentScene:optionS transition:[SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.8]];
    }else if (dragLocation.y-location.y>300&&multiScreen){
        [self loadAchievement];
    }
}

-(void)nodesDisappearWith:(SKNode*)node{
    SKAction *scale = [SKAction sequence:@[[SKAction scaleTo:.1 duration:.15],[SKAction scaleXTo:1. duration:.07],[SKAction scaleXTo:.1 duration:.05],[SKAction scaleTo:.0 duration:.05]]];
    SKNode *world = [self childNodeWithName:@"world"];
    SKAction *color = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1. duration:0.22];
    SKNode *player = [world childNodeWithName:@"beginButton"];
    SKNode *enemy  = [world childNodeWithName:@"multiButton"];
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
        }
    }];
    [player runAction:color];
    [enemy runAction:color];
}

-(void)setMusic{
    AppDelegate *delegate =  ( AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    SKNode *world=[self childNodeWithName:@"world"];
    SKNode *musicor=[world childNodeWithName:@"musicor"];
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
    if (delegate.bgMusic&&multiScreen){
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
            SKNode *world=[self childNodeWithName:@"world"];
            //SKNode *multi=[self childNodeWithName:@"multiButton"];
            SKNode *begin=[self childNodeWithName:@"beginButton"];
            SKSpriteNode *beginButton2 = [SKSpriteNode spriteNodeWithImageNamed:@"AI.png"];
            beginButton2.size=CGSizeMake(80*kSizeMultiply(), 30*kSizeMultiply());
            beginButton2.alpha=.5;
            beginButton2.zPosition=-.1;
            [beginButton2 runAction:[SKAction scaleTo:1.3 duration:1.0]];
            [beginButton2 runAction:[SKAction fadeAlphaTo:.0 duration:1.0]];
            
            beginButton2.position =CGPointMake(begin.position.x, begin.position.y);
            beginButton2.zPosition = 0.0f;
            [world addChild:beginButton2];
            
            SKSpriteNode *multiButton = [SKSpriteNode spriteNodeWithImageNamed:@"HU.png"];
            multiButton.size=CGSizeMake(80*kSizeMultiply(), 30*kSizeMultiply());//insert picture here?
            multiButton.position = CGPointMake(CGRectGetMidX(self.frame)-CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-50*kSizeMultiply()-CGRectGetMidY(self.frame));
            multiButton.zPosition = -.1f;
            multiButton.alpha=.5;
            [multiButton runAction:[SKAction colorizeWithColor:[UIColor lightGrayColor] colorBlendFactor:1. duration:.0]];
            [multiButton runAction:[SKAction scaleTo:1.3 duration:1.0]];
            [multiButton runAction:[SKAction fadeAlphaTo:.0 duration:1.0]];
            [world addChild:multiButton];
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

-(void)zoomMulti{
    
    self.zooming=YES;
    
    SKNode*world=[self childNodeWithName:@"world"];
    SKNode*multiWorld1=[self childNodeWithName:@"multiWorld"];
    
    switch (multiScreen) {
        case NO:
        {
            //zoom to main
            
            SKAction *zoom =[SKAction sequence:@[[SKAction scaleTo:1.05 duration:.35],[SKAction scaleTo:1. duration:.08]]];
            [zoom setTimingMode:SKActionTimingEaseOut];
            [world runAction:zoom];
            world.zPosition=0;
            
            [multiWorld1 runAction:[SKAction scaleTo:1.7 duration:0.5]];
            [multiWorld1 runAction:[SKAction sequence:@[[SKAction colorizeWithColor:[UIColor colorWithWhite:1.0 alpha:1.0] colorBlendFactor:1. duration:0.3],[SKAction fadeAlphaTo:.0 duration:.2],[SKAction removeFromParent]]]completion:^{
                self.zooming=NO;
            }];
            
            multiScreen=YES;
            break;
        }
        case YES:
        {
            //zoom to multi
            SKAction *zoom =[SKAction sequence:@[[SKAction scaleTo:.15 duration:.35],[SKAction scaleTo:.2 duration:.08]]];
            [zoom setTimingMode:SKActionTimingEaseOut];
            [world runAction:zoom];
            
            SKSpriteNode *multiWorld = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1. alpha:0.0] size:self.size];
            multiWorld.position=world.position;
            multiWorld.name=@"multiWorld";
            [self addChild:multiWorld];
            multiWorld.zPosition=20;
            [multiWorld setScale:1.5];
            
            SKSpriteNode *wired = [SKSpriteNode spriteNodeWithImageNamed:@"wired.png"];
            wired.position=CGPointMake(0+[self multiPosition].x, 0-[self multiPosition].y);
            wired.size= kContainerSize();
            wired.name=@"wired";
            
            for (int i=0; i<4; i++) {
                SKSpriteNode *over = [SKSpriteNode spriteNodeWithImageNamed:@"over.png"];
                over.size =wired.size;
                [over runAction:[SKAction rotateByAngle:(M_PI/2)*i duration:0]];
                double random =(((double)arc4random() / 0x100000000)/2);
                over.alpha =0;
                over.name=@"wired";
                over.position=CGPointZero;
                over.zPosition=21;
                SKAction *flick = [SKAction fadeAlphaTo:(((double)arc4random() / 0x100000000)/2) duration:(random+0.5)];
                //[over runAction:[SKAction repeatActionForever:flick]];
                [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[flick,[SKAction fadeAlphaTo:0 duration:flick.duration/2]]]]];
                [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:flick.duration],[SKAction rotateByAngle:M_PI/2 duration:0]]]]];
                [wired addChild:over];
            }
            
            CGMutablePathRef myPath2 = CGPathCreateMutable();
            SKShapeNode *ballE = [[SKShapeNode alloc] init];
            CGPathAddArc(myPath2, NULL, 0,0, (wired.size.height/2+5), 0, M_PI*2, YES);
            ballE.path = myPath2;
            ballE.position=wired.position;
            ballE.name=@"wired";
            ballE.lineWidth = 1.0;
            ballE.fillColor = [SKColor whiteColor];
            ballE.strokeColor = [SKColor whiteColor];
            ballE.glowWidth = 0.0;
            ballE.alpha=.0;
            ballE.zPosition=-1;
            [ballE runAction:[SKAction fadeAlphaTo:0.6 duration:.3]];
            [multiWorld addChild:ballE];
            
            SKSpriteNode *wireless = [SKSpriteNode spriteNodeWithImageNamed:@"wireless.png"];
            wireless.position=CGPointMake(0-[self multiPosition].x, 0+[self multiPosition].y);
            wireless.size=kContainerSize();
            wireless.name=@"wireless";
            [multiWorld addChild:wired];
            [multiWorld addChild:wireless];
            
            for (int i=0; i<4; i++) {
                SKSpriteNode *over = [SKSpriteNode spriteNodeWithImageNamed:@"over.png"];
                over.size =wired.size;
                [over runAction:[SKAction rotateByAngle:(M_PI/2)*i duration:0]];
                double random =(((double)arc4random() / 0x100000000)/2);
                over.alpha =0;
                over.name=@"wireless";
                over.position=CGPointZero;
                over.zPosition=21;
                SKAction *flick = [SKAction fadeAlphaTo:(((double)arc4random() / 0x100000000)/2) duration:(random+0.5)];
                //[over runAction:[SKAction repeatActionForever:flick]];
                [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[flick,[SKAction fadeAlphaTo:0 duration:flick.duration/2]]]]];
                [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction waitForDuration:flick.duration],[SKAction rotateByAngle:M_PI/2 duration:0]]]]];
                [wireless addChild:over];
            }
            
            SKShapeNode *ball = [[SKShapeNode alloc] init];
            CGPathAddArc(myPath2, NULL, 0,0, (wired.size.height/2+5), 0, M_PI*2, YES);
            ball.path = myPath2;
            ball.position=wireless.position;
            ball.name=@"wireless";
            ball.lineWidth = 1.0;
            ball.fillColor = [SKColor whiteColor];
            ball.strokeColor = [SKColor whiteColor];
            ball.glowWidth = 0.0;
            ball.alpha=.0;
            ball.zPosition=-1;
            [ball runAction:[SKAction fadeAlphaTo:0.6 duration:.3]];
            [multiWorld addChild:ball];
        
            [multiWorld runAction:[SKAction colorizeWithColor:[UIColor colorWithWhite:1.0 alpha:.4] colorBlendFactor:1.0 duration:0.5]];
            [multiWorld runAction:[SKAction scaleTo:1.0 duration:0.5]completion:^{
                self.zooming=NO;
            }];
            
            SKAction *rotation = [SKAction sequence:@[[SKAction rotateByAngle:(double)(1+((arc4random()% 10))/3) duration:(((double)arc4random() / 0x100000000)+1.)*2.],[SKAction rotateToAngle:(double)(arc4random()/ 0x100000000)*M_2_PI duration:(((double)arc4random() / 0x100000000)+.5)*3.]]];
            [wireless runAction:[SKAction repeatActionForever:rotation]];
            [wired runAction:[SKAction repeatActionForever:rotation.reversedAction]];
            
            multiScreen=NO;
            
            break;
        }
        default:
            break;
    }
}

-(CGPoint)multiPosition{
    return [[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone ? CGPointMake(CGRectGetMidX(self.frame)*1/5, CGRectGetMidY(self.frame)*2/5):CGPointMake(CGRectGetMidX(self.frame)*3/5, CGRectGetMidY(self.frame)/4) ;
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
    //SKNode*multiWorld=[self childNodeWithName:@"multiWorld"];
    //if ([multiWorld.name isEqualToString:@"multiWorld"] && mainScreen) {
      //  [multiWorld removeFromParent];
    //}
}


-(void)loadAchievement{
    
    [self reportAchievementIdentifier:@"manual" percentComplete:1.];
    
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
        UIViewController *vc = self.view.window.rootViewController;
        [vc presentViewController: gameCenterController animated: YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
    
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

-(void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController{
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

-(void)matchmakerViewController:(GKMatchmakerViewController*)viewController didFailWithError:(NSError*)error{
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    if (achievement)
    {
        achievement.percentComplete = percent*100.;
        
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

-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID{
    
}

@end
