//
//  MasterViewController.h
//  YAWA
//
//  Created by Marcel Beetz on 18/10/13.
//  Copyright (c) 2013 Marcel Beetz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>{
    NSString *cityName;
    NSString *countryName;
    NSMutableArray *daysWeather;
    NSDateFormatter *dateFormatter;
    UITapGestureRecognizer *tgr;
}

// Self Made.
@property (strong, nonatomic) IBOutlet UISearchBar *searchBarCityName;
@property (nonatomic, retain) NSArray *imageURLs;


// Auto Made.
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end