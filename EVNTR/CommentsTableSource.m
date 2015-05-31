//
//  CommentsTableSource.m
//  EVNTR
//
//  Created by Alex Ryan on 4/15/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "CommentsTableSource.h"
#import "EVNCommentsTableCell.h"
#import "NSDate+NVTimeAgo.h"

static NSString *const cellIdentifier = @"commentsCell";

@interface CommentsTableSource ()

@property (nonatomic, strong) UIButton *addCommentButton;

@end

@implementation CommentsTableSource

#pragma mark - Initialization Methods

- (instancetype)init {
    return [self initWithEvent:nil withTable:nil];
}

- (instancetype) initWithEvent:(EventObject *)event withTable:(UITableView *)table {
    
    self = [super init];
    if (self) {
        if (event) {
            _allowAddingComments = NO;
            _commentsData = [[NSMutableArray alloc] init];
            _commentsTable = table;
            _commentsTable.delegate = self;
            _commentsTable.dataSource = self;
            _commentsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_commentsTable registerNib:[UINib nibWithNibName:@"EVNCommentsTableCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
            _commentsTable.estimatedRowHeight = 100.0;
            _commentsTable.rowHeight = UITableViewAutomaticDimension;
            
            [self getCommentsForTableWithEvent:event];
        }
    }
    
    return self;
}


#pragma mark - Custom Setters

- (void) setAllowAddingComments:(BOOL)allowAddingComments {
    
    if (allowAddingComments) {
        if (!self.commentsTable.tableHeaderView) {
            [self showAddCommentButtonHeader];
        }
    } else {
        self.commentsTable.tableHeaderView = nil;
    }
    
    _allowAddingComments = allowAddingComments;
}


#pragma mark - Helper Methods

- (void) showAddCommentButtonHeader {
    
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _commentsTable.frame.size.width, 50)];
    tableHeader.backgroundColor = [UIColor clearColor];
    
    self.addCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.addCommentButton setTitle:@"+" forState:UIControlStateNormal];
    [self.addCommentButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
    [self.addCommentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addCommentButton addTarget:self action:@selector(createNewComment) forControlEvents:UIControlEventTouchUpInside];
    self.addCommentButton.backgroundColor = [UIColor whiteColor];
    self.addCommentButton.layer.cornerRadius = 20;
    self.addCommentButton.center = self.commentsTable.superview.center;
    self.addCommentButton.frame = CGRectMake(self.addCommentButton.frame.origin.x - 10, 0, 40, 40);
    
    [tableHeader addSubview:self.addCommentButton];
    
    [_commentsTable setTableHeaderView:tableHeader];
    
}


- (void) getCommentsForTableWithEvent:(EventObject *)event {
    
    [event queryForCommentsWithCompletion:^(NSArray *comments) {
        
        if (comments) {
            _commentsData = [NSMutableArray arrayWithArray:comments];
        }
        
        [self.commentsTable reloadData];
    }];
    
}


- (NSMutableAttributedString *) buildAttributedCommentWithText:(NSString *)commentText andUsername:(NSString *)usernameText {
    
    UIFont *usernameFont = [UIFont fontWithName:@"Lato-Light" size:10];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor], NSForegroundColorAttributeName, usernameFont, NSFontAttributeName, nil];
    
    UIFont *commentFont = [UIFont fontWithName:@"Lato-Light" size:14];
    NSDictionary *attributesDictionaryAdd = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, commentFont, NSFontAttributeName, nil];
    
    NSMutableAttributedString *commentAttributedString = [[NSMutableAttributedString alloc] initWithString:usernameText attributes:attributesDictionary];
    NSMutableAttributedString *commentAttributedStringTwo = [[NSMutableAttributedString alloc] initWithString:commentText attributes:attributesDictionaryAdd];
    
    [commentAttributedString appendAttributedString:commentAttributedStringTwo];

    return commentAttributedString;
    
}

#pragma mark - User Actions

- (void) createNewComment {
    
    id<EVNCommentsTableProtocol> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(addNewComment)]) {
        [strongDelegate addNewComment];
    }
    
    //Button Press Feedback
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.addCommentButton.transform = CGAffineTransformMakeScale(0.9, 0.9);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.addCommentButton.transform = CGAffineTransformIdentity;
            
        } completion:nil];
        
    }];
    
}


#pragma mark - Table View DataSource Methods

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    EVNCommentsTableCell *commentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!commentCell) {
        commentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    PFObject *comment = [self.commentsData objectAtIndex:indexPath.row];
    EVNUser *commentParent = (EVNUser *) [comment objectForKey:@"commentParent"];
    
    NSString *commentString = comment[@"commentText"];
    NSString *usernameComponent = [commentParent.username stringByAppendingString:@": "];
    
    commentCell.commentTextLabel.attributedText = [self buildAttributedCommentWithText:commentString andUsername:usernameComponent];

    commentCell.commentDateLabel.text = [comment.updatedAt formattedAsTimeAgo];
    commentCell.commentDateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    commentCell.backgroundColor = [UIColor clearColor];
    commentCell.selectionStyle = UITableViewCellSelectionStyleNone;

    return commentCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.commentsData.count;

}



@end
