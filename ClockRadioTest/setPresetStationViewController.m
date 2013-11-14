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
@property (strong, nonatomic) NSFetchedResultsController *frController;
@property (strong, nonatomic) NSManagedObjectContext *moContext;

@end

@implementation setPresetStationViewController

bool anyEditableStations;

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

    self.moContext = [self setupManagedObjectContext];
    self.frController = [self setupFetchedResultsController];
    self.frController.delegate = self;
    
    NSError *error;
    if (![self.frController performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{

    // check if there are any editable stations (the preloaded stations are not editable, but the stations that the users has added are editable); as long as there are, then the user can enter edit mode
    
    
    // clear the editable stations flag
    anyEditableStations=NO;

    // setEditing will call canEditRowAtIndexPath for every row.  This method will set the above flag if there are any editable rows
    [super setEditing:editing animated:animated];

    // if the user is trying to enter edit mode and there are no editable stations, then display message and revert out of edit mode
    if ((editing) && (anyEditableStations==NO)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Defaults stations cannot be edited"
                                                        message:@"Click on \"Add new radio or TV station\" button at bottom of list to add your own station"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [super setEditing:NO animated:animated];

    }

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

/*
 The data source methods are handled primarily by the fetch results controller
 */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSLog(@"%d sections",[[self.frController sections] count]);
    return [[self.frController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frController sections] objectAtIndex:section];
    NSLog(@"%d rows", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
    
}


// Customize the appearance of table view cells.
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell to show the book's title
    PresetStationData *station = [self.frController objectAtIndexPath:indexPath];

    int preset = station.presetStationNumber.intValue;

    cell.textLabel.text = station.stationName;
    
    // if there is an icon name given, try to display it....
    if (station.stationIcon) {
        //cell.imageView.image = [UIImage imageNamed:station.stationIcon];
        
        // first check if icon name references a preloaded image file or an internet URL
        // if a preloaded file, then grab it
        if ([station.stationIcon rangeOfString:@"http://"].location == NSNotFound) {
            if (station.stationIcon.length > 0) {
                
                cell.imageView.image = [UIImage imageNamed:station.stationIcon];
                
                // if it's not valid, then give error message
                if (cell.imageView.image == nil) {
                    NSString *alertMessage = [NSString stringWithFormat:@"You have given an invalid URL for user-defined station %@", station.stationName];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"invalid URL" message: alertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    
                }
            }
        }
        
        // if we arrive here, this is an image file stored online, so let's grab it and display it asynchronously
        else {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                                         [NSURL URLWithString:station.stationIcon]]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    cell.imageView.image= image;
                    [cell setNeedsLayout];
                });
            });
        }

    }
    
    // if this station is already assigned to a preset station, then dim it and make it unselectable
    if (preset < 99) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"preset #%d", preset];
    }
    else {
        cell.detailTextLabel.text = @" ";
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Station";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    // Display the authors' names as section headings.
    return [[[self.frController sections] objectAtIndex:section] name];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // if we're in editing mode, then edit the selected cell
    if (tableView.isEditing) {
        [self performSegueWithIdentifier:@"editStation" sender:self];
    }
 
    // otherwise, select this station as the new preset
    else {
        // user has selected a new station for this preset
        // first, grab the preset station number of the current preset
        int presetNumber = [self.presetStationToChange.presetStationNumber intValue];
        
        // then, reset the preset station number so that this station no longer appears on the preset list
        self.presetStationToChange.presetStationNumber = @99;
        
        // finally, get the currently selected station and make this the new preset
        PresetStationData *newPresetStation = [self.frController objectAtIndexPath:indexPath];
        
        // check if this selected station currently has a preset.  If so than swap it's preset #
        if (newPresetStation.presetStationNumber.intValue != 99) {
            self.presetStationToChange.presetStationNumber = newPresetStation.presetStationNumber;
        }
        else {
            self.presetStationToChange.presetStationNumber = @99;
        }
        newPresetStation.presetStationNumber = [NSNumber numberWithInt:presetNumber];
        
        [self saveStationList];
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    PresetStationData *station = [self.frController objectAtIndexPath:indexPath];
    
    if (station.isEditable.intValue) {
        anyEditableStations=YES;
        return YES;
    }
    else {
        return NO;
    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        PresetStationData *stationToDelete = [self.frController objectAtIndexPath:indexPath];
        
        // if this station is not currently set as a preset, then delete it
        if (stationToDelete.presetStationNumber.intValue == 99) {
            [self.moContext deleteObject:stationToDelete];
            
            NSError *error = nil;
            if (![self.moContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Delete" message:@"You cannot delete a station if it is currently selected as a preset station.  First, change this so it is not a preset station and then you can delete it" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
 NSFetchedResultsController delegate methods to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}




#pragma mark -- user inserted methods for accessing core data

- (NSManagedObjectContext *)setupManagedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


-(NSFetchedResultsController *) setupFetchedResultsController
{
    // Create and configure a fetch request with the Book entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PresetStationData" inManagedObjectContext:self.moContext];
    [fetchRequest setEntity:entity];
    
    // Create the sort descriptors array.
    NSSortDescriptor *sortByMediaType = [[NSSortDescriptor alloc] initWithKey:@"mediaType" ascending:YES];
    NSSortDescriptor *sortByStationName = [[NSSortDescriptor alloc] initWithKey:@"stationName" ascending:YES];
    NSArray *sortDescriptors = @[sortByMediaType,sortByStationName];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Create and initialize the fetch results controller.
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.moContext sectionNameKeyPath:@"mediaType" cacheName:@"Root"];

    return frc;
}


- (void) saveStationList {
    NSManagedObjectContext *context = self.moContext;
    
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
    destViewController.editStationsDelegate = self;
    
    // user wants to add a new station
    if ([[segue identifier] isEqualToString:@"addStation"]) {
        
        // create a new context for this station to add and set the parent to moContext.  This makes it easy to discard this station if the user hits "cancel"
        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [addingContext setParentContext:self.moContext];
        
        PresetStationData *newStation = (PresetStationData *) [NSEntityDescription insertNewObjectForEntityForName:@"PresetStationData" inManagedObjectContext:addingContext];
        
        newStation.stationName = nil;
        newStation.stationURL = nil;
        newStation.stationIcon = nil;
        newStation.mediaType = @"Radio";
        newStation.presetStationNumber = @99;
        newStation.isEditable = [NSNumber numberWithBool:YES];
        
        destViewController.stationToEdit = newStation;
        destViewController.editingMOC = addingContext;
        //destViewController.isAdded = NO;
        
        
    }
    
    // user wants to edit the currently selected station
    if ([[segue identifier] isEqualToString:@"editStation"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destViewController.stationToEdit = [self.frController objectAtIndexPath:indexPath];
        destViewController.editingMOC = self.moContext;
    }
    
}

-(void)editStationComplete:(EditStationsViewController *)controller didFinishWithSave:(BOOL)save
{
    if (save) {
        /*
         The new book is associated with the add controller's managed object context.
         This means that any edits that are made don't affect the application's main managed object context -- it's a way of keeping disjoint edits in a separate scratchpad. Saving changes to that context, though, only push changes to the fetched results controller's context. To save the changes to the persistent store, you have to save the fetch results controller's context as well.
         */
        NSError *error;
        NSManagedObjectContext *addingManagedObjectContext = [controller editingMOC];
        if (![addingManagedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        if (![[self.frController managedObjectContext] save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [self setEditing:NO animated:YES];
}


@end
