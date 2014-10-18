//
//  InstagramImage.m
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/16/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import "InstagramImage.h"

@implementation InstagramImage

+(InstagramImage *)createInstagramImage:(UIImage *)passedInImage andImageId:(NSString *)imageId{

    InstagramImage *image = [InstagramImage new];
    image.standardResolution = passedInImage;
    image.photoID = imageId;
    return image;
}

@end
