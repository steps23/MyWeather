//
//  City+MapAnnotation.m
//  MyWeather
//
//  Created by Stefano Ruggiero on 22/12/22.
//

#import "City+MapAnnotation.h"

@implementation City(MapAnnotation)

-(CLLocationCoordinate2D) coordinate{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.latitude;
    coordinate.longitude = self.longitude;
    return coordinate;
}

- (NSString *)title {
    return self.name;
}

@end
