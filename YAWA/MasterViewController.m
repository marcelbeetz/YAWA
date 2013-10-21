//
//  MasterViewController.m
//  YAWA
//
//  Created by Marcel Beetz on 18/10/13.
//  Copyright (c) 2013 Marcel Beetz. All rights reserved.
//
//  Using AsyncImageView to load images asynchronously.
//  https://github.com/nicklockwood/AsyncImageView
//
//  Used Ray Wenderlich tutorial for JSON.
//  http://www.raywenderlich.com/5492/

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AsyncImageView.h"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController
@synthesize txtBxSearchCity;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    cityInfo = [[NSDictionary alloc] init];
    weatherInfo = [[NSArray alloc] init];
    
    // Setup dateFormatter.
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Not the best way to make rows, but will make rows based on how many array sets of data there are.
    return weatherInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell == nil) {
        // Style with title, subtitle and image.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if(weatherInfo.count > 0) { // Only do the following if the array has data.
        NSDictionary *aDay = [weatherInfo objectAtIndex:indexPath.row];
        NSDictionary *temps = [aDay objectForKey:@"temp"];
        float stringFloat = [[temps objectForKey:@"day"] floatValue];
        NSString *currentTemp = [NSString stringWithFormat:@"%.0lf%@", stringFloat, @"\u00B0"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %-9s", currentTemp,
                                [[self getDayFromIndex:indexPath.row] UTF8String]];  // Gets day of week by multiplying the row 0-6 by the seconds in a day.
        
        NSArray *weather = [aDay objectForKey:@"weather"];
        NSDictionary *description = [weather objectAtIndex:0];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[description objectForKey:@"description"]];
        
        // Uses AsyncImageView to download images asynchronously.
        NSString *imagesurlloc = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", [description objectForKey:@"icon"]];
        [cell.imageView setImage:[UIImage imageNamed:@"defaultimage.png"]];
        [cell.imageView setImageURL:[NSURL URLWithString:imagesurlloc]];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Create an instance of our DetailViewController.
    DetailViewController *DVC = [[DetailViewController alloc] init];
    
    // Set DVC to the destinationViewController property of segue.
    DVC = [segue destinationViewController];
    
    // Get the index path.
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    // Pass info into properties stored in DVC.
    DVC.selectedCityInfo = cityInfo;
    DVC.selectedCityWeatherInfo = [weatherInfo objectAtIndex:path.row];
    DVC.selectedDay = [self getDayFromIndex:path.row];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

/*
 * Initially was going to make this asynchronus using background queue, but is pointless
 * because user must enter city first.
 * I could still do this on search button pressed, but then the table view cells try 
 * to load data that isn't ready yet.
 */
- (IBAction)btnSearchCity:(id)sender {
    // Set JSON Api URL. Strip spaces from URL because URL's cannot contain spaces.
    NSString *mayContainSpaces = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&mode=json&units=metric&cnt=7", txtBxSearchCity.text];
    NSURL *apiURL = [NSURL URLWithString: [mayContainSpaces stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    // Get data from api using JSON Serialization and store in a Dictionary and Array.
    NSData* data = [NSData dataWithContentsOfURL:apiURL];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    // Show message box if invalid city is entered.
    NSString *check404 = [json objectForKey:@"cod"];
    if([check404 isEqualToString:@"404"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid City"
                                                        message:@"Enter a valid city name."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        cityInfo = [json objectForKey:@"city"];
        weatherInfo = [json objectForKey:@"list"];
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@, %@",
                                     [cityInfo objectForKey:@"name"], [cityInfo objectForKey:@"country"]]; // Set title to city name.
        
        [self.tableView reloadData];    // Reload tableview to display entered city weather info.
        
    }
}

/*
 * Returns todays date based on the index path passed in, e.g. Tuesday at row 1,(index 0) 0 * 86400 = 0 = Tuesday.
 */
-(NSString*) getDayFromIndex:(int) index {
    if(index == 0) {
        return @"Today";
    } else if(index == 1) {
        return @"Tomorrow";
    } else {
        return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:index*86400]];
    }
}

@end
