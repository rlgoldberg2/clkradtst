//
//  ClockRadioViewController.m
//  ClockRadioTest
//
//  Created by Richard Goldberg on 10/31/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import "ClockRadioViewController.h"

@interface ClockRadioViewController ()
@property (nonatomic, strong) NSMutableArray *radioStationsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSIndexPath *indexOfLongPressSelectedStation;
@property (nonatomic, strong) NSNumber *indexOfSelectedStation;
@property (nonatomic, strong) NSTimer *oneSecTimer;

@property (nonatomic, strong) NSNumber *displayMode;

@property (weak, nonatomic) IBOutlet UICollectionView *stationCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *dayButton;

@end

#define DISPLAY_MODE_DAY 0
#define DISPLAY_MODE_SLEEP 1
#define DISPLAY_MODE_NIGHT 2

@implementation ClockRadioViewController


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
    
	// Setup long press gesture on collection view for when user does a press/hold on a radio station name
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];

    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;  //cell will not be selected during long press
    lpgr.minimumPressDuration = 1.0;
    lpgr.numberOfTouchesRequired = 1;
    lpgr.numberOfTapsRequired = 0;
    [self.stationCollectionView addGestureRecognizer:lpgr];
    
    // force to start in day mode
    [self dayButtonPress:self];


    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.radioStationsArray=[self getRadioStationList];
    if (self.radioStationsArray.count==0) {
        [self preloadCoreDataDefaultStations];          // if database is empty, then preload it
        self.radioStationsArray=[self getRadioStationList];  // now get list again
    }
    else {
        NSLog(@"There's stuff in the database so skipping the import of default data");
    }

    // this will refresh the collection view.  If any changes have been made (i.e. cells have moved) then it will show those changes by animating them
    
    [self animateChangesInCollectionView];
    
    // setup timer with 1 sec interval so that clock displays current time
    self.oneSecTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.oneSecTimer invalidate];
    
}

// the following method is automatically called when a long press occurs
// the method will figure out which radio station the user was pressing, and start the segue to edit that station
-(void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint P = [gestureRecognizer locationInView:self.stationCollectionView];
        self.indexOfLongPressSelectedStation = [self.stationCollectionView indexPathForItemAtPoint:P];
        if (self.indexOfLongPressSelectedStation) {
            [self performSegueWithIdentifier:@"editStation" sender:self];
        }
        else {
            NSLog(@"couldn't find indexPath");
        }
    }
}

// the following method is automatically called by the timer
- (void) updateTime:(NSTimer *)timer
{
    NSDate *currentTime;
    NSDate *currentDate;
    NSDate *currentDay;
    
    //load the time
    currentTime = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.timeLabel.text = [timeFormatter stringFromDate:currentTime];
    
    //load the date
    currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle ];
    self.dateLabel.text = [dateFormatter stringFromDate:currentDate];
    
    //load the day
    currentDay = [NSDate date];
    [dateFormatter setDateFormat:@"EEEE" ];
    self.dayLabel.text = [dateFormatter stringFromDate:currentDay];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark collection view delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Return the number of sections.
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.radioStationsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"stationCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RedBorder.png"]];

    RadioStationData *info=[self.radioStationsArray objectAtIndex:indexPath.row];
    UILabel *radioLabel = (UILabel *) [cell viewWithTag:100];
    UIImageView *radioImage = (UIImageView *) [cell viewWithTag:200];

    // if there was an icon specified, and it's not sleep mode, then display icon and hide label
    if (info.icon.length > 0 && [self.displayMode intValue] != DISPLAY_MODE_SLEEP) {
        radioImage.image = [UIImage imageNamed:info.icon];
        radioImage.hidden = NO;
        radioLabel.hidden = YES;
    }
    
    // otherwise, display label and hide icon
    else {
        radioLabel.text = info.name;
        radioImage.hidden = YES;
        radioLabel.hidden = NO;
        radioLabel.numberOfLines = 0;
        [radioLabel setLineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return cell;
    
}
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected item %d", indexPath.row);
    
    //check if this item is already selected
    if (indexPath.row == self.indexOfSelectedStation.intValue) {
        //yes, then deselect it
        [self.stationCollectionView deselectItemAtIndexPath:indexPath animated:YES];
        [self collectionView:self.stationCollectionView didDeselectItemAtIndexPath:indexPath];
    }
    else {
        //otherwise, then save currently selected station
        self.indexOfSelectedStation = [NSNumber numberWithInt:indexPath.row];
        
    }
}

- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexOfSelectedStation = [NSNumber numberWithInt:-1];
    
    NSLog(@"deselected item %d", indexPath.row);
    
}

/*
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editStatus) {   // if it's editing mode, then edit the current radio station
        RadioStationData *row = [self.radioStationsArray objectAtIndex:indexPath.row];
        
        NSLog(@"row %d iseditable %d", indexPath.row, [row.isEditable integerValue]);
        
        if ([row.isEditable integerValue]) {
            [self performSegueWithIdentifier:@"editStation" sender:self];
        }
    }
    
    // if it's not in editing mode, then select the current row
    else {
        selectedRow=indexPath.row;
        [tableView reloadData];
    }
}
*/


#pragma mark set screen brightness

- (IBAction)sleepButtonPress:(id)sender {
    [UIScreen mainScreen].brightness = 0;
    self.displayMode=@DISPLAY_MODE_SLEEP;
    [self animateChangesInCollectionView];
}

- (IBAction)nightButtonPress:(id)sender {
    [UIScreen mainScreen].brightness = 0.4;
    self.displayMode=@DISPLAY_MODE_NIGHT;
    [self animateChangesInCollectionView];
}

- (IBAction)dayButtonPress:(id)sender {
    [UIScreen mainScreen].brightness = 1.0;
    self.displayMode=@DISPLAY_MODE_DAY;
    [self animateChangesInCollectionView];
}

#pragma mark animate any changes in collection view

-(void) animateChangesInCollectionView
{
    [self.stationCollectionView performBatchUpdates:^{
    [self.stationCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
}

#pragma mark initializing core data

- (void)insertStationWithStationName:(NSString *)stationName
                             withURL: (NSString *)url
                            withIcon: (NSString *)icon
                      withEditStatus: (BOOL)editStatus
                    withDisplayOrder: (NSNumber *)displayOrder
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    RadioStationData *station =
    [NSEntityDescription insertNewObjectForEntityForName:@"RadioStationData"
                                  inManagedObjectContext:managedObjectContext];
    
    station.name = stationName;
    station.url=url;
    station.icon=icon;
    station.isEditable=[NSNumber numberWithBool: editStatus];
    station.displayOrder=displayOrder;
    
    [self.managedObjectContext save:nil];
}

- (void)preloadCoreDataDefaultStations {
    
    NSLog(@"Importing Core Data Default Values for Roles...");
    [self insertStationWithStationName:@"ESPN"
                               withURL:@"http://espn.play.com"
                              withIcon:@"espnIcon.png"
                        withEditStatus:YES
                      withDisplayOrder:@3];
    
    [self insertStationWithStationName:@"CBC News"
                               withURL:@"http://cbc.play.com"
                              withIcon:@"cbcIcon.jpg"
                        withEditStatus:NO
                      withDisplayOrder:@1];
    
    [self insertStationWithStationName:@"NPR News"
                               withURL:@"http://npr.play.com"
                              withIcon:@"nprIcon.jpg"
                        withEditStatus:YES
                      withDisplayOrder:@2];
    
    [self insertStationWithStationName:@"BBC News"
                               withURL:@"http://bbc.play.com"
                              withIcon:@"bbcIcon.jpg"
                        withEditStatus:NO
                      withDisplayOrder:@4];
    
    [self insertStationWithStationName:@"User defined" withURL:nil withIcon:nil withEditStatus:YES withDisplayOrder:@5];
    
    
    NSLog(@"Importing Core Data Default Values for Roles Completed!");
}

#pragma mark -- user inserted methods for accessing core data

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSMutableArray*) getRadioStationList {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RadioStationData" inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    
    return mutableFetchResults;
}

- (void) saveRadioStationList {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error;
    [context save:&error];
    
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    EditStationsViewController *destViewController = segue.destinationViewController;
    
    // user wants to edit station, grab data on this station and send to EditStationsViewController
    
    if ([[segue identifier] isEqualToString:@"editStation"]) {
        RadioStationData *selectedStation = [self.radioStationsArray objectAtIndex:self.indexOfLongPressSelectedStation.row];
        destViewController.stationToEdit=selectedStation;
        destViewController.editStationsDelegate = self;
    }
}

-(void) displayOrderHasChanged: (int) oldDisplayOrder to: (int) newDisplayOrder;
{
    NSLog(@"the new display changed from: %d to %d",oldDisplayOrder, newDisplayOrder);

    // first remove item from local array and move it to new place
    RadioStationData *item = [self.radioStationsArray objectAtIndex:oldDisplayOrder-1];
    [self.radioStationsArray removeObjectAtIndex:oldDisplayOrder-1];
    [self.radioStationsArray insertObject:item atIndex:newDisplayOrder-1];
    
    // then setup a new display order based on the current order of the items
    int i = 1;
    for(RadioStationData *row in self.radioStationsArray) {
        row.displayOrder = [NSNumber numberWithInt:i++];
        NSLog(@"Station %@ order %@",row.name, row.displayOrder);
    }
    [self saveRadioStationList];

}

@end
