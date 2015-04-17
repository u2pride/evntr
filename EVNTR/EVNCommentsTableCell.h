//
//  EVNCommentsTableCell.h
//  EVNTR
//
//  Created by Alex Ryan on 4/16/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EVNCommentsTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentDateLabel;

@end
