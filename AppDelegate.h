//
//  AppDelegate.h
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2556/12/03.
//  Copyright (c) 仏暦2556年 betaescape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    ViewController *viewController;
}

@property (strong, nonatomic) UIWindow *window;

@property BOOL bgMusic;

@end
