//
//  MZCoreDataFlickrPhoto.h
//  FlickrMania
//
//  Created by Michał Zaborowski on 30.11.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MZCoreDataFlickrComment, MZCoreDataFlickrPhotoDimension;

@interface MZCoreDataFlickrPhoto : NSManagedObject

@property (nonatomic, retain) NSNumber * iconFarm;
@property (nonatomic, retain) NSNumber * iconServer;
@property (nonatomic, retain) NSString * iD;
@property (nonatomic, retain) NSString * ownerID;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * uploadDate;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * permalink;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *dimensions;
@end

@interface MZCoreDataFlickrPhoto (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(MZCoreDataFlickrComment *)value;
- (void)removeCommentsObject:(MZCoreDataFlickrComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addDimensionsObject:(MZCoreDataFlickrPhotoDimension *)value;
- (void)removeDimensionsObject:(MZCoreDataFlickrPhotoDimension *)value;
- (void)addDimensions:(NSSet *)values;
- (void)removeDimensions:(NSSet *)values;

@end
