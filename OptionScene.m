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
@property BOOL dragLock;
@property int intCry;

#define kBackGroundColor [UIColor colorWithWhite:0.92 alpha:1.0];

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
        whiteBrick.position=CGPointMake(100,10);
        whiteBrick.name = @"whiteBrick";
        whiteBrick.zPosition=2.;
        SKSpriteNode *over = [SKSpriteNode spriteNodeWithImageNamed:@"tri2.png"];
        over.size =whiteBrick.size;
        [over runAction:[SKAction rotateByAngle:(M_PI/2)*3 duration:0]];
        double random =(((double)arc4random() / 0x100000000)/2);
        over.alpha =0;
        SKAction *flick = [SKAction fadeAlphaTo:(((double)arc4random() / 0x100000000)) duration:((random+0.5)*4)];
        //[over runAction:[SKAction repeatActionForever:flick]];
        [over runAction:[SKAction repeatActionForever:[SKAction sequence:@[flick,[SKAction fadeAlphaTo:0 duration:flick.duration/2]]]]];
        [whiteBrick addChild:over];
        SKSpriteNode *whiteWhite = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(30, 30)];
        whiteWhite.name = @"whiteBrick";
        [whiteBrick addChild:whiteWhite];

        
        SKSpriteNode *front = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.92 alpha:1.0] size:CGSizeMake(self.frame.size.width, 80)];
        front.position=CGPointMake(0,30);
        front.anchorPoint=CGPointZero;
        front.name = @"back1";
        front.zPosition=1.2;
        [self addChild:front];
        [front addChild:whiteBrick];
        
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



@end
