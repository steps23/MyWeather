//
//  City+CoreDataProperties.h
//  MyWeather
//
//  Created by Stefano Ruggiero on 30/11/22.
//
//

#import "City.h"


NS_ASSUME_NONNULL_BEGIN

@interface City (CoreDataProperties)

+ (NSFetchRequest<City *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
