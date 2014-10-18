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
#import "FavoritesViewController.h"
@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, CollectionViewImageCellDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray *images;
@property NSMutableArray *cells;
@property CollectionViewImageCell *selectedCell;
@property NSMutableDictionary *favoritesDictionary;
@property NSMutableArray *favoritesArray;
@property NSArray *saveFavorites;
@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];


    self.saveFavorites = [self load];
    if (self.saveFavorites) {
        [self performSegueWithIdentifier:@"favorites" sender:self];
    }else{
        [self setUpView];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self setUpView];
}

-(void)setUpView{
    [self.collectionView setPagingEnabled:YES];
    self.images = [[NSMutableArray alloc] init];
    self.cells = [[NSMutableArray alloc] init];
    self.favoritesDictionary = [[NSMutableDictionary alloc] init];
    self.favoritesArray = [[NSMutableArray alloc] init];

    [self setUpCollectionView];

    NSURL *url = [NSURL URLWithString:@"https://api.instagram.com/v1/tags/coffee/media/recent?client_id=de07f6709b3a418683cb2f43a2729de2&count=10&callback=callbackFunction=json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        for (NSDictionary *result in results[@"data"]) {
            NSURL *url = [NSURL URLWithString:result[@"images"][@"standard_resolution"][@"url"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];

            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                UIImage* image = [[UIImage alloc] initWithData:data];
                [self.images addObject:[InstagramImage createInstagramImage:image andImageId:(NSString *)result[@"id"]]];
                [self.collectionView reloadData];
            }];
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];

    [self queryInstagram:textField.text];
    textField.text = @"";
    return YES;
}

-(void)setUpCollectionView{
//    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
//    [flowLayout setMinimumInteritemSpacing:0.0f];
//    [flowLayout setMinimumLineSpacing:2.0f];
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    [flowLayout setItemSize:CGSizeMake(100, 100)];
//    [self.collectionView setPagingEnabled:YES];
//    [self.collectionView setCollectionViewLayout:flowLayout];
}


-(void)queryInstagram:(NSString *)query{
    [self.images removeAllObjects];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/%@/media/recent?client_id=de07f6709b3a418683cb2f43a2729de2&count=10&callback=callbackFunction=json", query]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSMutableDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

        for (NSDictionary *result in results[@"data"]) {
            NSURL *url = [NSURL URLWithString:result[@"images"][@"standard_resolution"][@"url"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];

            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                UIImage* image = [[UIImage alloc] initWithData:data];
                [self.images addObject:[InstagramImage createInstagramImage:image andImageId:(NSString *)result[@"id"]]];
                [self.collectionView reloadData];
            }];
        }
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewImageCell *cell = [CollectionViewImageCell createCellForCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath];
    cell.delegate = self;

    [self.cells insertObject:cell atIndex:indexPath.row];

    InstagramImage *image = [self.images objectAtIndex:indexPath.row];

    if ([self.favoritesDictionary objectForKey:image.photoID]) {
        cell.showFavoriteImageView.hidden = NO;
    }

    cell.imageView.image = image.standardResolution;


    return cell;
}


-(void)favoritePhoto:(UITapGestureRecognizer *)tap{

    CGPoint tapGesture = [tap locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapGesture];
    InstagramImage *image = [self.images objectAtIndex:indexPath.row];
    if (![self.favoritesDictionary  objectForKey:[NSString stringWithFormat:@"%@", image.photoID]]) {

        self.selectedCell = [self.cells objectAtIndex:indexPath.row];

        [self.favoritesDictionary setObject:image forKey:[NSString stringWithFormat:@"%@", image.photoID]];
        [self.favoritesArray addObject:image];

        [self saveImage:(InstagramImage *)image];
        [self.collectionView reloadData];

    }
}

-(void)saveImage:(InstagramImage *)image{
    NSString  *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.png", image.photoID]];
    [UIImagePNGRepresentation(image.standardResolution) writeToFile:pngPath atomically:YES];

    self.saveFavorites = [self load];
}


-(NSArray *)load{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSError *error;
    return [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
}


-(NSURL *)documentsDirectory{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSArray *files = [fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return files.firstObject;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"favorites"]) {
        FavoritesViewController *favoritesViewCtrler = [segue destinationViewController];
        favoritesViewCtrler.favoritesDictionary = self.favoritesDictionary;
        favoritesViewCtrler.favoritesArray = self.favoritesArray;
        favoritesViewCtrler.savedFavorites = self.saveFavorites;
    }
}



@end
