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
@property (nonatomic, strong) UILabel *commentLengthCount;

@end

@implementation EVNAddCommentVC

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setupNavigationBar];
    [self setupSubviews];
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.commentTextView becomeFirstResponder];
}


- (void) viewDidDisappear:(BOOL)animated {
    
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.navigationController.navigationBar.translucent = NO;
    
}


- (void) setupNavigationBar {
    
    //Transparent Navigation Bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.alpha = 1;
    
    //Create Submit and Cancel Bar Butttons
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CommentCancel"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelComment)];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CommentSubmit"] style:UIBarButtonItemStylePlain target:self action:@selector(submitComment)];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationItem setRightBarButtonItem:submitButton];
    
    //Customize Submit and Cancel Bar Butttons
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
    
}


- (void) setupSubviews {
    
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
    
    self.commentLengthCount = [[UILabel alloc] initWithFrame:CGRectMake(20, self.commentTextView.frame.size.height + self.commentTextView.frame.origin.y, self.view.frame.size.width - 40, 40)];
    self.commentLengthCount.textColor = [UIColor whiteColor];
    self.commentLengthCount.textAlignment = NSTextAlignmentCenter;
    self.commentLengthCount.font = [UIFont fontWithName:EVNFontLight size:18.0];
    self.commentLengthCount.text = [NSString stringWithFormat:@"%d", MAX_COMMENT_LENGTH];
    self.commentLengthCount.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.placeholderLabel];
    [self.view addSubview:self.commentTextView];
    [self.view addSubview:self.commentLengthCount];
    
}



#pragma mark - User Actions

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
        
        if (self.commentTextView.text.length <= MAX_COMMENT_LENGTH) {
            
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            [self.commentTextView resignFirstResponder];
            
            id<EVNAddCommentProtocol> strongDelegate = self.delegate;
            if ([strongDelegate respondsToSelector:@selector(submitCommentWithText:)]) {
                [strongDelegate submitCommentWithText:self.commentTextView.text];
            }
            
        } else {
            
            UIAlertView *maxCommentLength = [[UIAlertView alloc] initWithTitle:@"Comment Length" message:@"Your comment is too long.  Yeah, we know, it's a weird thing to limit." delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            
            [maxCommentLength show];
            
        }
    }
}


#pragma mark - UITextView Delegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    
    int charactersLeft = MAX_COMMENT_LENGTH - (int) self.commentTextView.text.length;
    
    self.commentLengthCount.text = [NSString stringWithFormat:@"%d", charactersLeft];
    
    if (textView.text.length == 0 && self.placeholderLabel.hidden == YES) {
        self.placeholderLabel.hidden = NO;

    } else if (self.placeholderLabel.hidden == NO && textView.text.length > 0) {
        self.placeholderLabel.hidden = YES;

    }
    
}


@end
