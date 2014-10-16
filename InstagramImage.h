//
//  InstagramImage.h
//  FavoritePhotosChallenge
//
//  Created by Richmond on 10/16/14.
//  Copyright (c) 2014 Richmond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface InstagramImage : NSObject

@property UIImage *standardResolution;
@property UIImage *thumbnail;

+(InstagramImage *)createInstagramImage:(UIImage *)passedInImage;
@end
