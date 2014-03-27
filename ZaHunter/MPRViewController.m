//
//  MPRViewController.m
//  ZaHunter
//
//  Created by Manas Pradhan on 3/26/14.
//  Copyright (c) 2014 Manas Pradhan. All rights reserved.
//

#import "MPRViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MPRViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
{
    NSArray     *pizzaJoints;

}
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property CLLocationManager *locationManager;
@end

@implementation MPRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    //[self.myTableView reloadData];
}

- (void)locationManager: (CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)locationManager: (CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            //self.myLabel.text = @"Location found, Reverse geocoding...";
            [self startReverseGeoCode:location];
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void)startReverseGeoCode: (CLLocation*) location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        //self.myLabel.text = [NSString stringWithFormat:@"%@", placemarks.firstObject];
        [self findPizzaJoints:placemarks.firstObject];
    }];
}

- (void)findPizzaJoints: (CLPlacemark *)placemark
{
    self.title = @"Pizza Joints";
    MKLocalSearchRequest* request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"Pizza";
    request.region = MKCoordinateRegionMake(placemark.location.coordinate, MKCoordinateSpanMake(1, 1));
    
    MKLocalSearch* search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         NSArray *mapItems = response.mapItems;
         pizzaJoints = mapItems;
         [self.myTableView reloadData];
     }];
}

- (void)showDirections: (MKMapItem*) destinationMapItem
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destinationMapItem;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.firstObject;
        //self.myLabel.text = @"";
        
//        for (MKRouteStep *step in route.steps)
//        {
//            self.myLabel.text = [NSString stringWithFormat:@"%@\n%@", self.myLabel.text, step.instructions];
//        }
    }];
}

-(NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [pizzaJoints count];
}

-(UITableViewCell*)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Returns table cell containing information from the MeetUpEvent
    
    UITableViewCell *cell            = [tableView dequeueReusableCellWithIdentifier:@"PizzaCellID"];
    MKMapItem *pizzaPlaces           = pizzaJoints[indexPath.row];
    
    int distance = roundf([pizzaPlaces.placemark.location distanceFromLocation:self.locationManager.location]);
    NSString *dist= [NSString stringWithFormat:@"Crow's Distance:  %i meters", distance];
    
    cell.textLabel.text = pizzaPlaces.name;
    cell.detailTextLabel.text = dist;
    
    return cell;
}

- (IBAction)pizzaSearch:(id)sender
{
    [self.locationManager startUpdatingLocation];
}


@end
