//
//  EVNEvent.m
//  EVNTR
//
//  Created by Alex Ryan on 3/23/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import "EVNEvent.h"
#import "EVNConstants.h"

@implementation EVNEvent


- (id)initWithID:(NSString *)ID
            name:(NSString *)title
            type:(NSNumber *)type
         creator:(PFUser *)creator
      coverImage:(PFFile *)image
     description:(NSString *)description
            date:(NSDate *)date
locationGeoPoint:(PFGeoPoint *)locationGeoPoint
    locationName:(NSString *)locationName
          photos:(NSArray *)photos
    invitedUsers:(PFRelation *)invitedUsers
       attendees:(PFRelation *)attendees
    backingObject:(PFObject *)object {
    
    
    self = [super init];
    if (self) {
        _eventID = ID;
        _eventTitle = title;
        _eventType = type;
        _eventCreator = creator;
        _eventCoverPhoto = image;
        _eventDescription = description;
        _eventDate = date;
        _eventLocationGeoPoint = locationGeoPoint;
        _eventLocationName = locationName;
        _eventPhotos = photos;
        _eventInvitedUsers = invitedUsers;
        _eventAttenders = attendees;
        _backingObject = object;
    }
    
    return self;
    
    
}


- (void) totalNumberOfAttendersInBackground:(void (^)(int count))completionBlock {
    
    PFRelation *relation = self.eventAttenders;
    PFQuery *query = [relation query];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        completionBlock(number);
        
    }];
    
    
}


- (NSString *) eventDateShortStyle {
   
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    return [dateFormatter stringFromDate:self.eventDate];
    
}


- (NSString *) eventTimeShortStye {
 
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    
    return [dateFormatter stringFromDate:self.eventDate];
    
}


- (NSString *) eventTypeForHomeView {
    
    int typeOfEvent = [self.eventType intValue];

    switch (typeOfEvent) {
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
            return @"Un";
            break;
    }
    
}

//Users Can Only Post Photos To An Event Starting An Hour Before the Event.
//Creators of the Event Can Post Photos At All Times
- (BOOL) allowUserToAddPhotosAtThisTime {
    
    if ([self.eventCreator.objectId isEqual:[PFUser currentUser].objectId]) {
        
        NSLog(@"Same Creator and User");
        
        return YES;
        
    } else {
        
        NSDate *currentDate = [NSDate date];
        
        double numMinutesBefore = 60;
        
        double numSeconds = numMinutesBefore * 60;
        
        NSDate *hourBeforeDate = [currentDate dateByAddingTimeInterval:numSeconds];
        
        NSComparisonResult dateCompare = [hourBeforeDate compare:self.eventDate];
        
        NSLog(@"hourBeforeDate: %@ and Event Date: %@", hourBeforeDate, self.eventDate);
        
        
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



- (NSString *) numberOfPhotos {
    
    return [NSString stringWithFormat:@"%lu", (unsigned long)self.eventPhotos.count];
    
}

@end
