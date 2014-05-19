//
//  pageViewController.m
//  negative
//
//  Created by Pisit Wetchayanwiwat on BE2557/05/19.
//  Copyright (c) 仏暦2557年 betaescape. All rights reserved.
//

#import "pageViewController.h"
#import "secondViewController.h"
#import "ViewController.h"

@interface pageViewController ()

@property (nonatomic,retain)ViewController *firstViewController;
@property (nonatomic,retain)secondViewController *second;

@end

@implementation pageViewController
@synthesize firstViewController,second;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = self;
    
    [self setViewControllers:@[self.firstViewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    UIViewController *nextViewController = nil;
    
    if (viewController == self.firstViewController) {
        nextViewController = self.second;
    }
    
    return nextViewController;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    UIViewController *prevViewController = nil;
    
    if (viewController == self.second) {
        prevViewController = self.firstViewController;
    }
    
    return prevViewController;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (ViewController *)firstViewController {
    
    if (!firstViewController) {
        UIStoryboard *storyboard = self.storyboard;
        firstViewController = [storyboard instantiateViewControllerWithIdentifier:@"first"];
    }
    
    return firstViewController;
}

- (secondViewController *)second {
    
    if (!second) {
        UIStoryboard *storyboard = self.storyboard;
        second = [storyboard instantiateViewControllerWithIdentifier:@"second"];
    }
    
    return second;
}

@end
