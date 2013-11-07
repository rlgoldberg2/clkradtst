//
//  RadioStationModel.m
//  ClockRadioTest
//
//  Created by Richard Goldberg on 11/6/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import "RadioStationModel.h"

@interface RadioStationModel ()
//@property (strong, nonatomic) AVPlayer *radioStationPlayer;

@end

@implementation RadioStationModel

BOOL isPlaying=NO;

+(AVPlayer *) radioStationPlay:(PresetStationData *)station
{
    NSURL *radioStationURL = [NSURL URLWithString:station.stationURL];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:radioStationURL];
    
//    [playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
//    [playerItem addObserver:self forKeyPath:@"timedMetadata" options:0 context:nil];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

    // Allow to play in background
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // Receive remote events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    

    
    [player play];
    isPlaying = YES;
    
    return player;
}

+(void) radioStationPlayPause:(AVPlayer *)player
{
    if (isPlaying) {
        [player pause];
        isPlaying = NO;
    }
    else {
        [player play];
        isPlaying = YES;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    NSLog(@"hello");
    /*    NSLog(@"path: %@", keyPath);
    NSLog(@"tracks:%@ ", player.currentItem.tracks);
    
    for (AVMetadataItem *metaItem in player.currentItem.timedMetadata) {
        NSLog(@"%@ %@",[metaItem commonKey], [metaItem value]);
    }
    if ([player.currentItem.timedMetadata count]>0) {
        AVMetadataItem *metaItem = [player.currentItem.timedMetadata objectAtIndex:0];
        titleLabel.text = (NSString*)[metaItem value];
    }*/
}

@end
