//
//  EditProfileVC.m
//  EVNTR
//
//  Created by Alex Ryan on 2/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EditProfileVC.h"
#import <Parse/Parse.h>
#import "EVNUtility.h"

@interface EditProfileVC ()
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *detailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *profilePictureCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *socialTwitterCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *socialFacebookCell;

@property (nonatomic, strong) PFUser *currentUser;


- (IBAction)cancelEditProfile:(id)sender;
- (IBAction)finishedEditProfile:(id)sender;


@end

@implementation EditProfileVC

@synthesize nameCell, detailCell, profilePictureCell, socialFacebookCell, socialTwitterCell, nameTextField, hometownTextField, profileImageView, currentUser;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentUser = [PFUser currentUser];
    
    self.nameTextField.text = self.currentUser[@"username"];
    self.hometownTextField.text = @"Freehome, GA";
    self.profileImageView.image = [UIImage imageNamed:@"PersonDefault"];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    PFFile *profileImageDataFile = self.currentUser[@"profilePicture"];
    [profileImageDataFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            self.profileImageView.image = [EVNUtility maskImage:[UIImage imageWithData:data] withMask:[UIImage imageNamed:@"MaskImage"]];
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0: {
            return 3;
            break;
        }
        case 1: {
            return 2;
            break;
        }
        default:
            return 2;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                return self.nameCell;
                break;
            }
            case 1: {
                return self.detailCell;
                break;
            }
            case 2: {
                return self.profilePictureCell;
                break;
            }
            default:
                NSLog(@"Returned thru default");
                return self.detailCell;
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {
                return self.socialTwitterCell;
                break;
            }
            case 1: {
                return self.socialFacebookCell;
                break;
            }
            default:
                NSLog(@"Returned thru default");
                return self.detailCell;
                break;
        }
        
    } else {
        NSLog(@"Returned thru else statement");
        return self.detailCell;
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

- (IBAction)cancelEditProfile:(id)sender {
    
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"This getting called?");

    id<ProfileEditDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(canceledEditingProfile)]) {
        
        [strongDelegate canceledEditingProfile];
        
    }
    
}

- (IBAction)finishedEditProfile:(id)sender {
    
    //Determine New Values
    currentUser[@"username"] = nameTextField.text;
    
    NSLog(@"what about this?");
    
    
    id<ProfileEditDelegate> strongDelegate = self.delegate;
    
    if ([strongDelegate respondsToSelector:@selector(saveProfileEdits:)]) {
     
        [strongDelegate saveProfileEdits:currentUser];
        
    }
    
    
}
@end
