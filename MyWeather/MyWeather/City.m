//
//  City.m
//  MyWeather
//
//  Created by Stefano Ruggiero on 10/12/22.
//

#import "City.h"

@implementation City

-(instancetype) initWithName:(NSString* ) name
                    latitude:(double) lat
                   longitude:(double) lon {
    if(self = [super init]) {
           _name = [name copy];
           _latitude = lat;
           _longitude = lon;
       }
       return self;
}



@end
