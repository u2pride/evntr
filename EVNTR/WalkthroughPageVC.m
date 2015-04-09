//
//  WalkthroughPageVC.m
//  EVNTR
//
//  Created by Alex Ryan on 4/8/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "WalkthroughPageVC.h"

@interface WalkthroughPageVC ()

@property (nonatomic, strong) NSArray *viewControllerList;

@end

@implementation WalkthroughPageVC

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
    
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    self.dataSource = self;
    
    UIViewController *walkthrough1 = [self.storyboard instantiateViewControllerWithIdentifier:@"Walkthrough1"];
    UIViewController *walkthrough2 = [self.storyboard instantiateViewControllerWithIdentifier:@"Walkthrough2"];
    UIViewController *walkthrough3 = [self.storyboard instantiateViewControllerWithIdentifier:@"Walkthrough3"];
    UIViewController *walkthrough4 = [self.storyboard instantiateViewControllerWithIdentifier:@"Walkthrough4"];
    
    self.viewControllerList = [NSArray arrayWithObjects:walkthrough1, walkthrough2, walkthrough3, walkthrough4, nil];
    
    [self setViewControllers:@[walkthrough1] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
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


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return self.viewControllerList.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {

    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
