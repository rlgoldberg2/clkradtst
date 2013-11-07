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
@property (weak, nonatomic) IBOutlet UITextField *displayOrderTextField;
@property (strong, nonatomic) NSNumber *originalDisplayOrder;

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
    if (self.stationToEdit)  {
        self.nameTextField.text = self.stationToEdit.stationName;
        self.urlStreamTextField.text = self.stationToEdit.stationURL;
        self.urlIconTextField.text = self.stationToEdit.stationIcon;
        self.displayOrderTextField.text=[NSString stringWithFormat:@"%@", self.stationToEdit.presetStationNumber];
    }
    else {
        self.nameTextField.text=nil;
        self.urlStreamTextField.text=nil;
        self.urlIconTextField.text=nil;
        self.displayOrderTextField.text=nil;
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (IBAction)save:(id)sender {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    int newDisplayOrder, oldDisplayOrder;
    
    // if user is editing station, then update name,url,icon and resave
    if (self.stationToEdit) {
        self.stationToEdit.stationName = self.nameTextField.text;
        self.stationToEdit.stationURL = self.urlStreamTextField.text;
        self.stationToEdit.stationIcon = self.urlIconTextField.text;
        newDisplayOrder = [self.displayOrderTextField.text intValue];
        oldDisplayOrder = [self.stationToEdit.presetStationNumber integerValue];
        if (newDisplayOrder != oldDisplayOrder) {
            [self.editStationsDelegate displayOrderHasChanged:oldDisplayOrder to:newDisplayOrder];
        }
        // isEditable is already set, so no need to change here
    }
    
    // if user is adding station, then set all fields and save
    else {
        PresetStationData *newStation = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"PresetStationData"
                                        inManagedObjectContext:context];
        
        newStation.stationName = self.nameTextField.text;
        newStation.stationURL = self.urlStreamTextField.text;
        newStation.stationIcon = self.urlIconTextField.text;
        int displayOrderInt = [self.displayOrderTextField.text intValue];
        newStation.presetStationNumber = [NSNumber numberWithInteger:displayOrderInt];
        newStation.isEditable = [NSNumber numberWithBool:YES];
    }
    
    NSError *error;
    [context save:&error];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
}


- (IBAction)cancel:(id)sender {
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
