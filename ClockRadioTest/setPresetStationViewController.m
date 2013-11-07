//
//  setPresetStationViewController.m
//  ClockRadioTest
//
//  Created by Richard Goldberg on 11/7/13.
//  Copyright (c) 2013 Richard Goldberg. All rights reserved.
//

#import "setPresetStationViewController.h"
#import "PresetStationData.h"

@interface setPresetStationViewController ()
@property (strong, nonatomic) NSMutableArray *stationsArray;

@end

@implementation setPresetStationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.stationsArray=[self getCompleteStationList];

}

- (IBAction)cancelButton:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%d stations",self.stationsArray.count);
    return self.stationsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Station";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PresetStationData *station=[self.stationsArray objectAtIndex:indexPath.row];
    
    int preset = station.presetStationNumber.intValue;
    
    cell.textLabel.text = station.stationName;
    cell.imageView.image = [UIImage imageNamed:station.stationIcon];

    // if this station is already assigned to a preset station, then dim it and make it unselectable
    if (preset < 99) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"preset #%d", preset];
        cell.userInteractionEnabled = NO;
        cell.contentView.alpha = 0.5;
    }
    else {
        cell.detailTextLabel.text = @" ";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    // first find the station that currently has this preset station value and reset the preset to 99 (i.e. no preset)
    int i=0;
    PresetStationData *station;
    
    for (station in self.stationsArray) {
        if (station.presetStationNumber == self.presetStationNumberToSet) {
            break;
        }
        i++;
    }
    
    // i currently points to the station that currently has this preset station value
    station.presetStationNumber = [NSNumber numberWithInt:99];
    [self.stationsArray replaceObjectAtIndex:i withObject:(id) station];

    // now get the new station that was selected and save it with this preset
    PresetStationData *newPresetStation=[self.stationsArray objectAtIndex:indexPath.row];
    newPresetStation.presetStationNumber = self.presetStationNumberToSet;
    [self.stationsArray replaceObjectAtIndex:indexPath.row withObject:newPresetStation];
    
    [self saveStationList];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];

    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark -- user inserted methods for accessing core data

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (NSMutableArray*) getCompleteStationList {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PresetStationData" inManagedObjectContext:[self managedObjectContext]];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"stationName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    
    return mutableFetchResults;
}

- (void) saveStationList {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSError *error;
    [context save:&error];
    
}


@end
