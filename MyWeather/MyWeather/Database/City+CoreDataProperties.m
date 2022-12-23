//
//  City+CoreDataProperties.m
//  MyWeather
//
//  Created by Stefano Ruggiero on 30/11/22.
//
//

#import "City+CoreDataProperties.h"

@implementation City (CoreDataProperties)

+ (NSFetchRequest<City *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"City"];
}

@dynamic latitude;
@dynamic longitude;
@dynamic name;

@end
