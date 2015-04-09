//
//  WalkthroughVC.m
//  EVNTR
//
//  Created by Alex Ryan on 4/9/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "WalkthroughVC.h"

@interface WalkthroughVC ()

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *viewControllerList;

@end

@implementation WalkthroughVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *backgroundImageForWalkthrough = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cityBackground"]];
    backgroundImageForWalkthrough.frame = self.view.frame;
    backgroundImageForWalkthrough.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:backgroundImageForWalkthrough];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WalkthroughPageViewController"];
    
    //self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    UIViewController *walkthrough1 = [self.storyboard instantiateViewControllerWithIdentifier:@"Walkthrough1"];
    UIViewController *walkthrough2 = [self.storyboard instantiateViewControllerWithIdentifier:@"Walkthrough2"];
    UIViewController *walkthrough3 = [self.storyboard instantiateViewControllerWithIdentifier:@"Walkthrough3"];
    UIViewController *walkthrough4 = [self.storyboard instantiateViewControllerWithIdentifier:@"Walkthrough4"];
    
    self.viewControllerList = [NSArray arrayWithObjects:walkthrough1, walkthrough2, walkthrough3, walkthrough4, nil];
    
    [self.pageViewController setViewControllers:@[walkthrough1] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    
    if (viewController == self.viewControllerList[0]) {
        return nil;
    } else if (viewController == self.viewControllerList[1]) {
        return self.viewControllerList[0];
    } else if (viewController == self.viewControllerList[2]) {
        return self.viewControllerList[1];
    } else if (viewController == self.viewControllerList[3]) {
        return self.viewControllerList[2];
    } else {
        return nil;
    }
    
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if (viewController == self.viewControllerList[0]) {
        return self.viewControllerList[1];
    } else if (viewController == self.viewControllerList[1]) {
        return self.viewControllerList[2];
    } else if (viewController == self.viewControllerList[2]) {
        return self.viewControllerList[3];
    } else if (viewController == self.viewControllerList[3]) {
        return nil;
    } else {
        return nil;
    }
    
}


- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSLog(@"HERE TOO");
    
}

- (void) pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    NSLog(@"CALLED");
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    NSLog(@"THIS");
    return [self.viewControllerList count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    NSLog(@"ONCE");
    return 0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
