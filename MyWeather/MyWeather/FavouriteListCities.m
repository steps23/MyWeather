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
    [self.list addObject: [self cityToArray:city]];
}

-(void) removeCityArray:(City*) city{
    [self.list removeObject:[self cityToArray:city]];
}

-(void) updateFile{
    [self.list writeToFile:self.favListFileName atomically:YES];
}

-(NSMutableArray*) cityToArray:(City*)city{
    NSMutableArray* array= [[NSMutableArray alloc] init];
    [array addObject:city.name];
    [array addObject:[NSString stringWithFormat:@"%f",city.latitude]];
    [array addObject:[NSString stringWithFormat:@"%f",city.longitude]];
    //0=name 1=latitude 2=longitude
    return array;
}

-(BOOL) cityInFavList:(City*) city{
    for (int i = 0; i < [self.list count]; i++)
    {
        NSArray* cityArray =[[NSArray alloc]initWithArray:[self.list objectAtIndex:i]];
        //double latList=[[cityArray objectAtIndex:1] doubleValue];
        //double lonList=[[cityArray objectAtIndex:2] doubleValue];
        if([cityArray containsObject:[NSString stringWithFormat:@"%f",city.latitude]] &&
           [cityArray containsObject:[NSString stringWithFormat:@"%f",city.longitude]]){
            return true;
        }
        
    }
    return false;
}


@end
