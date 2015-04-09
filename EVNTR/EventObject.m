//
//  EventObject.m
//  EVNTR
//
//  Created by Alex Ryan on 4/3/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EventObject.h"
#import "EVNConstants.h"
#import <Parse/PFObject+Subclass.h>

@implementation EventObject

@dynamic dateOfEvent, nameOfLocation, title, descriptionOfEvent, typeOfEvent, invitedUsers, attenders, locationOfEvent, coverPhoto, eventImages, parent;

+ (void) load {
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Events";
}

- (NSString *) eventDateShortStyle {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    return [dateFormatter stringFromDate:self.dateOfEvent];
    
}


- (NSString *) eventTimeShortStye {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    
    return [dateFormatter stringFromDate:self.dateOfEvent];
    
}

- (void) coverImage:(void (^)(UIImage *))completionBlock {
    
    [self.coverPhoto getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        
        UIImage *cover = [UIImage imageWithData:imageData];
        
        completionBlock(cover);
        
    }];
    
}

- (NSString *) eventTypeForHomeView {
    
    int eventType = [self.typeOfEvent intValue];
    
    switch (eventType) {
        case PUBLIC_EVENT_TYPE: {
            return @"Pu";
            break;
        }
        case PRIVATE_EVENT_TYPE: {
            return @"Pr";
            break;
        }
        case PUBLIC_APPROVED_EVENT_TYPE: {
            return @"Pa";
            break;
        }
        default:
            return @"Unknown";
            break;
    }
    
}

- (void) totalNumberOfAttendersInBackground:(void (^)(int count))completionBlock {
    
    PFRelation *relation = self.attenders;
    PFQuery *query = [relation query];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        completionBlock(number);
        
    }];

}


//Users Can Only Post Photos To An Event Starting An Hour Before the Event.
//Creators of the Event Can Post Photos At All Times
- (BOOL) allowUserToAddPhotosAtThisTime {
    
    if ([self.objectId isEqual:[PFUser currentUser].objectId]) {
        
        NSLog(@"Same Creator and User");
        
        return YES;
        
    } else {
        
        NSDate *currentDate = [NSDate date];
        
        double numMinutesBefore = 60;
        
        double numSeconds = numMinutesBefore * 60;
        
        NSDate *hourBeforeDate = [currentDate dateByAddingTimeInterval:numSeconds];
        
        NSComparisonResult dateCompare = [hourBeforeDate compare:self.dateOfEvent];
        
        NSLog(@"hourBeforeDate: %@ and Event Date: %@", hourBeforeDate, self.dateOfEvent);
        
        
        switch (dateCompare) {
            case NSOrderedSame: {
                NSLog(@"SAME");
                
                return YES;
                
                break;
            }
            case NSOrderedAscending: {
                NSLog(@"ASCENDING - Restrict Adding");
                
                return NO;
                
                break;
            }
            case NSOrderedDescending: {
                NSLog(@"ASCENDING - Allow Adding");
                
                return YES;
                
                break;
            }
            default: {
                
                return NO;
                
                break;
            }
        }
        
    }
    
}



@end
