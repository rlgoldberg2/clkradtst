//
//  playTVstationViewController.m
//  ClockRadioTest
//
//  Created by Richard Goldberg on 11/9/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import "playTVstationViewController.h"

@interface playTVstationViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *TVview;
@property (nonatomic) BOOL startPlaying;

@end

@implementation playTVstationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // this lets our program know when the user taps on the done button to exit from watching tv station
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VideoExitFullScreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];

    NSURLRequest *tvRequest = [NSURLRequest requestWithURL:self.tvURLtoPlay];
    [self.TVview loadRequest:tvRequest];
    self.startPlaying = NO;


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.startPlaying == NO) {
        self.startPlaying=YES;
    }
    else {
        [self doneButton:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doneButton:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];

}

@end
