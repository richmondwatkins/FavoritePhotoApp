//
//  MapViewController.m
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/18/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "MapViewController.h"
#import "PhotoDetailsViewController.h"
#import <MapKit/MapKit.h>
@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property CLLocationManager *locationManger;
@property CLLocationCoordinate2D userLocation;
@property NSMutableArray *coordinatesArray;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property NSMutableArray *imagesArray;
@property int imagesCount;
@property NSDictionary *selectedPhoto;
@property (nonatomic, strong) NSURLSession *session;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

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
    self.tableView.hidden = YES;
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




    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/locations/search?lat=%0.3f&lng=%0.3f&count=20&distance=5000&client_id=de07f6709b3a418683cb2f43a2729de2", self.userLocation.latitude, self.userLocation.longitude]];


    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        for(NSDictionary *result in results[@"data"]){
            [self findInstagramPhotosByLocation:(NSNumber *)result[@"id"]];
        }
    }];
}



-(void)findInstagramPhotosByLocation:(NSNumber *)locationId{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/locations/%@/media/recent?count=20&client_id=de07f6709b3a418683cb2f43a2729de2", locationId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *dataArry = results[@"data"];
        if (dataArry.count) {
            for (NSDictionary *tempDataDict in dataArry) {
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
        [imageDictionary setObject:instagramJson[@"user"] forKeyedSubscript:@"user"];
        [imageDictionary setObject:[self formatTime:instagramJson[@"created_time"]] forKey:@"time"];
        [self createMapAnnotations:(NSDictionary *) imageDictionary];
        NSLog(@"%@", imageDictionary);
    }];
}

-(NSString *)formatTime:(NSNumber *)timeMil{
    NSLog(@"%@", timeMil);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:([timeMil doubleValue] / 1000.0)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSString *resultString = [formatter stringFromDate:date];
    return resultString;
}

-(void)createMapAnnotations:(NSDictionary *)locationDictionary{
    NSString *latitude = locationDictionary[@"location"][@"latitude"];
    NSString *longitude = locationDictionary[@"location"][@"longitude"];
    CLLocationCoordinate2D coord;
    coord.latitude = [latitude doubleValue];
    coord.longitude = [longitude doubleValue];

    MKPointAnnotation *mkPoint = [MKPointAnnotation new];
    mkPoint.title = locationDictionary[@"user"][@"username"];
    mkPoint.subtitle = locationDictionary[@"time" ];
    mkPoint.coordinate = coord;

    [self findUserProfilePicture:locationDictionary putonMapAfterWith:mkPoint];
}

-(void)findUserProfilePicture:(NSDictionary *)userDict putonMapAfterWith:(MKPointAnnotation *)mkPoint{
    NSURL *url = [NSURL URLWithString:userDict[@"user"][@"profile_picture"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        UIImage* image = [[UIImage alloc] initWithData:data];
        [userDict setValue:image forKey:@"profile_photo"];
        [self.imagesArray addObject:userDict];

        [self.mapView addAnnotation:mkPoint];
        [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    }];
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

    UIImageView *profileImageView = [[UIImageView alloc] initWithImage:imageDictionary[@"profile_photo"]];
    profileImageView.frame = CGRectMake(0,0,50,50);

    pin.leftCalloutAccessoryView = profileImageView;


    return pin;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.imagesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstaCell"];

    NSDictionary *imageDict = [self.imagesArray objectAtIndex:indexPath.row];
    cell.imageView.image = imageDict[@"image"];

    cell.textLabel.text = imageDict[@"user"][@"full_name"];

    return cell;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    for (NSDictionary *imageDict in self.imagesArray) {
        if ([imageDict[@"user"][@"username"] isEqualToString:view.annotation.title] && [imageDict[@"time"]isEqualToString:view.annotation.subtitle]) {
            self.selectedPhoto = imageDict;
            [self performSegueWithIdentifier:@"photoDetails" sender:self];
        }
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"photoDetails"]) {
        PhotoDetailsViewController *photoDetailsCtrl = [segue destinationViewController];
        photoDetailsCtrl.photoDictionary = self.selectedPhoto;
    }
}

- (IBAction)toggleSegmentControl:(UISegmentedControl *)segment {

    if (segment.selectedSegmentIndex) {
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }else{
        self.tableView.hidden = YES;
    }
}

- (IBAction)dissMissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
