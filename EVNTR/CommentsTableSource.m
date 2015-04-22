//
//  CommentsTableSource.m
//  EVNTR
//
//  Created by Alex Ryan on 4/15/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "CommentsTableSource.h"
#import "EVNParseEventHelper.h"
#import "NSDate+NVTimeAgo.h"
#import "EVNCommentsTableCell.h"

NSString *const cellIdentifier = @"commentsCell";

@interface CommentsTableSource ()



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
    
    UIButton *addCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addCommentButton setTitle:@"+" forState:UIControlStateNormal];
    [addCommentButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:20]];
    [addCommentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addCommentButton addTarget:self action:@selector(createNewComment) forControlEvents:UIControlEventTouchUpInside];
    addCommentButton.backgroundColor = [UIColor whiteColor];
    addCommentButton.layer.cornerRadius = 20;
    addCommentButton.center = tableHeader.center;
    
    [tableHeader addSubview:addCommentButton];
    
    [_commentsTable setTableHeaderView:tableHeader];
    
}

- (void) getCommentsForTableWithEvent:(EventObject *)event {
    
    [EVNParseEventHelper queryForCommentsFromEvent:event completion:^(NSArray *comments) {
        
        NSLog(@"Got Comments");
        _commentsData = [NSMutableArray arrayWithArray:comments];
        
        [self.commentsTable reloadData];
        
    }];
    
    
}


- (void) createNewComment {
    
    id<EVNCommentsTableProtocol> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(addNewComment)]) {
        [strongDelegate addNewComment];
    }
    
}


#pragma mark - Comments Table View DataSource Methods
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EVNCommentsTableCell *commentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!commentCell) {
        [tableView registerNib:[UINib nibWithNibName:@"EVNCommentsTableCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        
        commentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    
    if (self.commentsData.count == 0) {
        commentCell.commentTextLabel.text = @"No comments yet for this event...";
        commentCell.commentDateLabel.text = @"";
    } else {
        PFObject *comment;
        
        comment = [self.commentsData objectAtIndex:indexPath.row];
        commentCell.commentTextLabel.text = comment[@"commentText"];
        commentCell.commentDateLabel.text = [comment.updatedAt formattedAsTimeAgo];
    }
    
    commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    commentCell.backgroundColor = [UIColor clearColor];
    commentCell.textLabel.textColor = [UIColor whiteColor];
    
    return commentCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.commentsData.count == 0) {
        return 1;
    } else {
        return self.commentsData.count;
    }
}


#pragma mark - Comments Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSLog(@"Did select table cell for comment - %ld", (long)indexPath.row);
    
}




@end
