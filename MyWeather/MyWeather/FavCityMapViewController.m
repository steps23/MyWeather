//
//  FavCityMapViewController.m
//  MyWeather
//
//  Created by Stefano Ruggiero on 22/12/22.
//

#import "FavCityMapViewController.h"
#import <MapKit/MapKit.h>
#import "City+MapAnnotation.h"
#import "FavouriteListCities.h"

@interface FavCityMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;

@property (nonatomic,strong) FavouriteListCities* favList;

@end

@implementation FavCityMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.map.delegate = self;
    [self setupFavList];
    [self addCityAnnotations];
    // Do any additional setup after loading the view.
}

-(void) addCityAnnotations{
    for (int i = 0; i < [self.favList.list count]; i++)
    {
        NSArray* cityArray =[[NSArray alloc]initWithArray:[self.favList.list objectAtIndex:i]];
        NSString* name= [cityArray objectAtIndex:0];
        double latList=[[cityArray objectAtIndex:1] doubleValue];
        double lonList=[[cityArray objectAtIndex:2] doubleValue];
        City* city = [[City alloc]initWithName:name latitude:latList longitude:lonList];
        [self.map addAnnotation:city];
    }
}

-(void) setupFavList{
    self.favList = [[FavouriteListCities alloc]init];
}

// setup the annotation that are associated with each map's pin
- (MKAnnotationView *) mapView:(MKMapView *)mapView
             viewForAnnotation:(id<MKAnnotation>)annotation{
    static NSString *AnnotationIdentifer = @"cityAnnotation";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifer];
    if(!view){
        view = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:AnnotationIdentifer];
        view.canShowCallout = YES;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    //default view of pin annotation
    imageView.image = [UIImage imageNamed:@"clear-day"];
    view.leftCalloutAccessoryView = imageView;
    view.leftCalloutAccessoryView.backgroundColor = [UIColor blackColor];
    return view;
}


- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    if([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]){
        __block UIImageView *imageView = (UIImageView *)view.leftCalloutAccessoryView; //this object saves what appends inside a block
        id<MKAnnotation> annotation = view.annotation;
        if([annotation isKindOfClass:[City class]]) { //introspection
            dispatch_queue_t queue = dispatch_queue_create("forecastWeatherAnnotation", NULL);
            City *city = (City *)annotation;
            dispatch_async(queue, ^{
                NSString *urlString = [NSString stringWithFormat: @"https://api.open-meteo.com/v1/forecast?latitude=%f&longitude=%f&current_weather=true&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=UTC",city.latitude,city.longitude];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:[NSURL URLWithString:urlString]];
                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self updateCityAnnotation:data image:imageView];
                        });
                    }] resume];
            });
        }
        
    }
}

-(void) updateCityAnnotation:(NSData *)data
                       image:(UIImageView *)imageView{
    id value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *weather_response = (NSDictionary *)value;
    NSDictionary* daily=[weather_response valueForKey:@"daily"];
    NSArray* weathercode=[daily valueForKey:@"weathercode"];
    imageView.image = [UIImage imageNamed:[self weathercodeToString:[[weathercode objectAtIndex:0] intValue]]];
}

-(NSString*) weathercodeToString:(int) weathercode{
    NSString *weathercodeString = @"";
    if(weathercode == 0){
        weathercodeString  = @"clear-day";
    }
    else if(weathercode == 1 || weathercode == 2 || weathercode == 3) {
        weathercodeString  = @"cloudy-day";
    }
    else if(weathercode == 45 || weathercode == 48){
        weathercodeString  = @"fog";
    }
    else if(weathercode == 51 || weathercode == 53 || weathercode == 55){
        weathercodeString  = @"drizzle";
    }
    else if(weathercode == 56 || weathercode == 57 || weathercode == 71 || weathercode == 73 || weathercode == 75 || weathercode == 77 || weathercode == 85 || weathercode == 86 ){
        weathercodeString  = @"snow";
    }
    else if(weathercode == 61 || weathercode == 63 || weathercode == 65 || weathercode == 80 || weathercode == 81 || weathercode == 82){
        weathercodeString  = @"rain";
    }
    else if(weathercode == 66 || weathercode == 67){
        weathercodeString  = @"sleet";
    }
    else if(weathercode == 95 || weathercode == 96 || weathercode== 99){
        weathercodeString  = @"storm";
    }
    return weathercodeString;
}

@end
