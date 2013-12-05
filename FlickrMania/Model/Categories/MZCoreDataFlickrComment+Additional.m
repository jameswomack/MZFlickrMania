//
//  MZCoreDataFlickrComment+Additional.m
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

#import "MZCoreDataFlickrComment+Additional.h"

@implementation MZCoreDataFlickrComment (Additional)

+ (MZCoreDataFlickrComment *)commentWithFlickrComment:(MZFlickrComment *)flickrComment saveInDefaultContext:(BOOL)save
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];

    MZCoreDataFlickrComment *comment = [MZCoreDataFlickrComment MR_createEntity];
    comment.authorID = flickrComment.authorID;
    comment.authorName = flickrComment.authorName;
    comment.authorRealName = flickrComment.authorRealName;
    comment.content = flickrComment.content;
    comment.createdDate = flickrComment.createdDate;
    comment.iconFarm = flickrComment.iconFarm;
    comment.iconServer = flickrComment.iconServer;
    comment.iD = flickrComment.ID;
    comment.permalink = [flickrComment.permalink absoluteString];

    if (save) {
        [context MR_saveOnlySelfAndWait];
    }

    return comment;
}

@end
