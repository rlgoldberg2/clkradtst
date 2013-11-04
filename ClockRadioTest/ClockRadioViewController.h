//
//  ClockRadioViewController.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 10/31/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioStationData.h"
#import "EditStationsViewController.h"

@interface ClockRadioViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, EditStationsDelegate>
@end
