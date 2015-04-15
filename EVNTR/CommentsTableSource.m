//
//  CommentsTableSource.m
//  EVNTR
//
//  Created by Alex Ryan on 4/15/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "CommentsTableSource.h"
#import "EVNParseEventHelper.h"

@interface CommentsTableSource ()

@property (nonatomic, strong) NSArray *commentsData;


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
            
            [self getCommentsForTableWithEvent:event];
        }
    }

    return self;
}

- (void) getCommentsForTableWithEvent:(EventObject *)event {
    
    [EVNParseEventHelper queryForCommentsFromEvent:event completion:^(NSArray *comments) {
        
        NSLog(@"Got Comments");
        _commentsData = comments;
        
        [self.commentsTable reloadData];
        
    }];
    
    
}

#pragma mark - Comments Table View DataSource Methods
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Cellforrowatindexpath");

    
    static NSString *cellIdentifier = @"commentsCell";

    UITableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!commentCell) {
        commentCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    PFObject *comment;
    
    if (indexPath.row == 0) {
        commentCell.textLabel.text = @"Add a Comment";
    } else {
        comment = [self.commentsData objectAtIndex:indexPath.row - 1];
        commentCell.textLabel.text = comment[@"commentText"];
        commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    commentCell.backgroundColor = [UIColor clearColor];
    commentCell.textLabel.textColor = [UIColor whiteColor];
    
    return commentCell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.commentsData.count + 1;
}


#pragma mark - Comments Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        id<EVNCommentsTableProtocol> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(addNewComment)]) {
            [strongDelegate addNewComment];
        }
        
    }
    
    NSLog(@"Did select table cell for comment - %ld", (long)indexPath.row);
    
}

@end
