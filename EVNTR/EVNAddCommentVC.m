//
//  EVNAddCommentVC.m
//  EVNTR
//
//  Created by Alex Ryan on 4/15/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNAddCommentVC.h"
#import "EVNConstants.h"

@interface EVNAddCommentVC ()

@property (nonatomic, strong) UITextView *commentTextView;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation EVNAddCommentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    //self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    
    //TODO PUSH THIS VC ONTO A NAVIGATION CONTROLLER
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 1;
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CommentCancel"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelComment)];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CommentSubmit"] style:UIBarButtonItemStylePlain target:self action:@selector(submitComment)];

    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationItem setRightBarButtonItem:submitButton];
    
    //Bar Button Item Text Attributes
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIFont fontWithName:EVNFontLight size:16.0], NSFontAttributeName,
                                                                   [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                   nil]
                                                         forState:UIControlStateNormal];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:EVNFontLight size:16.0], NSFontAttributeName,
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    nil]
                                                          forState:UIControlStateNormal];
    
    CGSize size = [@"What's" sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:EVNFontLight size:21.0]}];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 90, self.view.frame.size.width - 40, ceilf(size.height))];
    self.placeholderLabel.textColor = [UIColor colorWithWhite:0.9 alpha:0.7];
    self.placeholderLabel.font = [UIFont fontWithName:EVNFontLight size:21.0];
    self.placeholderLabel.text = @"Add to the conversation...";
    self.placeholderLabel.backgroundColor = [UIColor clearColor];

    
    self.commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 80, self.view.frame.size.width - 40, 200)];
    self.commentTextView.textColor = [UIColor whiteColor];
    self.commentTextView.font = [UIFont fontWithName:EVNFontLight size:21.0];
    self.commentTextView.text = @"";
    self.commentTextView.delegate = self;
    self.commentTextView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.placeholderLabel];
    [self.view addSubview:self.commentTextView];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.commentTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) cancelComment {
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    [self.commentTextView resignFirstResponder];
    
    id<EVNAddCommentProtocol> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(cancelComment)]) {
        [strongDelegate cancelComment];
    }
    
}

- (void) submitComment {
    
    if (self.commentTextView.text.length > 0) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [self.commentTextView resignFirstResponder];
        
        id<EVNAddCommentProtocol> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(submitCommentWithText:)]) {
            [strongDelegate submitCommentWithText:self.commentTextView.text];
        }
        
    }
    
}


#pragma mark - TextView Delegate 

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView.text.length == 0 && self.placeholderLabel.hidden == YES) {
        self.placeholderLabel.hidden = NO;

    } else if (self.placeholderLabel.hidden == NO && textView.text.length > 0) {
        self.placeholderLabel.hidden = YES;

    }
    
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
