//
//  MZCoreDataFlickrPhotoDimension.h
//  FlickrMania
//
//  Created by Michał Zaborowski on 30.11.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MZCoreDataFlickrPhoto;

@interface MZCoreDataFlickrPhotoDimension : NSManagedObject

@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) MZCoreDataFlickrPhoto *photo;

@end
