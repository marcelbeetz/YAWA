//
//  DetailViewController.m
//  YAWA
//
//  Created by Marcel Beetz on 18/10/13.
//  Copyright (c) 2013 Marcel Beetz. All rights reserved.
//

#import "DetailViewController.h"
#import "AsyncImageView.h"

@implementation DetailViewController
@synthesize cityName, countryName, currentDay, selectedDayImage;
@synthesize lblDay, lblMinTemp, lblMaxTemp, lblDescription;
@synthesize lblMorningTemp, lblDayTemp, lblEveningTemp, lblNightTemp;
#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        //[self configureView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setControls];
}

-(void) setControls {
    // Break down JSON data.
    //NSDictionary *temps = [selectedCityWeatherInfo objectForKey:@"temp"];
    //NSArray *weatherArr = [selectedCityWeatherInfo objectForKey:@"weather"];
    //NSDictionary *weather = [weatherArr objectAtIndex:0];
    
    self.title = [NSString stringWithFormat:@"%@, %@", cityName, countryName];
    
    // Uses AsyncImageView to download images asynchronously.
    NSString *imagesurlloc = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", currentDay.icon];
    [selectedDayImage setImage:[UIImage imageNamed:@"defaultimage.png"]];
    [selectedDayImage setImageURL:[NSURL URLWithString:imagesurlloc]];
    
    lblDay.text = [NSString stringWithFormat:@"%@", currentDay.day];
    lblMinTemp.text = [NSString stringWithFormat:@"Low: %.0lf%@", currentDay.minTemp,  @"\u00B0"];
    lblMaxTemp.text = [NSString stringWithFormat:@"High: %.0lf%@", currentDay.maxTemp,  @"\u00B0"];
    lblDescription.text = [NSString stringWithFormat:@"Description:\n%@", currentDay.description];
    lblMorningTemp.text = [NSString stringWithFormat:@"Morning: %.0lf%@", currentDay.morningTemp,  @"\u00B0"];
    lblDayTemp.text = [NSString stringWithFormat:@"Day: %.0lf%@", currentDay.dayTemp,  @"\u00B0"];
    lblEveningTemp.text = [NSString stringWithFormat:@"Evening: %.0lf%@", currentDay.eveningTemp,  @"\u00B0"];
    lblNightTemp.text = [NSString stringWithFormat:@"Night: %.0lf%@", currentDay.nightTemp,  @"\u00B0"];
}
@end