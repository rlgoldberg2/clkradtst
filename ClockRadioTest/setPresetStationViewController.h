//
//  setPresetStationViewController.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 11/7/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresetStationData.h"
#import "EditStationsViewController.h"

@interface setPresetStationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, EditStationsDelegate>

@property (strong, nonatomic) PresetStationData *presetStationToChange;
@end
