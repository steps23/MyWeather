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

-(NSMutableArray*) toArray{
    NSMutableArray* array= [[NSMutableArray alloc] init];
    [array addObject:self.name];
    [array addObject:[NSString stringWithFormat:@"%f",self.latitude]];
    [array addObject:[NSString stringWithFormat:@"%f",self.longitude]];
    //0=name 1=latitude 2=longitude
    return array;
}

-(BOOL) cityInFavList:(NSMutableArray*) favList{
    for (int i = 0; i < [favList count]; i++)
    {
        NSArray* cityArray =[[NSArray alloc]initWithArray:[favList objectAtIndex:i]];
        //double latList=[[cityArray objectAtIndex:1] doubleValue];
        //double lonList=[[cityArray objectAtIndex:2] doubleValue];
        if([cityArray containsObject:[NSString stringWithFormat:@"%f",self.latitude]] &&
           [cityArray containsObject:[NSString stringWithFormat:@"%f",self.longitude]]){
            return true;
        }
        
    }
    return false;
}

@end
