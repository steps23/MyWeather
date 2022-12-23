//
//  City.h
//  MyWeather
//
//  Created by Stefano Ruggiero on 10/12/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface City : NSObject

-(instancetype) initWithName:(NSString* ) name
                    latitude:(double) lat
                   longitude:(double) lon;

-(NSMutableArray*) toArray;

-(BOOL) cityInFavList:(NSMutableArray*) favList;

@property(nonatomic,strong) NSString* name;
@property double latitude;
@property double longitude;

@end

NS_ASSUME_NONNULL_END
