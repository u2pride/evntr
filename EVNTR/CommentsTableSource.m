//
//  CommentsTableSource.m
//  EVNTR
//
//  Created by Alex Ryan on 4/15/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "CommentsTableSource.h"
#import "NSDate+NVTimeAgo.h"
#import "EVNCommentsTableCell.h"

NSString *const cellIdentifier = @"commentsCell";

@interface CommentsTableSource ()

@property (nonatomic, strong) UIButton *addCommentButton;

@end

@implementation CommentsTableSource

- (instancetype)init {
    
    return [self initWithEvent:nil withTable:nil];
}



- (instancetype)initWithEvent:(EventObject *)event withTable:(UITableView *)table {
    
    self = [super init];
    if (self) {
        if (event) {
            
            _commentsTable = table;
            _commentsTable.delegate = self;
            _commentsTable.dataSource = self;
            _commentsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_commentsTable registerNib:[UINib nibWithNibName:@"EVNCommentsTableCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
            
            [self setupTableHeader];
            [self getCommentsForTableWithEvent:event];
        }
    }

    return self;
}


- (void) setAllowAddingComments:(BOOL)allowAddingComments {
        
    if (allowAddingComments) {
        if (!self.commentsTable.tableHeaderView) {
            [self setupTableHeader];
        }
    } else {
        self.commentsTable.tableHeaderView = nil;
    }
    
    _allowAddingComments = allowAddingComments;
}

- (void) setupTableHeader {
    
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _commentsTable.frame.size.width, 50)];
    tableHeader.backgroundColor = [UIColor clearColor];
    
    self.addCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.addCommentButton setTitle:@"+" forState:UIControlStateNormal];
    [self.addCommentButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
    [self.addCommentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addCommentButton addTarget:self action:@selector(createNewComment) forControlEvents:UIControlEventTouchUpInside];
    self.addCommentButton.backgroundColor = [UIColor whiteColor];
    self.addCommentButton.layer.cornerRadius = 20;
    self.addCommentButton.frame = CGRectMake(self.commentsTable.center.x - 40, 0, 40, 40);
    
    [tableHeader addSubview:self.addCommentButton];
    
    [_commentsTable setTableHeaderView:tableHeader];
    
}


- (void) getCommentsForTableWithEvent:(EventObject *)event {
    
    [event queryForCommentsWithCompletion:^(NSArray *comments) {
        
        _commentsData = [NSMutableArray arrayWithArray:comments];
                
        [self.commentsTable reloadData];
        
    }];
    
}


- (void) createNewComment {
    
    id<EVNCommentsTableProtocol> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(addNewComment)]) {
        [strongDelegate addNewComment];
    }
    
    [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.addCommentButton.transform = CGAffineTransformMakeScale(0.9, 0.9);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.addCommentButton.transform = CGAffineTransformIdentity;
            
        } completion:^(BOOL finished) {
            
        }];
        
    }];
    
}


#pragma mark - Comments Table View DataSource Methods
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"cellForRowAtIndexPath: %ld", (long)indexPath.row);
    
    EVNCommentsTableCell *commentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!commentCell) {
        [tableView registerNib:[UINib nibWithNibName:@"EVNCommentsTableCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        
        commentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    
    PFObject *comment;
        
    comment = [self.commentsData objectAtIndex:indexPath.row];
    commentCell.commentTextLabel.text = comment[@"commentText"];
    commentCell.commentDateLabel.text = [comment.updatedAt formattedAsTimeAgo];
    
    commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    commentCell.backgroundColor = [UIColor clearColor];
    commentCell.textLabel.textColor = [UIColor whiteColor];
    
    return commentCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.commentsData.count;

}


#pragma mark - Comments Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Did select table cell for comment - %ld", (long)indexPath.row);
    
}




@end
