//
//  EVNFullWebViewController.m
//  EVNTR
//
//  Created by Alex Ryan on 6/17/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNFullWebViewController.h"

@interface EVNFullWebViewController ()

@property (nonatomic, strong) UIWebView *termsWebView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation EVNFullWebViewController

#pragma mark - Lifecycle Methods

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.termsWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.termsWebView.scalesPageToFit = YES;
    self.termsWebView.delegate = self;
    
    [self.view addSubview:self.termsWebView];
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.center = self.view.center;
    
    [self.view addSubview:self.loadingIndicator];
    
    [self.loadingIndicator startAnimating];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSURL *evntrTerms = [NSURL URLWithString:@"http://evntr.co/terms"];
    NSURLRequest *request = [NSURLRequest requestWithURL:evntrTerms];
    
    [self.termsWebView loadRequest:request];
    
}


#pragma mark - UIWebView Delegate Methods

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [self.loadingIndicator stopAnimating];
    
    UIAlertController *errorLoading = [UIAlertController alertControllerWithTitle:@"Failed to Load" message:@"Please visit evntr.co/terms to view the terms." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Got It" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    [errorLoading addAction:doneAction];
    
    [self presentViewController:errorLoading animated:YES completion:nil];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.loadingIndicator stopAnimating];

}



@end
