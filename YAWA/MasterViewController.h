//
//  MasterViewController.h
//  YAWA
//
//  Created by Marcel Beetz on 18/10/13.
//  Copyright (c) 2013 Marcel Beetz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
