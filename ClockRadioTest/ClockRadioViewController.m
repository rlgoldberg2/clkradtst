//
//  ClockRadioViewController.m
//  ClockRadioTest
//
//  Created by Richard Goldberg on 10/31/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import "ClockRadioViewController.h"
#import "setPresetStationViewController.h"
#import "RadioStationModel.h"

@interface ClockRadioViewController ()
@property (nonatomic, strong) NSMutableArray *radioStationsArray;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSIndexPath *indexOfLongPressSelectedStation;
@property (nonatomic, strong) NSNumber *indexOfSelectedStation;
@property (nonatomic, strong) NSTimer *oneSecTimer;
@property (nonatomic, strong) NSNumber *displayMode;

@property (nonatomic, strong) AVPlayer *streamingPlayer;
//@property (nonatomic, strong) AVPlayerItem *playerItem;

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
    
    self.indexOfSelectedStation = @-1;
    
    // force to start in day mode
    [self dayButtonPress:self];


    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.radioStationsArray=[self getPresetStationList];
    if (self.radioStationsArray.count==0) {
        [self preloadCoreDataDefaultStations];          // if database is empty, then preload it
        self.radioStationsArray=[self getPresetStationList];  // now get list again
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
            [self performSegueWithIdentifier:@"setPresetStation" sender:self];
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

    PresetStationData *info=[self.radioStationsArray objectAtIndex:indexPath.row];
    UILabel *radioLabel = (UILabel *) [cell viewWithTag:100];
    UIImageView *radioImage = (UIImageView *) [cell viewWithTag:200];

    // if there was an icon specified, and it's not sleep mode, then display icon and hide label
    if (info.stationIcon.length > 0 && [self.displayMode intValue] != DISPLAY_MODE_SLEEP) {
        radioImage.image = [UIImage imageNamed:info.stationIcon];
        radioImage.hidden = NO;
        radioLabel.hidden = YES;
    }
    
    // otherwise, display label and hide icon
    else {
        radioLabel.text = info.stationName;
        radioImage.hidden = YES;
        radioLabel.hidden = NO;
        radioLabel.numberOfLines = 0;
        [radioLabel setLineBreakMode:NSLineBreakByWordWrapping];
    }

    // if this station is currently selected and playing, then we want to maintain that selection to keep the selected boarder around the cell
    if (indexPath.row == self.indexOfSelectedStation.intValue) {
        cell.selected = TRUE;
        [self.stationCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        NSLog(@"cell %d selected", indexPath.row);
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
        //otherwise, then save and play the newly selected station
        self.indexOfSelectedStation = [NSNumber numberWithInt:indexPath.row];
        PresetStationData *station = [self.radioStationsArray objectAtIndex:indexPath.row];
        self.streamingPlayer = [RadioStationModel radioStationPlay:station];
    }
}

- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.indexOfSelectedStation = [NSNumber numberWithInt:-1];
    [RadioStationModel radioStationPlayPause:self.streamingPlayer];
    
    NSLog(@"deselected item %d", indexPath.row);
    
}


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
                   withStationNumber: (NSNumber *)stationNumber
                       withMediaType: (NSString *)mediaType
{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    PresetStationData *station =
    [NSEntityDescription insertNewObjectForEntityForName:@"PresetStationData"
                                  inManagedObjectContext:managedObjectContext];
    
    station.stationName = stationName;
    station.stationURL=url;
    station.stationIcon=icon;
    station.isEditable=[NSNumber numberWithBool: editStatus];
    station.presetStationNumber=stationNumber;
    station.mediaType=mediaType;
    
    [self.managedObjectContext save:nil];
}

- (void)preloadCoreDataDefaultStations {
    
    NSLog(@"Importing Core Data Default Values for Roles...");
    [self insertStationWithStationName:@"ESPN"
                               withURL:@"http://den-a.plr.liquidcompass.net/pls/KIROAMMP3.pls"
                              withIcon:@"espnIcon.png"
                        withEditStatus:NO
                      withStationNumber:@1
                         withMediaType:@"Radio"];
    
    [self insertStationWithStationName:@"CBC News"
                               withURL:@"http://playerservices.streamtheworld.com/pls/CBC_R1_TOR_H.pls"
                              withIcon:@"cbcIcon.jpg"
                        withEditStatus:NO
                      withStationNumber:@2
                         withMediaType:@"Radio"];
    
    [self insertStationWithStationName:@"NPR News"
                               withURL:@"http://152.2.63.68:8000/listen.pls"
                              withIcon:@"nprIcon.jpg"
                        withEditStatus:NO
                      withStationNumber:@3
                         withMediaType:@"Radio"];
    
    [self insertStationWithStationName:@"BBC News"
                               withURL:@"http://www.bbc.co.uk/worldservice/meta/tx/nb/live/eneuk.pls"
                              withIcon:@"bbcIcon.jpg"
                        withEditStatus:NO
                      withStationNumber:@99
                          withMediaType:@"Radio"];
    
    [self insertStationWithStationName:@"Bloomberg TV"
                               withURL:@"http://live.bltvios.com.edgesuite.net/oza2w6q8gX9WSkRx13bskffWIuyf/BnazlkNDpCIcD-QkfyZCQKlRiiFnVa5I/master.m3u8"
                              withIcon:nil
                        withEditStatus:NO
                     withStationNumber:@4
                         withMediaType:@"TV"];
    
    [self insertStationWithStationName:@"Deutsche Welle"
                               withURL:@"http://www.metafilegenerator.de/DWelle/tv-asia/ios/master.m3u8"
                              withIcon:nil
                        withEditStatus:NO
                     withStationNumber:@5
                         withMediaType:@"TV"];

    [self insertStationWithStationName:@"CCTV — China"
                               withURL:@"http://cctv.lsops.net/live/cctv_en_hls.smil/playlist.m3u8"
                              withIcon:nil
                        withEditStatus:NO
                     withStationNumber:@99
                         withMediaType:@"TV"];

    
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

- (NSMutableArray*) getPresetStationList {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PresetStationData" inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"presetStationNumber" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"presetStationNumber < 99"];
    [request setPredicate:predicate];
    
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
    UINavigationController *navigationController = segue.destinationViewController;
    setPresetStationViewController *destViewController = (id)[[navigationController viewControllers] objectAtIndex:0];
     
    // user wants to pick a new preset station
    if ([[segue identifier] isEqualToString:@"setPresetStation"]) {
        PresetStationData *station = [self.radioStationsArray objectAtIndex:self.indexOfLongPressSelectedStation.row];
        destViewController.presetStationToChange = station;
         
        // if this station is currently playing, then pause it
        NSLog(@"%d %d",self.indexOfLongPressSelectedStation.row, self.indexOfSelectedStation.intValue);
         
        if (self.indexOfLongPressSelectedStation.row == self.indexOfSelectedStation.intValue) {
            [self collectionView:self.stationCollectionView didDeselectItemAtIndexPath:self.indexOfLongPressSelectedStation];
        }
    }
}



@end
