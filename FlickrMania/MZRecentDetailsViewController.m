//
//  MZRecentDetailsViewController.m
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

#import "MZRecentDetailsViewController.h"
#import "MZRecentPhotoCommentCell.h"
#import "MZFlickrComment.h"
#import <UIImageView+AFNetworking.h>

NSString *const MZRecentPhotoCommentCellIdentifier = @"CommentCell";

@interface MZRecentDetailsViewController ()
@property (nonatomic, strong) NSArray *comments;
@end

@implementation MZRecentDetailsViewController


- (void)setPhoto:(MZFlickrPhoto *)photo
{
    if (_photo != photo) {
        _photo = photo;
        [self reloadData];
    }
}

- (void)setPhotoFromDatabase:(MZCoreDataFlickrPhoto *)photoFromDatabase
{
    if (_photoFromDatabase != photoFromDatabase) {
        _photoFromDatabase = photoFromDatabase;

        _comments = [_photoFromDatabase.comments allObjects];

        if (_comments.count <= 0) {
            [[MZLibraryAPI sharedLibrary] commentsForPhotoID:_photoFromDatabase.iD completionHandler:^(NSArray *comments, NSError *error) {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                } else {
                    _comments = comments;
                    [_photoFromDatabase updateComments:comments saveInDefaultContext:YES];
                    [self.tableView reloadData];
                }
            }];
        }

        [self reloadOutlets];
    }
}

- (void)reloadOutlets
{
    if (_photo) {
        self.photoTitleLabel.text = _photo.title;
        [self.photoImageView setImageWithURL:_photo.mediumImageURL];
        self.photoOwnerNameLabel.text = _photo.ownerName;
        [self.photoOwnerImageView setImageWithURL:_photo.ownerThumbnailURL];
        self.photoDateLabel.text = _photo.uploadDateFormattedString;
        self.tableView.tableHeaderView.frame =(CGRect){ .origin = self.tableView.tableHeaderView.frame.origin, .size = CGSizeMake(self.tableView.tableHeaderView.frame.size.width, _photo.mediumImageDimensions.height - self.authorBackgroundView.frame.size.height)  };
    } else {
        self.photoTitleLabel.text = _photoFromDatabase.title;
        [self.photoImageView setImageWithURL:_photoFromDatabase.mediumImageURL];
        self.photoOwnerNameLabel.text = _photoFromDatabase.ownerName;
        [self.photoOwnerImageView setImageWithURL:_photoFromDatabase.ownerThumbnailURL];
        self.photoDateLabel.text = _photoFromDatabase.uploadDateFormattedString;

        self.tableView.tableHeaderView.frame =(CGRect){ .origin = self.tableView.tableHeaderView.frame.origin, .size = CGSizeMake(self.tableView.tableHeaderView.frame.size.width, [_photoFromDatabase.mediumDimension.height floatValue] - self.authorBackgroundView.frame.size.height)  };
    }
}

- (void)reloadData
{
    [self reloadOutlets];

    if (_photo.comments.count <= 0) {
        [[MZLibraryAPI sharedLibrary] commentsForPhotoID:_photo.ID completionHandler:^(NSArray *comments, NSError *error) {
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                _photo.comments = comments;
                [self.tableView reloadData];
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self reloadOutlets];
    [self.tableView reloadData];

    if (self.photoFromDatabase) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (IBAction)bookmarkButtonTapped:(id)sender
{
    [[MZLibraryAPI sharedLibrary] addPhotoToDatabase:self.photo completionBlock:^(MZCoreDataFlickrPhoto *photo, BOOL isNewRecord, NSError *error) {
        if (!error && isNewRecord) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MZAddToFavouritesNotification object:photo];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZRecentPhotoCommentCell *cell = (MZRecentPhotoCommentCell *)[tableView dequeueReusableCellWithIdentifier:MZRecentPhotoCommentCellIdentifier];

    id <MZFlickrComment> comment = nil;

    if (self.photo) {
        comment = self.photo.comments[indexPath.row];
    } else if (self.photoFromDatabase) {
        comment = self.comments[indexPath.row];
    }

    cell.commentLabel.text = comment.content;

    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    return height + 10;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.photo) {
        return self.photo.comments.count;
    } else {
        return self.comments.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZRecentPhotoCommentCell *cell = (MZRecentPhotoCommentCell *)[tableView dequeueReusableCellWithIdentifier:MZRecentPhotoCommentCellIdentifier forIndexPath:indexPath];

    id <MZFlickrComment> comment = nil;

    if (self.photo) {
        comment = self.photo.comments[indexPath.row];
    } else if (self.photoFromDatabase) {
        comment = self.comments[indexPath.row];
    }
    
    [cell setupCellWithFlickerPhotoComment:comment];


    return cell;
}


@end
