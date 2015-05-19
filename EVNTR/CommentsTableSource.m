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
            
            _allowAddingComments = NO;
            _commentsTable = table;
            _commentsTable.delegate = self;
            _commentsTable.dataSource = self;
            _commentsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_commentsTable registerNib:[UINib nibWithNibName:@"EVNCommentsTableCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
            
            [self getCommentsForTableWithEvent:event];
        }
    }

    return self;
}


- (void) setAllowAddingComments:(BOOL)allowAddingComments {
    
    NSLog(@"allowAddingComments");
    if (allowAddingComments) {
        NSLog(@"allowAddingComments2");

        if (!self.commentsTable.tableHeaderView) {
            NSLog(@"allowAddingComments3");

            [self setupTableHeader];
        }
    } else {
        self.commentsTable.tableHeaderView = nil;
    }
    
    _allowAddingComments = allowAddingComments;
}

- (void) setupTableHeader {
    
    NSLog(@"allowAddingComments4");

    
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _commentsTable.frame.size.width, 50)];
    tableHeader.backgroundColor = [UIColor clearColor];
    
    self.addCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.addCommentButton setTitle:@"+" forState:UIControlStateNormal];
    [self.addCommentButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
    [self.addCommentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addCommentButton addTarget:self action:@selector(createNewComment) forControlEvents:UIControlEventTouchUpInside];
    self.addCommentButton.backgroundColor = [UIColor whiteColor];
    self.addCommentButton.layer.cornerRadius = 20;
    //self.addCommentButton.bounds = CGRectMake(self.commentsTable.center.x, 0, 40, 40);
    //self.addCommentButton.frame = CGRectMake(self.commentsTable.center.x, 0, 40, 40);
    self.addCommentButton.center = self.commentsTable.superview.center;
    self.addCommentButton.frame = CGRectMake(self.addCommentButton.frame.origin.x - 10, 0, 40, 40);
    
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
    
    //[commentCell.commentTextLabel sizeToFit];
    
    PFObject *comment = [self.commentsData objectAtIndex:indexPath.row];
    EVNUser *commentParent = (EVNUser *) [comment objectForKey:@"commentParent"];
    
    NSString *usernameComponent = [commentParent.username stringByAppendingString:@": "];
    NSString *commentString = comment[@"commentText"];
    
    
    UIFont *usernameFont = [UIFont fontWithName:@"Lato-Light" size:10];
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor orangeColor], NSForegroundColorAttributeName, usernameFont, NSFontAttributeName, nil];
    
    UIFont *commentFont = [UIFont fontWithName:@"Lato-Light" size:14];
    NSDictionary *attributesDictionaryAdd = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, commentFont, NSFontAttributeName, nil];
    
    NSMutableAttributedString *commentAttributedString = [[NSMutableAttributedString alloc] initWithString:usernameComponent attributes:attributesDictionary];
    NSMutableAttributedString *commentAttributedStringTwo = [[NSMutableAttributedString alloc] initWithString:commentString attributes:attributesDictionaryAdd];
    
    [commentAttributedString appendAttributedString:commentAttributedStringTwo];
    

    NSLog(@"Comment: %@ CommentParent: %@ Username Component: %@ CommentString: %@", comment, commentParent, usernameComponent, commentString);

    commentCell.commentTextLabel.attributedText = commentAttributedString;
    commentCell.commentDateLabel.text = [comment.updatedAt formattedAsTimeAgo];
    commentCell.commentDateLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    commentCell.backgroundColor = [UIColor clearColor];
    //commentCell.textLabel.textColor = [UIColor whiteColor];
    
    commentCell.backgroundColor = [[UIColor alloc] initWithRed:arc4random()%256/256.0 green:arc4random()%256/256.0 blue:arc4random()%256/256.0 alpha:1.0];

    
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
