//
//  MZCoreDataFlickrPhoto+Additional.m
//  FlickrMania
//
//  Created by Michał Zaborowski on 30.11.2013.
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

#import "MZCoreDataFlickrPhoto+Additional.h"
#import "MZFlickrPhoto.h"
#import "MZCoreDataFlickrComment+Additional.h"
#import "MZCoreDataFlickrPhotoDimension+Additional.h"

@implementation MZCoreDataFlickrPhoto (Additional)

- (void)updateWithFlickrPhoto:(MZFlickrPhoto *)flickrPhoto saveInDefaultContext:(BOOL)save
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    
    [self insertAttributesFromFlickPhoto:flickrPhoto];

    if (save) {
        [context MR_saveOnlySelfAndWait];
    }
}

- (void)updateComments:(NSArray *)comments saveInDefaultContext:(BOOL)save
{
    for (MZCoreDataFlickrComment *comment in self.comments) {
        [comment MR_deleteEntity];
    }

    if (comments.count > 0) {
        [comments enumerateObjectsUsingBlock:^(MZFlickrComment *obj, NSUInteger idx, BOOL *stop) {
            MZCoreDataFlickrComment *comment = [MZCoreDataFlickrComment commentWithFlickrComment:obj saveInDefaultContext:NO];
            comment.photo = self;
        }];
    }

    if (save) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        [context MR_saveOnlySelfAndWait];
    }
}

- (void)insertAttributesFromFlickPhoto:(MZFlickrPhoto *)flickrPhoto
{
    self.iconFarm = flickrPhoto.iconFarm;
    self.iconServer = flickrPhoto.iconServer;
    self.iD = flickrPhoto.ID;
    self.ownerID = flickrPhoto.ownerID;
    self.ownerName = flickrPhoto.ownerName;
    self.title = flickrPhoto.title;
    self.uploadDate = flickrPhoto.uploadDate;

    MZCoreDataFlickrPhotoDimension *smallDimension = [MZCoreDataFlickrPhotoDimension dimensionWithURL:flickrPhoto.smallImageURL width:@(flickrPhoto.smallImageDimensions.width) height:@(flickrPhoto.smallImageDimensions.height) saveInDefaultContext:NO];

    MZCoreDataFlickrPhotoDimension *mediumDimension = [MZCoreDataFlickrPhotoDimension dimensionWithURL:flickrPhoto.mediumImageURL width:@(flickrPhoto.mediumImageDimensions.width) height:@(flickrPhoto.mediumImageDimensions.height) saveInDefaultContext:NO];

    MZCoreDataFlickrPhotoDimension *originalDimension = [MZCoreDataFlickrPhotoDimension dimensionWithURL:flickrPhoto.originalImageURL width:@(flickrPhoto.originalImageDimensions.width) height:@(flickrPhoto.originalImageDimensions.height) saveInDefaultContext:NO];

    for (MZCoreDataFlickrPhotoDimension *dimmension in self.dimensions) {
        [dimmension MR_deleteEntity];
    }

    [self addDimensions:[NSSet setWithArray:@[smallDimension,mediumDimension,originalDimension]]];

    for (MZCoreDataFlickrComment *comment in self.comments) {
        [comment MR_deleteEntity];
    }

    if (flickrPhoto.comments.count > 0) {
        [flickrPhoto.comments enumerateObjectsUsingBlock:^(MZFlickrComment *obj, NSUInteger idx, BOOL *stop) {
            MZCoreDataFlickrComment *comment = [MZCoreDataFlickrComment commentWithFlickrComment:obj saveInDefaultContext:NO];
            comment.photo = self;
        }];
    }
}

+ (MZCoreDataFlickrPhoto *)photoWithFlickrPhoto:(MZFlickrPhoto *)flickrPhoto saveInDefaultContext:(BOOL)save
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];

    MZCoreDataFlickrPhoto * photo = [MZCoreDataFlickrPhoto MR_createEntity];
    [photo insertAttributesFromFlickPhoto:flickrPhoto];

    if (save) {
        [context MR_saveOnlySelfAndWait];
    }

    return photo;
}

- (NSArray *)sortedDimensionsByWidth
{
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"height" ascending:YES]];

    NSMutableArray *mutableDimensions = [[self.dimensions allObjects] mutableCopy];
    NSMutableArray *objectForDelete = [NSMutableArray array];

    for (MZCoreDataFlickrPhotoDimension *dimension in mutableDimensions) {
        if ([dimension.width integerValue] <= 0 || [dimension.height integerValue] <= 0) {
            [objectForDelete addObject:dimension];
        }
    }

    [mutableDimensions removeObjectsInArray:objectForDelete];

    NSArray *sortedDimensions = [mutableDimensions sortedArrayUsingDescriptors:sortDescriptors];

    return sortedDimensions;
}

- (MZCoreDataFlickrPhotoDimension *)smallestDimension
{
    return [[self sortedDimensionsByWidth] firstObject];
}

- (NSURL *)mediumImageURL
{
    NSArray *dimensions = [self sortedDimensionsByWidth];
    if (dimensions.count > 2) {
        MZCoreDataFlickrPhotoDimension *dimension = dimensions[1];
        return [NSURL URLWithString:dimension.imageURL];
    } else {
        MZCoreDataFlickrPhotoDimension *dimension = [dimensions firstObject];
        return [NSURL URLWithString:dimension.imageURL];
    }
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
    return [[MZFlickrPhoto flickrPhotoDateFormatter] stringFromDate:self.uploadDate];
}

@end
