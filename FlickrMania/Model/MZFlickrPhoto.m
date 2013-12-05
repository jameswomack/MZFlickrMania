//
//  MZFlickrPhoto.m
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

#import "MZFlickrPhoto.h"

@implementation MZFlickrPhoto

+ (NSDateFormatter *)flickrPhotoDateFormatter
{
    static dispatch_once_t once;
    static NSDateFormatter *instanceOfFlickrDateFormatter;
    dispatch_once(&once, ^ { instanceOfFlickrDateFormatter = [[NSDateFormatter alloc] init];
        [instanceOfFlickrDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [instanceOfFlickrDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    });
    return instanceOfFlickrDateFormatter;
}

- (NSURL *)ownerThumbnailURL
{
    NSString *thumbnailURLString = @"http://www.flickr.com/images/buddyicon.gif";

    if ([self.iconServer integerValue] > 0) {
        thumbnailURLString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/buddyicons/%@.jpg",self.iconFarm,self.iconServer,self.ownerID];
    }
    return [NSURL URLWithString:thumbnailURLString];
}

- (NSString *)uploadDateFormattedString
{
    return [[[self class] flickrPhotoDateFormatter] stringFromDate:self.uploadDate];
}

@end
