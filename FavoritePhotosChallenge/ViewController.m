//
//  ViewController.m
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/16/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewImageCell.h"
#import "InstagramImage.h"
@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *images;
@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.images = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/v1/tags/coffee/media/recent?client_id=de07f6709b3a418683cb2f43a2729de2&count=10&callback=callbackFunction=json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        for (NSDictionary *result in results[@"data"]) {
            NSURL *url = [NSURL URLWithString:result[@"images"][@"standard_resolution"][@"url"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];

            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                UIImage* image = [[UIImage alloc] initWithData:data];
                [self.images addObject:[InstagramImage createInstagramImage:image]];
                [self.collectionView reloadData];
            }];
        }
    }];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self queryInstagram:textField.text];
    return YES;
}


-(void)queryInstagram:(NSString *)query{
    [self.images removeAllObjects];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?client_id=de07f6709b3a418683cb2f43a2729de2&count=10&callback=callbackFunction=json", query]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        for (NSDictionary *result in results[@"data"]) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_async(queue, ^{
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:result[@"images"][@"standard_resolution"][@"url"]]];
                UIImage* image = [[UIImage alloc] initWithData:imageData];

                [self.images addObject:[InstagramImage createInstagramImage:image]];
                [self.collectionView reloadData];
            });
        }
        
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    InstagramImage *image = [self.images objectAtIndex:indexPath.row];
    cell.imageView.image = image.standardResolution;
    return cell;
}


@end
