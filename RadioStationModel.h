//
//  RadioStationModel.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 11/6/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "RadioStationData.h"

@interface RadioStationModel : NSObject

+(AVPlayer *) radioStationPlay: (RadioStationData *)station;
+(void) radioStationPlayPause: (AVPlayer *) player;

@end
