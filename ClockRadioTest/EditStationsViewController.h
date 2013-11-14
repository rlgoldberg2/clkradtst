//
//  EditStationsViewController.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 10/31/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresetStationData.h"

@protocol EditStationsDelegate;

@interface EditStationsViewController : UIViewController

// the following properties are passed through the segue
@property (nonatomic, strong) PresetStationData *stationToEdit;
@property (nonatomic, strong) NSManagedObjectContext *editingMOC;
@property (nonatomic) BOOL isAdded;
@property (nonatomic, weak) id<EditStationsDelegate> editStationsDelegate;

@end

// on exit, this view controller will call the method below, which executes in the calling view controller.  The end result will be to reorder the array to insert this item into the appropriate place and regenerate the display order

@protocol EditStationsDelegate <NSObject>;
@required
- (void) editStationComplete:(EditStationsViewController *)controller didFinishWithSave:(BOOL)save;

@end
