//
//  secondViewController.m
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2557/05/19.
//  Copyright (c) 仏暦2557年 betaescape. All rights reserved.
//

#import "secondViewController.h"
#import "OptionScene.h"
#import "OnlineScene.h"
#import "AppDelegate.h"
//#import "MyScene.h"

@implementation secondViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Pause the view (and thus the game) when the app is interrupted or backgrounded
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActive:)  name:UIApplicationDidBecomeActiveNotification  object:nil];
    
    
    
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    OptionScene * scene = [[OptionScene alloc]initWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    // Present the scene.
    [skView presentScene:scene];
    
    
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        // Insert game-specific code here to clean up any game in progress.
        
        
        OnlineScene* gameScene = [[OnlineScene alloc] initWithSize:skView.bounds.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        gameScene.multiMode = NO;
        gameScene.touchLocation = CGPointMake(CGRectGetMidX(skView.frame), CGRectGetMidY(skView.frame));
        gameScene.guardBreak = YES;
        gameScene.maxLives = 2;
        gameScene.invite=YES;
        AppDelegate *delegate =  ( AppDelegate *) [[UIApplication sharedApplication] delegate];
        gameScene.bgMusic=delegate.bgMusic;
        [skView presentScene:gameScene transition:[SKTransition fadeWithColor:[UIColor colorWithWhite:0.92 alpha:0.7] duration:0.65f]];
        
        if (acceptedInvite)
        {
            gameScene.invite=YES;
            GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
            mmvc.matchmakerDelegate = gameScene;
            [self presentViewController:mmvc animated:YES completion:nil];
            
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
            [self presentViewController:mmvc animated:YES completion:nil];
        }
        
    };
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)handleApplicationWillResignActive:(NSNotification*)note
{
    ((SKView*)self.view).paused = YES;
    
    
    /*SKView * skView = (SKView *)self.view;
     SKScene * myScene = [StartScene sceneWithSize:skView.bounds.size];
     if(skView.scene.==myScene){
     NSLog(@"same");
     }*/
}

- (void)handleApplicationDidBecomeActive:(NSNotification*)note
{
    ((SKView*)self.view).paused = NO;
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController {
    
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

-(void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController{
    UIViewController *vc = self.view.window.rootViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}



@end

