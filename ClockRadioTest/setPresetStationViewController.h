//
//  setPresetStationViewController.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 11/7/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresetStationData.h"

@interface setPresetStationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) PresetStationData *presetStationToChange;
@end
