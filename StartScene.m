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

@end

@implementation StartScene

@synthesize location,maxLife,breakAble,saveArray;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self createPlistForFirstTime];
        [self readNumbersFromFile];
        
        
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

#pragma mark - Touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    
    if ([node.name isEqualToString:@"beginButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        
        [self nodesDisappear];
        MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        gameScene.multiMode = NO;
        gameScene.touchLocation = location;
        gameScene.guardBreak = breakAble;
        gameScene.maxLives = maxLife;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65]];
        
    }else if ([node.name isEqualToString:@"multiButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood3.m4a" waitForCompletion:NO]];
        
        [self nodesDisappear];
        MyScene* gameScene = [[MyScene alloc] initWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        gameScene.multiMode = YES;
        gameScene.touchLocation = location;
        gameScene.guardBreak = breakAble;
        gameScene.maxLives = maxLife;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
        
    }else if ([node.name isEqualToString:@"classicButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        
        [self nodesDisappear];
        ClassicScene* gameScene = [[ClassicScene alloc] initWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        gameScene.multiMode = NO;
        gameScene.touchLocation = location;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
        
    }else if ([node.name isEqualToString:@"classicMButton"]) {
        [self runAction:[SKAction playSoundFileNamed:@"wood3.m4a" waitForCompletion:NO]];
        
        [self nodesDisappear];
        ClassicScene* gameScene = [[ClassicScene alloc] initWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        gameScene.multiMode = YES;
        gameScene.touchLocation = location;
        [self.view presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
        
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
