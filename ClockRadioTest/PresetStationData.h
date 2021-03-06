//
//  RadioStationData.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 11/9/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PresetStationData : NSManagedObject

@property (nonatomic, retain) NSNumber * isEditable;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSNumber * presetStationNumber;
@property (nonatomic, retain) NSString * stationIcon;
@property (nonatomic, retain) NSString * stationName;
@property (nonatomic, retain) NSString * stationURL;

@end
