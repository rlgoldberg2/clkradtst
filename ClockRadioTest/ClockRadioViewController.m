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
@property (weak, nonatomic) IBOutlet UICollectionView *stationCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *dayButton;
@property (nonatomic, strong) NSIndexPath *indexOfSelectedStation;
@end

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
	// Do any additional setup after loading the view.
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleLongPress:)];

    [self.stationCollectionView addGestureRecognizer:lpgr];

    lpgr.delegate = self;
    lpgr.minimumPressDuration = 1.0;
    lpgr.numberOfTouchesRequired = 1;
    lpgr.numberOfTapsRequired = 0;
    
    
}

-(void) handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint P = [gestureRecognizer locationInView:self.stationCollectionView];
    
    self.indexOfSelectedStation = [self.stationCollectionView indexPathForItemAtPoint:P];
    if (self.indexOfSelectedStation == nil) {
        NSLog(@"couldn't find indexPath");
    }
    
    [self performSegueWithIdentifier:@"editStation" sender:self];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self updateTime];
    
    self.radioStationsArray=[self getRadioStationList];
    if (self.radioStationsArray.count==0) {
        [self preloadCoreDataDefaultStations];          // if database is empty, then preload it
        self.radioStationsArray=[self getRadioStationList];  // now get list again
    }
    else {
        NSLog(@"There's stuff in the database so skipping the import of default data");
    }
    
    [self.stationCollectionView reloadData];
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
    RadioStationData *info=[self.radioStationsArray objectAtIndex:indexPath.row];
    UILabel *radioLabel = (UILabel *) [cell viewWithTag:100];
    radioLabel.text=info.name;
    
    return cell;
    
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

- (void)updateTime {
    
    NSDate *currentTime;
    NSTimer *updateTimer;
    NSDate *currentDate;
    NSDate *currentDay;

    [updateTimer invalidate];
    updateTimer = nil;
    
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
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    //load the day
    currentDay = [NSDate date];
    [dateFormatter setDateFormat:@"EEEE" ];
    
    self.dayLabel.text = [dateFormatter stringFromDate:currentDay];
}

#pragma mark set screen brightness

- (IBAction)sleepButtonPress:(id)sender {
    [UIScreen mainScreen].brightness = 0;
    NSLog(@"sleep");
}
- (IBAction)nightButtonPress:(id)sender {
    [UIScreen mainScreen].brightness = 0.4;
    NSLog(@"night");
}

- (IBAction)dayButtonPress:(id)sender {
    [UIScreen mainScreen].brightness = 1.0;
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
                      withDisplayOrder:@0];
    
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
        //UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.indexOfSelectedStation];
        RadioStationData *selectedStation = [self.radioStationsArray objectAtIndex:self.indexOfSelectedStation.row];
        destViewController.stationToEdit=selectedStation;
    }
    
    
}


@end
