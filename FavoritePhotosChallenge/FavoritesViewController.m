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
#import <MessageUI/MessageUI.h>

#import <Social/Social.h>
@interface FavoritesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
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

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{

}

- (IBAction)pressedEmailButton:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.favoriteCollectionView];
    NSIndexPath *indexPath = [self.favoriteCollectionView indexPathForItemAtPoint:buttonPosition];

    NSString *imageString = [self.mutableFavorites objectAtIndex:indexPath.row];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString: imageString]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];


    MFMailComposeViewController *mailComposer;
    mailComposer  = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setModalPresentationStyle:UIModalPresentationFormSheet];
    [mailComposer setSubject:@"Check out my favorite image!"];
    [mailComposer addAttachmentData:UIImageJPEGRepresentation(image, 1) mimeType:@"image/jpeg" fileName:@"MyFile.jpeg"];

    [mailComposer setMessageBody:@"your custom body content" isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];
}
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.mutableFavorites.count;
}
- (IBAction)twitterButtonPressed:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.favoriteCollectionView];
    NSIndexPath *indexPath = [self.favoriteCollectionView indexPathForItemAtPoint:buttonPosition];

    NSString *imageString = [self.mutableFavorites objectAtIndex:indexPath.row];
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithString: imageString]];
    UIImage* image = [UIImage imageWithContentsOfFile:path];

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"One of my favorites!"];
        [tweetSheet addImage:image];

        [self presentViewController:tweetSheet animated:YES completion:nil];

    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }

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

- (IBAction)deletePhotoPanGesture:(UISwipeGestureRecognizer *)panGesture{

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

@end
