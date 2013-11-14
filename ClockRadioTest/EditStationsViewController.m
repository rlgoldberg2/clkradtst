//
//  EditStationsViewController.m
//  ClockRadioTest
//
//  Created by Richard Goldberg on 10/31/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import "EditStationsViewController.h"

@interface EditStationsViewController ()
{
    UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *urlStreamTextField;
@property (weak, nonatomic) IBOutlet UITextField *urlIconTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mediaTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

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
    NSLog(@"media type %@, station number %@",self.stationToEdit.mediaType, self.stationToEdit.presetStationNumber);
    
    if ([self.stationToEdit.mediaType isEqualToString:@"Radio"]) {
        self.mediaTypeSegmentedControl.selectedSegmentIndex = 0;
    }
    else {
        self.mediaTypeSegmentedControl.selectedSegmentIndex = 1;
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(320, 524);
    self.scrollView.showsVerticalScrollIndicator = YES;
    
    [self registerForKeyboardNotifications];
}

- (IBAction)save:(id)sender {
   
    //  user is editing station, so update name,url,icon and resave

    self.stationToEdit.stationName = self.nameTextField.text;
    self.stationToEdit.stationURL = self.urlStreamTextField.text;
    self.stationToEdit.stationIcon = self.urlIconTextField.text;
    self.stationToEdit.mediaType = self.mediaTypeSegmentedControl.selectedSegmentIndex==0? @"Radio" : @"Television";
    
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

#pragma mark methods for scrolling text fields out of the way of the keyboard
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.scrollView.frame;
    aRect.size.height -= kbSize.height;
    self.scrollView.frame = aRect;
    self.scrollView.contentSize = CGSizeMake(320, 524);

    CGRect textFieldRect = activeField.frame;
    //textFieldRect.origin.y += 10;
    
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:textFieldRect animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (BOOL)textFieldShouldReturn: (UITextField *)textField
{
    return [activeField resignFirstResponder];
    
}

@end
