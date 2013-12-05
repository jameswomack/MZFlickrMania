//
//  MZRecentCell.m
//  FlickrMania
//
//  Created by Michał Zaborowski on 10.11.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "MZRecentCell.h"
#import <UIImageView+AFNetworking.h>
#import "UIColor+Random.h"

@interface AFImageCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
@end

@interface UIImageView()
+ (AFImageCache *)af_sharedImageCache;
@end

@implementation MZRecentCell

- (void)setupCellWithFlickerPhoto:(MZFlickrPhoto *)photo
{


    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:photo.smallImageURL];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    UIImage *cachedImage = [[UIImageView af_sharedImageCache] cachedImageForRequest:request];

    if (cachedImage) {
        self.imageView.image = cachedImage;
    } else {
        self.imageView.alpha = 0;

        [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.imageView.image = image;

            if (!cachedImage) {
                [UIView animateWithDuration:kMZDefaultAnimationDuration animations:^{
                    self.imageView.alpha = 1.0;
                }];
            }
            
        } failure:nil];
    }
    
    self.titleLabel.text = photo.title;

    if ([photo.title isEqualToString:@""] || !photo.title) {
        [(NSLayoutConstraint *)self.titleLabel.constraints[0] setConstant:0];
    }

    self.backgroundPhotoView.backgroundColor = [UIColor whiteColor];

    self.backgroundPhotoView.layer.cornerRadius = 6;
    self.backgroundPhotoView.clipsToBounds = YES;
    self.imageView.clipsToBounds = YES;
    self.imageViewBackgroundView.backgroundColor = [UIColor randomFlatColor];

    self.clipsToBounds = NO;
    [self.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.layer setShadowRadius:2.0];
    [self.layer setShadowColor:[UIColor blackColor].CGColor] ;
    [self.layer setShadowOpacity:0.2];
    [self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.layer.bounds] CGPath]];
}

@end
