//
//  CommentsTableSource.h
//  EVNTR
//
//  Created by Alex Ryan on 4/15/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EventObject.h"

@protocol EVNCommentsTableProtocol;

@interface CommentsTableSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *commentsTable;
@property (nonatomic, strong) NSMutableArray *commentsData;
@property (nonatomic) BOOL allowAddingComments;

@property (nonatomic, weak) id <EVNCommentsTableProtocol> delegate;

//Designated Initializer
- (instancetype)initWithEvent:(EventObject *)event withTable:(UITableView *)table;

@end

@protocol EVNCommentsTableProtocol <NSObject>

- (void) addNewComment;

@end
