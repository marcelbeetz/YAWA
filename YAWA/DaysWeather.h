//
//  DaysWeather.h
//  YAWA
//
//  Created by Marcel Beetz on 23/10/13.
//  Copyright (c) 2013 Marcel Beetz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DaysWeather : NSObject {
    
}

@property(strong, nonatomic) NSString *day;
@property(strong, nonatomic) NSString *description;
@property(strong, nonatomic) NSString *icon;
@property(nonatomic) float morningTemp;
@property(nonatomic) float dayTemp;
@property(nonatomic) float eveningTemp;
@property(nonatomic) float nightTemp;
@property(nonatomic) float minTemp;
@property(nonatomic) float maxTemp;

@end
