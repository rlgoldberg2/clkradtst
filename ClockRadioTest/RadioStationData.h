//
//  RadioStationData.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 10/31/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RadioStationData : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * isEditable;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;

@end
