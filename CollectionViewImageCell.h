//
//  CollectionViewImageCell.h
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/16/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
@protocol CollectionViewImageCellDelegate

-(void)favoritePhoto:(UITapGestureRecognizer *)sender;

@end

@interface CollectionViewImageCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *hiddenImageView;


+(CollectionViewImageCell *)createCellForCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@property id<CollectionViewImageCellDelegate> delegate;



@end
