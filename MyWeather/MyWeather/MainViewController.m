//
//  MainViewController.m
//  MyWeather
//
//  Created by Stefano Ruggiero on 12/11/22.
//

#define BACKGROUND_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#import "MainViewController.h"
#import <MapKit/MapKit.h>
#import "City.h"
#import "FavouriteListCities.h"



@interface MainViewController ()<CLLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet UILabel *cityName;
@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UIImageView *imgToday;

@property (weak, nonatomic) IBOutlet UILabel *day1;
@property (weak, nonatomic) IBOutlet UIImageView *imgDay1;
@property (weak, nonatomic) IBOutlet UILabel *minTempDay1;
@property (weak, nonatomic) IBOutlet UILabel *maxTempDay1;

@property (weak, nonatomic) IBOutlet UILabel *day2;
@property (weak, nonatomic) IBOutlet UIImageView *imgDay2;
@property (weak, nonatomic) IBOutlet UILabel *minTempDay2;
@property (weak, nonatomic) IBOutlet UILabel *maxTempDay2;

@property (weak, nonatomic) IBOutlet UILabel *day3;
@property (weak, nonatomic) IBOutlet UIImageView *imgDay3;
@property (weak, nonatomic) IBOutlet UILabel *minTempDay3;
@property (weak, nonatomic) IBOutlet UILabel *maxTempDay3;

@property (weak, nonatomic) IBOutlet UISearchBar *searchCityBar;
@property (weak, nonatomic) IBOutlet UIButton *searchCityButton;

@property (weak, nonatomic) IBOutlet UIButton *currentPositionButton;

@property (weak, nonatomic) IBOutlet UIButton *favCityButton;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property(nonatomic,strong) City* city;

@property (nonatomic,strong) FavouriteListCities* favList;

@end

@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self registerForCitySelected];
    self.searchCityBar.text=@"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add tap to dismiss kaybord by tapping outside
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
    
    self.city= [[City alloc]init];
    [self setUpLocationManager];
    [self.locationManager requestWhenInUseAuthorization];
    
    //_cityName.text= [NSString stringWithFormat:@"%@",_locationManager.location];
    self.favList= [[FavouriteListCities alloc]init]; //get the fav list from the file
    CLLocation *currentLocation = _locationManager.location;
    //currentLocation.coordinate.latitude
    [self updateForecastWeather:currentLocation];
    
}

//start location manager
-(CLLocationManager *)locationManager {
    if(!_locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    return _locationManager;
}

-(void) setUpLocationManager {
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
}

//when device's location update -> set new current city name,lat,lon
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    [self updateForecastWeather:currentLocation];
}

-(void) updateForecastWeather:(CLLocation*) currentLocation{
    //[self updateCityLabel:currentLocation];
    self.city.latitude= currentLocation.coordinate.latitude;
    self.city.longitude= currentLocation.coordinate.longitude;
    double lat= self.city.latitude;
    double lon= self.city.longitude;
    dispatch_queue_t queue = dispatch_queue_create("forecastWeather", NULL);
    dispatch_async(queue, ^{
        NSString *urlString = [NSString stringWithFormat: @"https://api.open-meteo.com/v1/forecast?latitude=%f&longitude=%f&current_weather=true&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=UTC", lat, lon];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateGuiForecast:data];
                    [self updateCityLabel:currentLocation];
                    [self setImageCurrentPositionButtonFill];
                    [self updateFavCityButton];
                });
            }] resume];
        
        //NSURL *url = [NSURL URLWithString:urlString];
        //NSData *data = [NSData dataWithContentsOfURL:url];
    });
}

-(void) updateCityLabel:(CLLocation*) currentLocation {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    dispatch_queue_t queue = dispatch_queue_create("getCityNameCurrentLocation", NULL);
    dispatch_async(queue, ^{
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks lastObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.city.name=placemark.locality;
                self.cityName.text = self.city.name;
            });
        }];
    });
    
    
}

-(void) updateForecastWeatherWithLatitude:(double)latitude
                             andLongitude:(double)longitude{
    dispatch_queue_t queue = dispatch_queue_create("forecastWeatherLatLon", NULL);
    dispatch_async(queue, ^{
        NSString *urlString = [NSString stringWithFormat: @"https://api.open-meteo.com/v1/forecast?latitude=%f&longitude=%f&current_weather=true&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=UTC", latitude, longitude];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateGuiForecast:data];
                    [self updateFavCityButton];
                    [self setImageCurrentPositionButtonEmpty];
                });
            }] resume];
    });
}


-(void) printDictonary:(NSDictionary*) dictionary {
    for(NSString *key in [dictionary allKeys]) {
        //NSLog(@"%@",[weather_response objectForKey:key]);
        id value = dictionary[key];
        NSLog(@"Value for key %@: %@ ",key, value);
    }
}

//get the day name from a string date
-(NSString*) getDayName:(NSString*) dateString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:dateString];
    [dateFormat setDateFormat:@"EEEE"];
    NSString *dayName = [dateFormat stringFromDate:date];
    //NSString *dayName = [dateFormatter stringFromDate:[time objectAtIndex:1]];
    return dayName;
}

-(void)updateForecastBySearch:(NSString*) citySearched{
    //setup the searchrequest from the text inserted (citySearched)
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    [searchRequest setNaturalLanguageQuery: citySearched ];
    // Create the local search to perform the search
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    dispatch_queue_t queue = dispatch_queue_create("updateForecastBySearch", NULL);
    dispatch_async(queue, ^{
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            if (!error) {
                MKMapItem *mapItem = [[response mapItems] firstObject];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.city.latitude=mapItem.placemark.location.coordinate.latitude;
                        self.city.longitude=mapItem.placemark.location.coordinate.longitude;
                        if(mapItem.placemark.locality != nil) {
                            self.city.name=mapItem.placemark.locality;
                            [self updateForecastWeatherWithLatitude:self.city.latitude andLongitude:self.city.longitude];
                            self.cityName.text = self.city.name;
                            [self setImageCurrentPositionButtonEmpty];
                            [self updateFavCityButton];
                        }
                        else{
                            [self showAlert]; //if we cant't get the city name an alert pops up
                        }
                    });
                
            } else {
                NSLog(@"Search Request Error: %@", [error localizedDescription]);
                [self showAlert]; //if we get an error an alert pops up
            }
        }];
    });
}

//dismiss the keybord touching button
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


//dismiss the keybord touching elsewhere
-(void)dismissKeyboard {
       [self.searchCityBar resignFirstResponder];
}

- (IBAction)searchButtonPressed:(id)sender {
    //[self resignFirstResponder];
    NSString* citySearched=self.searchCityBar.text;
    [self updateForecastBySearch:citySearched];
}

-(void)showAlert{
    UIAlertController* alert= [UIAlertController alertControllerWithTitle:@"Attenzione" message:@"Città non trovata" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)currentPositionButtonPressed:(id)sender {
    CLLocation *currentLocation = _locationManager.location;
    //currentLocation.coordinate.latitude
    [self updateForecastWeather:currentLocation];
}

-(void) setImageCurrentPositionButtonFill{
    [self.currentPositionButton setImage: [UIImage systemImageNamed:@"location.fill"] forState: UIControlStateNormal];
}

-(void) setImageCurrentPositionButtonEmpty{
    [self.currentPositionButton setImage: [UIImage systemImageNamed:@"location"] forState: UIControlStateNormal];
}

- (IBAction)favCityButtonPressed:(id)sender {
    if(![self.favList cityInFavList:self.city]){
        if(self.city.name != nil){
            [self.favList addCityArray:self.city];
        }
        else{
            NSLog(@"%@  %f  %f",self.city.name,self.city.latitude,self.city.longitude);
        }
    }
    else{
        [self.favList removeCityArray:self.city];
    }
    [self.favList updateFile];
    [self updateFavCityButton];
}

//verify if the city is in the favourites list or not and change the button
-(void) updateFavCityButton{
    if([self.favList cityInFavList:self.city]){
        [self setImageFavCityButtonFill];
    }
    else{
        [self setImageFavCityButtonEmpty];
    }
}

-(void) setImageFavCityButtonFill{
    [self.favCityButton setTitle:@"Rimuovi dai preferiti" forState:UIControlStateNormal];
    [self.favCityButton setImage: [UIImage systemImageNamed:@"heart.fill"] forState: UIControlStateNormal];
}

-(void) setImageFavCityButtonEmpty{
    [self.favCityButton setTitle:@"Aggiungi ai preferiti" forState:UIControlStateNormal];
    [self.favCityButton setImage: [UIImage systemImageNamed:@"heart"] forState: UIControlStateNormal];
}

//cacth the notification for the city selected in the table view
- (void)cityselected:(NSNotification *)notification{
    if ([notification.object isKindOfClass:[City class]]) //introspection
    {
        self.city = [City alloc] ;
        self.city = notification.object;
        self.cityName.text = self.city.name;
        [self updateForecastWeatherWithLatitude:self.city.latitude andLongitude:self.city.longitude];
        //NSLog(@"notification received, self city: %@ %f %f", self.city.name,self.city.latitude,self.city.longitude);
    }
}

- (void)registerForCitySelected{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(cityselected:)
                                                 name: @"citySelected"
                                               object: nil];
}
    
-(void) updateGuiForecast:(NSData *)data{
    id value = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *weather_response = (NSDictionary *)value;
    NSDictionary* current_weather= [weather_response valueForKey:@"current_weather"];
    NSDictionary* daily=[weather_response valueForKey:@"daily"];
    NSArray* temperature_2m_max=[daily valueForKey:@"temperature_2m_max"];
    NSArray* temperature_2m_min=[daily valueForKey:@"temperature_2m_min"];
    NSArray* time=[daily valueForKey:@"time"];
    NSArray* weathercode=[daily valueForKey:@"weathercode"];
    //[self printDictonary:weather_response];
    self.temp.text=[NSString stringWithFormat:@"%@ C°",[current_weather valueForKey:@"temperature"]];
    self.imgToday.image=[UIImage imageNamed:[self weathercodeToString:[[weathercode objectAtIndex:0] intValue]]];
    self.day1.text=[self getDayName:[time objectAtIndex:1]];
    self.minTempDay1.text = [NSString stringWithFormat:@"min %@ C°",[temperature_2m_min objectAtIndex:1]];
    self.maxTempDay1.text= [NSString stringWithFormat:@"max %@ C°",[temperature_2m_max objectAtIndex:1]];
    self.imgDay1.image =[UIImage imageNamed:[self weathercodeToString:[[weathercode objectAtIndex:1] intValue]]];
    self.day2.text=[self getDayName:[time objectAtIndex:2]];
    self.minTempDay2.text = [NSString stringWithFormat:@"min %@ C°",[temperature_2m_min objectAtIndex:2]];
    self.maxTempDay2.text= [NSString stringWithFormat:@"max %@ C°",[temperature_2m_max objectAtIndex:2]];
    self.imgDay2.image =[UIImage imageNamed:[self weathercodeToString:[[weathercode objectAtIndex:2] intValue]]];
    self.day3.text=[self getDayName:[time objectAtIndex:3]];
    self.minTempDay3.text = [NSString stringWithFormat:@"min %@ C°",[temperature_2m_min objectAtIndex:3]];
    self.maxTempDay3.text= [NSString stringWithFormat:@"max %@ C°",[temperature_2m_max objectAtIndex:3]];
    self.imgDay3.image =[UIImage imageNamed:[self weathercodeToString:[[weathercode objectAtIndex:3] intValue]]];
}

//get the name of the image by the weathercode
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


/*
-(void) setLatitudeLongitude:(NSString*) stringLocation {
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    [searchRequest setNaturalLanguageQuery: stringLocation ];
    // Create the local search to perform the search
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    dispatch_queue_t queue = dispatch_queue_create("setLatitudeLongitude", NULL);
    dispatch_async(queue, ^{
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
            if (!error) {
                MKMapItem *mapItem = [[response mapItems] lastObject];
                    //NSLog(@"MapItem: %@", mapItem);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //self.cityName.text = [NSString stringWithFormat:@"%f",mapItem.placemark.location.coordinate.latitude];
                        self.city.latitude=mapItem.placemark.location.coordinate.latitude;
                        self.city.longitude=mapItem.placemark.location.coordinate.longitude;
                    });
                
            } else {
                NSLog(@"Search Request Error: %@", [error localizedDescription]);
            }
        }];
    });
}*/

@end
