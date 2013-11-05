//
//  EditStationsViewController.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 10/31/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioStationData.h"

@protocol EditStationsDelegate;

@interface EditStationsViewController : UIViewController

@property (nonatomic, strong) RadioStationData *stationToEdit;
@property (nonatomic, weak) id<EditStationsDelegate> editStationsDelegate;

@end

// on exit, this view controller will call the method below, which executes in the calling view controller.  The end result will be to reorder the array to insert this item into the appropriate place and regenerate the display order

@protocol EditStationsDelegate <NSObject>;
@required
-(void) displayOrderHasChanged: (int) oldDisplayOrder to: (int) newDisplayOrder;
@end
