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

@implementation MasterViewController
@synthesize searchBarCityName;

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
    DVC.selectedCityInfo = cityInfo;
    DVC.selectedCityWeatherInfo = [weatherInfo objectAtIndex:path.row];
    DVC.selectedDay = [self getDayFromIndex:path.row];
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
-(NSString*) getDayFromIndex:(int) index
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