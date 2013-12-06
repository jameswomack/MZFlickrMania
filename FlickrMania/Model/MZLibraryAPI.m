//
//  MZLibraryAPI.m
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

#import "MZLibraryAPI.h"
#import "MZFlickrPhoto.h"
#import "MZFlickrComment.h"
#import "MZCoreDataFlickrPhoto+Additional.h"
#import <RestKit/RestKit.h>

@interface MZLibraryAPI()
@property (nonatomic, strong) RKObjectManager *objectManager;
@end

@implementation MZLibraryAPI

+ (MZLibraryAPI *)sharedLibrary
{
    static dispatch_once_t once;
    static MZLibraryAPI *instanceOfHTTPClient;
    dispatch_once(&once, ^ { instanceOfHTTPClient = [[MZLibraryAPI alloc] init]; });
    return instanceOfHTTPClient;
}

- (id)init
{
    if (self = [super init]) {
        [self configureRestKitObjectManager];
    }
    return self;
}

- (void)commentsForPhotoID:(NSString *)photoID
       completionHandler:(MZLibraryAPICommentsForPhotoCompletionHandler)completionHandler
{
    NSParameterAssert(photoID);

    NSDictionary *parameters = @{@"photo_id" : photoID,

                                 @"format" : @"json",
                                 @"nojsoncallback" : @(1),
                                 @"method" : @"flickr.photos.comments.getList",
                                 @"api_key" : MZFlickrAPIKey
                                 };

    [self.objectManager getObjectsAtPath:MZFlickrPath parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSArray *comments = [mappingResult array];
        if (completionHandler) {
            completionHandler(comments,nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (completionHandler) {
            completionHandler(nil,error);
        }
    }];
}

- (void)recentPhotosOnPage:(NSInteger)page
                      completionHandler:(MZLibraryAPIRecentGeoreferencedPhotosCompletionHandler)completionHandler
{
    NSDictionary *parameters = @{@"per_page" : @"50",
                                 @"extras" : @"date_upload,owner_name,url_n,url_z,url_o,o_dims,icon_server,icon_farm",
                                 @"page" : @(page),
                                 
                                 @"format" : @"json",
                                 @"nojsoncallback" : @(1),
                                 @"method" : @"flickr.interestingness.getList",
                                 @"api_key" : MZFlickrAPIKey
                                 };

    [self.objectManager getObjectsAtPath:MZFlickrPath parameters:parameters success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSArray *photos = [mappingResult array];

        if (completionHandler) {
            completionHandler(photos,nil);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Photo load error: %@", error);

        if (completionHandler) {
            completionHandler(nil,error);
        }
    }];

}

#pragma mark - Core Data Managemenet

- (void)addPhotoToDatabase:(MZFlickrPhoto *)photo completionBlock:(MZLibraryAPIAddPhotoCompletionBlock)completionBlock
{
    MZCoreDataFlickrPhoto *flickrPhoto = [MZCoreDataFlickrPhoto MR_findFirstByAttribute:@"iD" withValue:photo.ID];
    BOOL isNewRecord = YES;

    if (flickrPhoto) {
        isNewRecord = NO;
        [flickrPhoto updateWithFlickrPhoto:photo saveInDefaultContext:NO];
    } else {
        flickrPhoto = [MZCoreDataFlickrPhoto photoWithFlickrPhoto:photo saveInDefaultContext:NO];
    }

    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];

    [context MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
        if (!success || error) {
            if (completionBlock)
                completionBlock(flickrPhoto,isNewRecord,error);
        } else {
            if (completionBlock)
                completionBlock(flickrPhoto,isNewRecord,nil);
        }

    }];

}

#pragma mark - Rest Kit Configuration

- (void)configureRestKitObjectManager
{
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:MZFlickrBaseURL]];
    objectManager.managedObjectStore = [RKManagedObjectStore defaultStore];
    self.objectManager = objectManager;

    [self configureRestKitObjectMapping];
}

- (void)configureRestKitObjectMapping
{
    [self configureFlickrPhotoMapping];
    [self configureFlickrPhotoCommentsMapping];
}

- (void)configureFlickrPhotoCommentsMapping
{
    RKObjectMapping *commentMapping = [RKObjectMapping mappingForClass:[MZFlickrComment class]];

    NSDictionary *commentDictionaryMapping = @{@"author" : @"authorID",
                                             @"authorname" : @"authorName",
                                             @"id" : @"ID",
                                             @"iconserver" : @"iconServer",
                                             @"iconfarm" : @"iconFarm",
                                             @"datecreate" : @"createdDate",
                                             @"permalink" : @"permalink",
                                             @"realname" : @"authorRealName",
                                             @"_content" : @"content"
                                             };

    [commentMapping addAttributeMappingsFromDictionary:commentDictionaryMapping];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:MZFlickrPath
                                                                                           keyPath:@"comments.comment"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    [self.objectManager addResponseDescriptor:responseDescriptor];

    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                                      method:RKRequestMethodGET
                                                                 pathPattern:MZFlickrPath
                                                                     keyPath:@"comments"
                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    [self.objectManager addResponseDescriptor:responseDescriptor];
}

- (void)configureFlickrPhotoMapping
{
    RKObjectMapping *photoMapping = [RKObjectMapping mappingForClass:[MZFlickrPhoto class]];

    NSDictionary *photoDictionaryMapping = @{@"ownername" : @"ownerName",
                                             @"owner" : @"ownerID",
                                             @"id" : @"ID",
                                             @"iconserver" : @"iconServer",
                                             @"iconfarm" : @"iconFarm",
                                             @"dateupload" : @"uploadDate",
                                             @"title" : @"title",
                                             @"url_n" : @"smallImageURL",
                                             @"url_z" : @"mediumImageURL",
                                             @"url_o" : @"originalImageURL",
                                             };

    [photoMapping addAttributeMappingsFromDictionary:photoDictionaryMapping];

    RKObjectMapping *photoSmallImageDimenstionMapping = [RKObjectMapping
                                                         mappingForClass:[MZFlickrPhotoDimension class]];
    [photoSmallImageDimenstionMapping addAttributeMappingsFromDictionary:@{
                                                                           @"width_n" : @"width",
                                                                           @"height_n" : @"height",
                                                                           }];

    RKRelationshipMapping* photoSmallImageDimenstionRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:nil
                                                                                                                      toKeyPath:@"smallImageDimensions"
                                                                                                                    withMapping:photoSmallImageDimenstionMapping];
    [photoMapping addPropertyMapping:photoSmallImageDimenstionRelationshipMapping];

    RKObjectMapping *photoMediumImageDimenstionMapping = [RKObjectMapping
                                                          mappingForClass:[MZFlickrPhotoDimension class]];
    [photoMediumImageDimenstionMapping addAttributeMappingsFromDictionary:@{
                                                                            @"width_z" : @"width",
                                                                            @"height_z" : @"height",
                                                                            }];

    RKRelationshipMapping *photoMediumImageDimenstionRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:nil
                                                                                                                       toKeyPath:@"mediumImageDimensions"
                                                                                                                     withMapping:photoMediumImageDimenstionMapping];
    [photoMapping addPropertyMapping:photoMediumImageDimenstionRelationshipMapping];

    RKObjectMapping *photoOriginalImageDimenstionMapping = [RKObjectMapping
                                                            mappingForClass:[MZFlickrPhotoDimension class]];
    [photoOriginalImageDimenstionMapping addAttributeMappingsFromDictionary:@{
                                                                              @"width_o" : @"width",
                                                                              @"height_o" : @"height",
                                                                              }];

    RKRelationshipMapping *photoOriginalImageDimenstionRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:nil
                                                                                                                         toKeyPath:@"originalImageDimensions"
                                                                                                                       withMapping:photoOriginalImageDimenstionMapping];
    [photoMapping addPropertyMapping:photoOriginalImageDimenstionRelationshipMapping];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor
                                                responseDescriptorWithMapping:photoMapping
                                                method:RKRequestMethodGET
                                                pathPattern:MZFlickrPath
                                                keyPath:@"photos.photo"
                                                statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [self.objectManager addResponseDescriptor:responseDescriptor];
}

@end