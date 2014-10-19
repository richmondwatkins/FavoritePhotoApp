//
//  MapViewController.m
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/18/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property CLLocationManager *locationManger;
@property CLLocationCoordinate2D userLocation;
@property NSMutableArray *coordinatesArray;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property NSMutableArray *imagesArray;
@property int imagesCount;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imagesArray = [NSMutableArray array];
    self.coordinatesArray = [NSMutableArray array];
    self.locationManger = [[CLLocationManager alloc] init];
    [self.locationManger requestWhenInUseAuthorization];
    self.locationManger.delegate = self;
    [self.locationManger startUpdatingLocation];

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    for(CLLocation *location in locations){
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            self.userLocation = location.coordinate;
            [self.locationManger stopUpdatingLocation];
            [self findInstagramLocations];
            break;
        }
    }
}

-(void)findInstagramLocations{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/locations/search?lat=%0.3f&lng=%0.3f&count=10&client_id=de07f6709b3a418683cb2f43a2729de2", self.userLocation.latitude, self.userLocation.longitude]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        for(NSDictionary *result in results[@"data"]){
            [self findInstagramPhotosByLocation:(NSNumber *)result[@"id"]];
        }
    }];
}



-(void)findInstagramPhotosByLocation:(NSNumber *)locationId{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/locations/%@/media/recent?count=10&client_id=de07f6709b3a418683cb2f43a2729de2", locationId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *dataArry = results[@"data"];
        if (dataArry.count) {
            for (NSDictionary *tempDataDict in dataArry) {
                NSLog(@"%@", tempDataDict);
//[self downloadInstagramPhotos:(NSString *)tempDataDict[@"images"][@"standard_resolution"][@"url"] withLocation:(NSString *)tempDataDict[@"location"]];
                [self downloadInstagramPhotos:tempDataDict];
            }
        }
    }];
}


-(void)downloadInstagramPhotos:(NSDictionary *)instagramJson {
    NSURL *url = [NSURL URLWithString:instagramJson[@"images"][@"standard_resolution"][@"url"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        UIImage* image = [[UIImage alloc] initWithData:data];
        NSMutableDictionary *imageDictionary = [NSMutableDictionary new];
        [imageDictionary setObject:image forKey:@"image"];
        [imageDictionary setObject:instagramJson[@"location"] forKey:@"location"];
        [imageDictionary setObject:instagramJson[@"user"][@"username"] forKeyedSubscript:@"username"];
        [self.imagesArray addObject:imageDictionary];
        [self createMapAnnotations:(NSDictionary *) imageDictionary];
    }];
}


-(void)createMapAnnotations:(NSDictionary *)locationDictionary{
    NSString *latitude = locationDictionary[@"location"][@"latitude"];
    NSString *longitude = locationDictionary[@"location"][@"longitude"];
    CLLocationCoordinate2D coord;
    coord.latitude = [latitude doubleValue];
    coord.longitude = [longitude doubleValue];

    MKPointAnnotation *mkPoint = [MKPointAnnotation new];
    mkPoint.title = locationDictionary[@"username"];
    mkPoint.subtitle = locationDictionary[@"location"][@"name"];
    mkPoint.coordinate = coord;

    [self.mapView addAnnotation:mkPoint];

    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if (annotation == mapView.userLocation) {
        return nil;
    }

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];


    NSDictionary *imageDictionary = self.imagesArray.lastObject;
    UIImage *image = imageDictionary[@"image"];

    CGSize size = CGSizeMake(50, 50);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    pin.image = newImage;
    return pin;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    for (NSDictionary *imageDict in self.imagesArray) {
        if ([imageDict[@"location"][@"name"] isEqualToString:view.annotation.title]) {
            NSLog(@"%@", imageDict);
        }
    }
}



- (IBAction)dissMissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
