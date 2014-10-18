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

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/locations/search?lat=%f&lng=%f&client_id=de07f6709b3a418683cb2f43a2729de2", self.userLocation.latitude, self.userLocation.longitude]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
//        NSLog(@" FIRST ROUND OF RESULTS %@", results);
        for(NSDictionary *result in results[@"data"]){
            NSLog(@" ID ID ID ID ID ID ID ID %@", result[@"id"]);
            [self findInstagramPhotosByLocation:(NSNumber *)result[@"id"]];
        }
    }];
}



-(void)findInstagramPhotosByLocation:(NSNumber *)locationId{
    NSLog(@"LOCATION ID %@", locationId);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/locations/%@/media/recent?client_id=de07f6709b3a418683cb2f43a2729de2", locationId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//        NSLog(@"RESULTS %@", results);
        NSArray *dataArry = results[@"data"];
//        NSLog(@"THIS IS THE DATA ARRAY %@", dataArry);

        for(NSDictionary *dic in dataArry){
            NSLog(@"TEMP DIC %@", dic);
        }

//            for (int i = 0; i <= dataArry.count; i++) {
//                NSLog(@" DATA ITMEMMMMM %@", dataArry[i]);
//                ////            NSDictionary *tempDataDict = dataArry[i];
//                ////            [self downloadInstagramPhotos:(NSString *)tempDataDict[@"images"][@"standard_resolution"][@"url"] withLocation:(NSString *)tempDataDict[@"location"] andCount:i];
//            }

//        for(NSDictionary *photoDict in results[@"data"]){
//            [self.coordinatesArray addObject:photoDict[@"location"]];
//            [self downloadInstagramPhotos:(NSString *)photoDict[@"images"][@"standard_resolution"][@"url"] withLocation:(NSString *)photoDict[@"location"]];
//        }
    }];
}


-(void)downloadInstagramPhotos:(NSString *)photoURL withLocation:(NSString *)location andCount:(int)count{
    NSURL *url = [NSURL URLWithString:photoURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        UIImage* image = [[UIImage alloc] initWithData:data];
        NSDictionary *imageDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:image, @"image", location, "location", count, "index", nil];
//        [self.imagesArray addObject:imageDictionary];
        [self createMapAnnotations:(NSDictionary *) imageDictionary];
    }];
}


-(void)createMapAnnotations:(NSDictionary *)locationDictionary{
    NSLog(@"%@", locationDictionary);
//    for(NSDictionary *imageLocation in self.coordinatesArray){
//        NSString *latitude = imageLocation[@"latitude"];
//        NSString *longitude = imageLocation[@"longitude"];
//        CLLocationCoordinate2D coord;
//        coord.latitude = [latitude doubleValue];
//        coord.longitude = [longitude doubleValue];
//
//        MKPointAnnotation *mkPoint = [MKPointAnnotation new];
//        mkPoint.title = imageLocation[@"name"];
//        mkPoint.coordinate = coord;
//
//        [self.mapView addAnnotation:mkPoint];
//
//
//        NSLog(@"%lu", (unsigned long)self.coordinatesArray.count);
//    }
//    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if (annotation == mapView.userLocation) {
        return nil;
    }

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView  = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];


//    UIImage *image = [self.imagesArray objectAtIndex:self.imagesArray.count -1];

//    UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
//    myImageView.frame = CGRectMake(0,0,50,50);
//
//    pin.leftCalloutAccessoryView = myImageView;

//    pin.image = image;

    return pin;
}



- (IBAction)dissMissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
