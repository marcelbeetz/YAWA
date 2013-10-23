//
//  DetailViewController.h
//  YAWA
//
//  Created by Marcel Beetz on 18/10/13.
//  Copyright (c) 2013 Marcel Beetz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaysWeather.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *countryName;
@property (strong, nonatomic) DaysWeather *currentDay;
@property (strong, nonatomic) IBOutlet UIImageView *selectedDayImage;

// View Labels.
@property (strong, nonatomic) IBOutlet UILabel *lblCity;
@property (strong, nonatomic) IBOutlet UILabel *lblDay;
@property (strong, nonatomic) IBOutlet UILabel *lblMorningTemp;
@property (strong, nonatomic) IBOutlet UILabel *lblDayTemp;
@property (strong, nonatomic) IBOutlet UILabel *lblEveningTemp;
@property (strong, nonatomic) IBOutlet UILabel *lblNightTemp;
@property (strong, nonatomic) IBOutlet UILabel *lblMinTemp;
@property (strong, nonatomic) IBOutlet UILabel *lblMaxTemp;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;

@property (strong, nonatomic) id detailItem;

@end
