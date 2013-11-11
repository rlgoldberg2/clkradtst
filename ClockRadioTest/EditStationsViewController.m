//
//  EditStationsViewController.m
//  ClockRadioTest
//
//  Created by Richard Goldberg on 10/31/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import "EditStationsViewController.h"

@interface EditStationsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *urlStreamTextField;
@property (weak, nonatomic) IBOutlet UITextField *urlIconTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mediaTypeSegmentedControl;

@end

@implementation EditStationsViewController

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
    // initialize text fields if the user selected a segue to edit
    
    self.nameTextField.text = self.stationToEdit.stationName;
    self.urlStreamTextField.text = self.stationToEdit.stationURL;
    self.urlIconTextField.text = self.stationToEdit.stationIcon;
    if ([self.stationToEdit.mediaType isEqualToString:@"Radio"]) {
        self.mediaTypeSegmentedControl.selectedSegmentIndex = 0;
    }
    else {
        self.mediaTypeSegmentedControl.selectedSegmentIndex = 1;
    }

}


- (IBAction)save:(id)sender {
   
    // if user is editing station, then update name,url,icon and resave
    if (self.stationToEdit) {
        self.stationToEdit.stationName = self.nameTextField.text;
        self.stationToEdit.stationURL = self.urlStreamTextField.text;
        self.stationToEdit.stationIcon = self.urlIconTextField.text;
        self.stationToEdit.mediaType =
            self.mediaTypeSegmentedControl.selectedSegmentIndex? @"Radio":@"Television";
        self.stationToEdit.presetStationNumber = @99;
        self.stationToEdit.isEditable = [NSNumber numberWithBool: YES];
    }

    self.stationToEdit.stationName = self.nameTextField.text;
    self.stationToEdit.stationURL = self.urlStreamTextField.text;
    self.stationToEdit.stationIcon = self.urlIconTextField.text;
    self.stationToEdit.mediaType = self.mediaTypeSegmentedControl.selectedSegmentIndex? @"Radio" : @"Television";
    
    [self.editStationsDelegate editStationComplete:self didFinishWithSave:YES];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)cancel:(id)sender {

    [self.editStationsDelegate editStationComplete:self didFinishWithSave:NO];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
