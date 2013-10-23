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
#import "DaysWeather.h"

@implementation MasterViewController
@synthesize searchBarCityName;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    daysWeather = [[NSMutableArray alloc] init];
    
    // Setup dateFormatter.
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    
    tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.tableView addGestureRecognizer:tgr];
}

-(void) viewTapped:(UITapGestureRecognizer *) tgr
{
    [searchBarCityName resignFirstResponder];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self getCityWeather];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Not the best way to make rows, but will make rows based on how many array sets of data there are.
    return daysWeather.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell == nil) {
        // Style with title, subtitle and image.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if([daysWeather count] > 0) { // Only do the following if the array has data.
        DaysWeather *currentDay = [daysWeather objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%.0lf%@ %-9s", currentDay.dayTemp, @"\u00B0", [currentDay.day UTF8String]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", currentDay.description];
        
        // Uses AsyncImageView to download images asynchronously.
        NSString *imagesurlloc = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", currentDay.icon];
        [cell.imageView setImage:[UIImage imageNamed:@"defaultimage.png"]];
        [cell.imageView setImageURL:[NSURL URLWithString:imagesurlloc]];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self viewTapped:tgr];
    
    // Create an instance of our DetailViewController.
    DetailViewController *DVC = [[DetailViewController alloc] init];
    
    // Set DVC to the destinationViewController property of segue.
    DVC = [segue destinationViewController];
    
    // Get the index path.
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    // Pass info into properties stored in DVC.
    DVC.cityName = cityName;
    DVC.countryName = countryName;
    DVC.currentDay = [daysWeather objectAtIndex:path.row];
}

/*
 * Initially was going to make this asynchronus using background queue, but is pointless
 * because user must enter city first.
 * I could still do this on search button pressed, but then the table view cells try 
 * to load data that isn't ready yet.
 */
- (void) getCityWeather
{
    // Hide keyboard on search.
    [self.tableView removeGestureRecognizer:tgr];
    [self viewTapped:tgr];
    
    // Flush the daysWeather Array of previous city weather info.
    [daysWeather removeAllObjects];
    
    // Set JSON Api URL. Strip spaces from URL because URL's cannot contain spaces.
    NSString *mayContainSpaces = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&mode=json&units=metric&cnt=7", searchBarCityName.text];
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
        NSDictionary *cityInfo = [[NSDictionary alloc] init];
        NSArray *weekOfWeather = [[NSArray alloc] init];
        cityInfo = [json objectForKey:@"city"];
        weekOfWeather = [json objectForKey:@"list"];
        
        cityName = [NSString stringWithFormat:@"%@", [cityInfo objectForKey:@"name"]];
        countryName = [NSString stringWithFormat:@"%@", [cityInfo objectForKey:@"country"]];
        
        // Init a DaysWeather object for each day.
        for(int i = 0; i < weekOfWeather.count; i++) {
            NSDictionary *eachDaysWeather = [weekOfWeather objectAtIndex:i];
            NSArray *weather = [eachDaysWeather objectForKey:@"weather"];
            NSDictionary *temps = [eachDaysWeather objectForKey:@"temp"];
            
            DaysWeather *currentDay = [[DaysWeather alloc] init];
            currentDay.day = [self getDayFromIndex:i];
            currentDay.description = [[weather objectAtIndex:0] objectForKey:@"description"];
            currentDay.icon = [[weather objectAtIndex:0] objectForKey:@"icon"];
            currentDay.morningTemp = [[temps objectForKey:@"morn"] floatValue];
            currentDay.dayTemp = [[temps objectForKey:@"day"] floatValue];
            currentDay.eveningTemp = [[temps objectForKey:@"eve"] floatValue];
            currentDay.nightTemp = [[temps objectForKey:@"night"] floatValue];
            currentDay.minTemp = [[temps objectForKey:@"min"] floatValue];
            currentDay.maxTemp = [[temps objectForKey:@"max"] floatValue];
            
            [daysWeather addObject:currentDay];
        }
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@, %@", cityName, countryName]; // Set title to city name.
        
        [self.tableView reloadData];    // Reload tableview to display entered city weather info.
    }
}

/*
 * Returns todays date based on the index path passed in, e.g. Tuesday at row 1,(index 0) 0 * 86400 = 0 = Tuesday.
 */
-(NSString *) getDayFromIndex:(int) index
{
    if(index == 0) {
        return @"Today";
    } else if(index == 1) {
        return @"Tomorrow";
    } else {
        return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:index*86400]];
    }
}

@end