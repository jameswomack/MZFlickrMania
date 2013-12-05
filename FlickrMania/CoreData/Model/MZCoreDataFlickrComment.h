//
//  MZCoreDataFlickrComment.h
//  FlickrMania
//
//  Created by Michał Zaborowski on 30.11.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MZCoreDataFlickrPhoto;

@interface MZCoreDataFlickrComment : NSManagedObject

@property (nonatomic, retain) NSString * iD;
@property (nonatomic, retain) NSNumber * iconFarm;
@property (nonatomic, retain) NSNumber * iconServer;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * authorID;
@property (nonatomic, retain) NSString * permalink;
@property (nonatomic, retain) NSString * authorRealName;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) MZCoreDataFlickrPhoto *photo;

@end
