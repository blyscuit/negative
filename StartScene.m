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

@interface StartScene()

@property CGPoint location;
@property BOOL classic;
@property BOOL loadMusic;

@end

@implementation StartScene

@synthesize location,maxLife,breakAble,saveArray,classic,loadMusic;

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
        SKAction *preloadC5 = [SKAction playSoundFileNamed:@"C5.caf" waitForCompletion:YES];
        
        SKSpriteNode *spinner = [SKSpriteNode spriteNodeWithImageNamed:@"mainLogo.png"];
        spinner.position=CGPointMake(70,400);
        spinner.name = @"spinner";
        spinner.size = CGSizeMake(100, 100);
        spinner.zPosition=-.5;
        [spinner runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI*2 duration:3]]];
        [self addChild:spinner];
        
        SKSpriteNode *cover = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(self.frame.size.width, 90)];
        cover.name = @"cover";
        cover.position = CGPointMake(CGRectGetMidX(self.frame), 395);
        cover.zPosition=-.4;
        cover.alpha=.0;
        [cover runAction:[SKAction group:@[[SKAction moveByX:0 y:-15 duration:.6],[SKAction fadeAlphaTo:.6 duration:.6]]]];
        [self addChild:cover];
        
        SKLabelNode* title = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Light"];
        title.name = @"title";
        title.fontSize = 21;
        title.fontColor = [SKColor blackColor];
        title.text = [NSString stringWithFormat:@"N-egative"];
        title.position = CGPointMake(0,-title.frame.size.height/2);
        [cover addChild:title];
        
        
        SKSpriteNode *beginButton = [SKSpriteNode spriteNodeWithImageNamed:@"PlayerWhite.png"];
        beginButton.size=CGSizeMake(80, 30);
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
        SKSpriteNode *beginLine = [SKSpriteNode spriteNodeWithImageNamed:@"startLine.png"];
        beginLine.size=CGSizeMake(80, 50);//insert picture here?
        beginLine.position = CGPointMake(0,0);
        beginLine.name = @"beginButton";
        beginLine.zPosition = 1.1f;
        [beginButton addChild:beginLine];
        SKLabelNode *startText = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Light"];
        startText.fontSize=15;
        startText.fontColor = [SKColor colorWithWhite:0.92 alpha:1.0];
        startText.text = @"AI";
        startText.position = CGPointMake(25,-10);
        startText.zPosition = 1.1f;
        [beginButton addChild:startText];
        
        SKSpriteNode *multiButton = [SKSpriteNode spriteNodeWithImageNamed:@"PlayerWhite.png"];
        multiButton.size=CGSizeMake(80, 30);//insert picture here?
        [multiButton runAction:[SKAction colorizeWithColor:[UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.7] colorBlendFactor:1. duration:.2]];
        multiButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-50);
        multiButton.name = @"multiButton";
        multiButton.zPosition = 1.0f;
        [self addChild:multiButton];
        SKSpriteNode *multiLine = [SKSpriteNode spriteNodeWithImageNamed:@"startLine.png"];
        multiLine.size=CGSizeMake(80, 50);//insert picture here?
        multiLine.position = CGPointMake(0,0);
        multiLine.name = @"multiButton";
        multiLine.zPosition = 1.1f;
        [multiButton addChild:multiLine];
        SKLabelNode *multiText = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Light"];
         multiText.fontSize=15;
         multiText.fontColor = [SKColor colorWithWhite:0.92 alpha:1.0];
         multiText.text = @"HU";
         multiText.position = CGPointMake(25,-10);
         multiText.zPosition = 1.1f;
         [multiButton addChild:multiText];
        
        SKSpriteNode *classicButton = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:1.0 green:0.95 blue:0.87 alpha:.7] size:CGSizeMake(30, 30)];//insert picture here?
        classicButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-120);
        classicButton.name = @"classicButton";
        classicButton.zPosition = 1.0f;
        [self addChild:classicButton];
        
        SKSpriteNode *classicMButton = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:.7 green:0.7 blue:0.7 alpha:.7] size:CGSizeMake(30, 30)];//insert picture here?
        classicMButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-170);
        classicMButton.name = @"classicMButton";
        classicMButton.zPosition = 1.0f;
        [self addChild:classicMButton];
        
        if (maxLife <=0) {
            maxLife =2;
        }
        
        
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
    
}

-(IBAction)saveData{
    
    [saveArray writeToFile:[self dataFilePath] atomically:YES];
}

-(void)checkClassic{
    if ([[saveArray objectAtIndex:2]intValue]==1) {
        //ANIMATION HERE
        [saveArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:2]];
        [self saveData];
    }if([[saveArray objectAtIndex:2]intValue]==2) {
        classic=YES;
        
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
    SKAction *scale = [SKAction scaleYTo:0.1 duration:0.05];
    SKAction *color = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0.8 duration:0.22];
    SKNode *player = [self childNodeWithName:@"beginButton"];
    SKNode *enemy  = [self childNodeWithName:@"multiButton"];
    [scale setTimingMode:SKActionTimingEaseInEaseOut];
    [color setTimingMode:SKActionTimingEaseInEaseOut];
    
    [player runAction:scale];
    [enemy runAction:scale completion:^{
        [player runAction:[SKAction scaleXTo:0.01 duration:0.15] completion:^{
            [player runAction:[SKAction scaleYTo:1. duration:0.02]];
            [enemy runAction:[SKAction scaleYTo:1. duration:0.02]];
        }];
        [enemy runAction:[SKAction scaleXTo:0.01 duration:0.15]];
    }];
    [player runAction:color];
    [enemy runAction:color completion:^{
        if ([node.name isEqualToString:@"beginButton"]) {
            MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            gameScene.multiMode = NO;
            gameScene.touchLocation = location;
            gameScene.guardBreak = breakAble;
            gameScene.maxLives = maxLife;
            [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65]];
            
        }else if ([node.name isEqualToString:@"multiButton"]) {
            MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            gameScene.multiMode = YES;
            gameScene.touchLocation = location;
            gameScene.guardBreak = breakAble;
            gameScene.maxLives = maxLife;
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
            
        }
    }];
}

-(void)brickDance:(NSInteger)brickNumber withTime:(CFTimeInterval*)currentTime{
    if (!loadMusic) {
        return;
    }
    
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
            
        default:
            return;
            break;
    }
    
    SKAction * dance = [SKAction moveToY:self.frame.size.height duration:1.1];
    dance.timingMode=SKActionTimingEaseOut;
    SKAction * danceOut = [SKAction moveByX:0 y:self.frame.size.height duration:dance.duration];
    danceOut.timingMode=SKActionTimingEaseIn;
    
    double r =(((double)arc4random() / 0x100000000));
    double b =(((double)arc4random() / 0x100000000));
    double g =(((double)arc4random() / 0x100000000));
    
    UIColor * randomColor = [UIColor colorWithCIColor:[CIColor colorWithRed:r green:g blue:b]];
    
    double sizeX =(arc4random()%10)+10;
    SKSpriteNode *whiteBrick = [SKSpriteNode spriteNodeWithColor:randomColor size:CGSizeMake(sizeX, self.frame.size.height)];
    whiteBrick.anchorPoint=CGPointMake(0, 1);
    
    double x =(arc4random()%310);
    NSLog(@"%f",x);
    
    whiteBrick.position=CGPointMake(x,0);
    whiteBrick.name = @"whiteBrick";
    whiteBrick.zPosition=-4;
    [whiteBrick runAction:[SKAction sequence:@[dance,[SKAction waitForDuration:1.9],danceOut,[SKAction removeFromParent]]]];
    [self addChild:whiteBrick];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self brickDance:((arc4random()% 400)) withTime:&currentTime];
}

@end
