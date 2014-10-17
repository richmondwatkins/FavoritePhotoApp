//
//  CollectionViewImageCell.m
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/16/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "CollectionViewImageCell.h"

@implementation CollectionViewImageCell

+(CollectionViewImageCell *)createCellForCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    CollectionViewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    UITapGestureRecognizer *doubleTapFolderGesture = [[UITapGestureRecognizer alloc] initWithTarget:cell.delegate action:@selector(favoritePhoto:)];
    [doubleTapFolderGesture setNumberOfTapsRequired:2];
    [doubleTapFolderGesture setNumberOfTouchesRequired:1];
    [cell addGestureRecognizer:doubleTapFolderGesture];


    return cell;
}

@end
