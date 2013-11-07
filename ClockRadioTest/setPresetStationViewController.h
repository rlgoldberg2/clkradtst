//
//  setPresetStationViewController.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 11/7/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface setPresetStationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSNumber *presetStationNumberToSet;
@end
