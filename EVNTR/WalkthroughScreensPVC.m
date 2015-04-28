//
//  WalkthroughScreensPVC.m
//  EVNTR
//
//  Created by Alex Ryan on 4/27/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "WalkthroughScreensPVC.h"

@interface WalkthroughScreensPVC ()

@property (nonatomic, strong) NSMutableArray *walkthroughImages;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic) int currentIndex;

@end

@implementation WalkthroughScreensPVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"WalkthroughBackground"]];
    
    //Walkthrough Model
    self.walkthroughImages = [[NSMutableArray alloc] init];
    [self.walkthroughImages addObject:[UIImage imageNamed:@"WalkthroughOne"]];
    [self.walkthroughImages addObject:[UIImage imageNamed:@"WalkthroughTwo"]];
    [self.walkthroughImages addObject:[UIImage imageNamed:@"WalkthroughThree"]];
    [self.walkthroughImages addObject:[UIImage imageNamed:@"WalkthroughFour"]];
    [self.walkthroughImages addObject:[UIImage imageNamed:@"WalkthroughFive"]];
    [self.walkthroughImages addObject:[UIImage imageNamed:@"WalkthroughSix"]];
    [self.walkthroughImages addObject:[UIImage imageNamed:@"WalkthroughSeven"]];
    [self.walkthroughImages addObject:[UIImage imageNamed:@"WalkthroughEight"]];

    self.delegate = self;
    self.dataSource = self;
    
    self.currentIndex = 0;
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(self.view.frame.size.width - 120, self.view.frame.size.height - 125, 200, 20);
    self.pageControl.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = self.walkthroughImages.count;
    
    [self.view addSubview:self.pageControl];
    
    UIViewController *firstVC = [self viewControllerForWalkthroughIndex:0];
    [self setViewControllers:@[firstVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIPageViewController Data Source Methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    int indexForVC = (int) viewController.view.tag;
    
    if (indexForVC == 0 || indexForVC > 7) {
        return nil;
    } else {
        return [self viewControllerForWalkthroughIndex: (int) viewController.view.tag - 1];
    }
    
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    int indexForVC = (int) viewController.view.tag;
    
    if (indexForVC < 0 || indexForVC > 6) {
        return nil;
    } else {
        return [self viewControllerForWalkthroughIndex: (int) viewController.view.tag + 1];
    }
    
}

- (UIViewController *) viewControllerForWalkthroughIndex:(int) index {
    
    UIViewController *walkthroughVC = [[UIViewController alloc] init];
    walkthroughVC.view.frame = self.view.frame;
    walkthroughVC.view.tag = index;
    
    UIImageView *imageScreen = [[UIImageView alloc] init];
    imageScreen.image = [self.walkthroughImages objectAtIndex:index];
    imageScreen.frame = walkthroughVC.view.frame;
    
    [walkthroughVC.view addSubview:imageScreen];
    
    if (index == 7) {
        
        UIView *transparentClickView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 2, self.view.frame.size.width, self.view.frame.size.height)];
        transparentClickView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endWalkthrough)];
        tapgr.delegate = self;
        
        [transparentClickView addGestureRecognizer:tapgr];
        [walkthroughVC.view addSubview:transparentClickView];
    }
    
    return walkthroughVC;
}

- (void) endWalkthrough {
    
    NSLog(@"End the Walkthrough");
    
    [self performSegueWithIdentifier:@"WalkthroughToApp" sender:self];
    
}


- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSLog(@"HERE TOO");
    
    if (completed) {
        self.pageControl.currentPage = self.currentIndex;
    }
    
}

- (void) pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    NSLog(@"CALLED");

    UIViewController *vc = [pendingViewControllers firstObject];
    self.currentIndex = (int) vc.view.tag;

}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    NSLog(@"THIS");
    return [self.walkthroughImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    NSLog(@"ONCE");
    return 0;
}

@end
