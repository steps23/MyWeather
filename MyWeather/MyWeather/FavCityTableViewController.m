//
//  FavCityTableViewController.m
//  MyWeather
//
//  Created by Stefano Ruggiero on 09/12/22.
//

#import "FavCityTableViewController.h"
#import "City.h"
#import "FavouriteListCities.h"

@interface FavCityTableViewController ()

@property (nonatomic,strong) City* citySelected;

@property (nonatomic,strong) FavouriteListCities* favList;

@end

@implementation FavCityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _citySelected = [[City alloc]init];
    [self setupFavList];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(updateView:)
                                                     name: @"ForecastViewUpdated"
                                                   object: nil];
   
}

-(void) setupFavList{
    self.favList = [[FavouriteListCities alloc]init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favList.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell" forIndexPath:indexPath];
    //0=name 1=latitude 2=longitude
    NSString* cityName= [[self.favList.list objectAtIndex:indexPath.row] objectAtIndex:0];
    double latitude= [[[self.favList.list objectAtIndex:indexPath.row] objectAtIndex:1] doubleValue];
    double longitude=  [[[self.favList.list objectAtIndex:indexPath.row] objectAtIndex:2] doubleValue];
    City* city = [[City alloc]initWithName:cityName latitude:latitude longitude:longitude];
    cell.textLabel.text = city.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cityName= [[self.favList.list objectAtIndex:indexPath.row] objectAtIndex:0];
    double latitude= [[[self.favList.list objectAtIndex:indexPath.row] objectAtIndex:1] doubleValue];
    double longitude=  [[[self.favList.list objectAtIndex:indexPath.row] objectAtIndex:2] doubleValue];
    City* city = [[City alloc]initWithName:cityName latitude:latitude longitude:longitude];
    self.citySelected = city;
    [NSNotificationCenter.defaultCenter postNotificationName:@"citySelected" object:self.citySelected];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateView:(NSNotification *)notification{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
