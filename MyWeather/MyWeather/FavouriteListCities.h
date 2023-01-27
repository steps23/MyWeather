//
//  FavouriteListCities.h
//  MyWeather
//
//  Created by Stefano Ruggiero on 23/12/22.
//

#import <Foundation/Foundation.h>
#import "City.h"

NS_ASSUME_NONNULL_BEGIN

@interface FavouriteListCities : NSObject


-(void) updateFile;
-(void) addCityArray:(City*) city;
-(void) removeCityArray:(City*) city;
-(NSMutableArray*) cityToArray:(City*)city;
-(BOOL) cityInFavList:(City*) city;


@property (strong,nonatomic) NSMutableArray *list;

@end

NS_ASSUME_NONNULL_END
