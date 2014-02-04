//
//  OptionScene.m
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2557/01/24.
//  Copyright (c) 仏暦2557年 betaescape. All rights reserved.
//

#import "OptionScene.h"
#import "StartScene.h"

@interface OptionScene()
@property CGPoint location;
@property SKLabelNode *live;

@end

@implementation OptionScene
@synthesize location,maxLives,live,shield,saveArray;


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        [self readNumbersFromFile];
        
        self.backgroundColor = [SKColor colorWithWhite:0.92 alpha:1.0];
        
        
        SKSpriteNode *redBrick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0] size:CGSizeMake(40, 40)];
        redBrick.position=CGPointMake(CGRectGetMidX(self.frame)-100,CGRectGetMidY(self.frame));
        redBrick.name = @"redBrick";
        [self addChild:redBrick];
        
        SKSpriteNode *blueBrick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.5 green:0.5 blue:1.0 alpha:1.0] size:CGSizeMake(40, 40)];
        blueBrick.position=CGPointMake(CGRectGetMidX(self.frame)+100,CGRectGetMidY(self.frame));
        blueBrick.name = @"blueBrick";
        [self addChild:blueBrick];
        
        live = [SKLabelNode labelNodeWithFontNamed:@"MissionGothic-Light"];
        live.name = @"live";
        live.fontSize = 15;
        live.fontColor = [SKColor grayColor];
        live.text = [NSString stringWithFormat:@" "];
        live.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:live];
        
        SKSpriteNode *greenBrick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:1.0] size:CGSizeMake(40, 40)];
        greenBrick.position=CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-100);
        greenBrick.name = @"greenBrick";
        SKAction *gray;
        if (!shield) {
            gray = [SKAction colorizeWithColor:[UIColor grayColor] colorBlendFactor:1.0 duration:0.1];
        }else{            gray = [SKAction colorizeWithColor:[UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:1.0] colorBlendFactor:1.0 duration:0.1];
        }
        [greenBrick runAction:gray];
        [self addChild:greenBrick];
        
        SKSpriteNode *greenBrick2 = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.9 green:.9 blue:0.9 alpha:1.0] size:CGSizeMake(39, 39)];
        greenBrick2.position=CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-100);
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
        
        SKSpriteNode *whiteBrick = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0] size:CGSizeMake(20, 20)];
        whiteBrick.position=CGPointMake(100,40);
        whiteBrick.name = @"whiteBrick";
        [self addChild:whiteBrick];
        
        SKSpriteNode *bird = [SKSpriteNode spriteNodeWithImageNamed:@"logo-01.png"];
        bird.size = CGSizeMake(60, 60);
        bird.name=@"bird";
        bird.position=CGPointMake(400, 40);
        bird.alpha=.0;
        [self addChild:bird];
        
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
    
    
    if ([node.name isEqualToString:@"redBrick"]) {
        //[self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        if(maxLives>1)
            maxLives--;
        //live.text = [NSString stringWithFormat:@"%i",maxLives];
        
    }else if([node.name isEqualToString:@"blueBrick"]) {
        //[self runAction:[SKAction playSoundFileNamed:@"wood1.m4a" waitForCompletion:NO]];
        maxLives++;
        //live.text = [NSString stringWithFormat:@"%i",maxLives];
    }else if ([node.name isEqualToString:@"whiteBrick"]){
        SKAction *in = [SKAction group:@[[SKAction fadeAlphaTo:1. duration:0.4],[SKAction moveToX:CGRectGetMidX(self.frame)+100 duration:.3]]];
        SKAction *out = [SKAction group:@[[SKAction fadeAlphaTo:0. duration:.3],[SKAction moveToX:-100 duration:0.4]]];
        in.timingMode = SKActionTimingEaseInEaseOut;
        out.timingMode = SKActionTimingEaseInEaseOut;
        SKNode *bird = [self childNodeWithName:@"bird"];
        [bird runAction:in];
        [node runAction:out];
        
    }else if ([node.name isEqualToString:@"greenBrick"]){
        SKAction *gray;
            shield=NO;
            gray = [SKAction colorizeWithColor:[UIColor grayColor] colorBlendFactor:1.0 duration:0.05];
        [node runAction:gray];
        SKNode *white = [self childNodeWithName:@"greenBrick2"];
        SKAction *zoom= [SKAction scaleTo:1.0 duration:0.25];
        [zoom setTimingMode:SKActionTimingEaseInEaseOut];
        [white runAction:zoom];
    }else if ([node.name isEqualToString:@"greenBrick2"]){
        SKAction *gray;
        shield=YES;
        SKNode *white = [self childNodeWithName:@"greenBrick"];
        SKAction *zoom= [SKAction scaleTo:0.0 duration:0.25];
        gray = [SKAction colorizeWithColor:[UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:1.0] colorBlendFactor:1.0 duration:0.05];
        [zoom setTimingMode:SKActionTimingEaseInEaseOut];
        [white runAction:gray];
        [node runAction:zoom];
    }else if ([node.name isEqualToString:@"bird"]){
        [self runAction:[SKAction playSoundFileNamed:@"birdcry.m4a" waitForCompletion:NO]];
        SKAction *jump = [SKAction sequence:@[[SKAction moveByX:0 y:20 duration:0.15],[SKAction moveByX:0 y:-20 duration:.15]]];
        jump.timingMode = SKActionTimingEaseInEaseOut;
        [node runAction:[SKAction repeatAction:jump count:2]];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint dragLocation = [touch locationInNode:self];
    
    if (location.x-dragLocation.x>150){
        
        [saveArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInteger:maxLives]];
        [saveArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool:shield]];
        [self saveData];
        
        StartScene *startS = [[StartScene alloc]initWithSize:self.size];
        startS.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:startS transition:[SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.8]];
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



@end
