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
        self.nameTextField.text = self.stationToEdit.name;
        self.urlStreamTextField.text = self.stationToEdit.url;
        self.urlIconTextField.text = self.stationToEdit.icon;
        
        int displayOrderInt = [self.stationToEdit.displayOrder intValue]+1;
        self.displayOrderTextField.text=[NSString stringWithFormat:@"%d", displayOrderInt];
    }
    else {
        self.nameTextField.text=nil;
        self.urlStreamTextField.text=nil;
        self.urlIconTextField.text=nil;
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
    int displayOrderInt;
    
    // if user is editing station, then update name,url,icon and resave
    if (self.stationToEdit) {
        self.stationToEdit.name = self.nameTextField.text;
        self.stationToEdit.url = self.urlStreamTextField.text;
        self.stationToEdit.icon = self.urlIconTextField.text;
        displayOrderInt = [self.displayOrderTextField.text intValue]-1;
        self.stationToEdit.displayOrder = [NSNumber numberWithInteger:displayOrderInt];

        // isEditable is already set, so no need to change here
    }
    
    // if user is adding station, then set all fields and save
    else {
        RadioStationData *newStation = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"RadioStationData"
                                        inManagedObjectContext:context];
        
        newStation.name = self.nameTextField.text;
        newStation.url = self.urlStreamTextField.text;
        newStation.icon = self.urlIconTextField.text;
        int displayOrderInt = [self.displayOrderTextField.text intValue]-1;
        newStation.displayOrder = [NSNumber numberWithInteger:displayOrderInt];
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
