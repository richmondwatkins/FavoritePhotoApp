//
//  FavoritesViewController.m
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "FavoritesViewController.h"
#import "FavoriteCollectionViewCell.h"
#import  "InstagramImage.h"
@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *favoriteCollectionView;
@property NSMutableArray *mutableFavorites;
@end

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mutableFavorites = [NSMutableArray arrayWithArray:self.savedFavorites];
    [self.favoriteCollectionView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.mutableFavorites.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    FavoriteCollectionViewCell *cell = [FavoriteCollectionViewCell createCellForCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath];

   NSString *imageString = [self.mutableFavorites objectAtIndex:indexPath.row];

    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString: imageString]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    cell.imageView.image = image;


    return cell;
}
- (IBAction)dissMissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deletePhotoPanGesture:(UIPanGestureRecognizer *)panGesture{

    CGPoint vel = [panGesture velocityInView:self.view];

    if (vel.x > 0){
        if(panGesture.state == UIGestureRecognizerStateEnded){
            NSIndexPath *indexPath = [self.favoriteCollectionView indexPathForItemAtPoint:[panGesture locationInView:self.favoriteCollectionView]];
            NSMutableArray *indexPaths = [NSMutableArray array];
            [indexPaths addObject:indexPath];

            NSString *deleteFilePath = [self.mutableFavorites  objectAtIndex:indexPath.row];
            [self.mutableFavorites removeObjectAtIndex:indexPath.row];
            [self.favoriteCollectionView reloadData];

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *path=[documentsDirectory stringByAppendingPathComponent:deleteFilePath];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];

        }
    }
}

@end
