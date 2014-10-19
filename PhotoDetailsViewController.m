//
//  PhotoDetailsViewController.m
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/18/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "PhotoDetailsViewController.h"

@interface PhotoDetailsViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation PhotoDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoView.image = self.photoDictionary[@"image"];
    self.avatarImageView.image = self.photoDictionary[@"profile_photo"];
    NSLog(@"%@", self.photoDictionary);
}
- (IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
