//
//  FavoriteCollectionViewCell.m
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/17/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "FavoriteCollectionViewCell.h"

@implementation FavoriteCollectionViewCell

+(FavoriteCollectionViewCell *)createCellForCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    FavoriteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"favCell" forIndexPath:indexPath];

    
    return cell;
}

@end
