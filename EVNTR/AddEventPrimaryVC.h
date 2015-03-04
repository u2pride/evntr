//
//  AddEventPrimaryVC.h
//  EVNTR
//
//  Created by Alex Ryan on 3/4/15.
//  Copyright (c) 2015 U2PrideLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVNConstants.h"

@interface AddEventPrimaryVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

// create outlets to event title, event type buttons, and cameraimageview.
// on click of next button,
// check to see if event title > 3 chars
// an event type button is selected (by default its' public)
// self.imageData has data.  so basically create self.imageData = alloc init - whenever you return from picture.  this way you can check if it's null on next button press.
// pass the title, type of event (use EVENT_TYPE_PRIVATE constants), and imageData

//create logic for buttons - default one is on.  click disables others and enables the one.  just change text color from gray to orange.


//eye candy:  custom buttons with click animation




@end
