//
//  RadioStationModel.h
//  ClockRadioTest
//
//  Created by Richard Goldberg on 11/6/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "PresetStationData.h"

@interface RadioStationModel : NSObject

+(AVPlayer *) radioStationPlay: (PresetStationData *)station;
+(void) radioStationPause: (AVPlayer *) player;
+(void) radioStationResume: (AVPlayer *) player;

@end
