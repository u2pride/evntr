//
//  SearchVC.h
//  EVNTR
//
//  Created by Alex Ryan on 2/23/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchVC : UIViewController <UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, EventDetailProtocol, EVNInviteProtocol>

@end
