//
//  FavouriteListCities.m
//  MyWeather
//
//  Created by Stefano Ruggiero on 23/12/22.
//

#import "FavouriteListCities.h"


@interface FavouriteListCities ()

@property (strong, nonatomic) NSArray *paths;
@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong,nonatomic) NSString *favListFileName;

@end


@implementation FavouriteListCities

-(instancetype) init{
    if(self = [super init]) {
        self.paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [self.paths objectAtIndex:0];
        self.favListFileName = [self.documentsDirectory stringByAppendingPathComponent:@"favListFile.json"];
        self.list = [[NSMutableArray alloc] initWithContentsOfFile: self.favListFileName];
        if(self.list == nil){
            //If Array file didn't exist creates a new one
            self.list = [[NSMutableArray alloc] init];
            [self.list writeToFile:self.favListFileName atomically:YES];
        }
    }
    return self;
}

-(void) addCityArray:(City*) city{
    [self.list addObject:city.toArray];
}

-(void) removeCityArray:(City*) city{
    [self.list removeObject:city.toArray];
}

-(void) updateFile{
    [self.list writeToFile:self.favListFileName atomically:YES];
}


@end
