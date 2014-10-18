//
//  FavoriteCollectionViewCell.h
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;


+(FavoriteCollectionViewCell *)createCellForCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;



@end
