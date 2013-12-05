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

@end

@implementation MZRecentDetailsViewController


- (void)setPhoto:(MZFlickrPhoto *)photo
{
    if (_photo != photo) {
        _photo = photo;
        [self reloadData];
    }
}

- (void)reloadOutlets
{
    self.photoTitleLabel.text = _photo.title;
    [self.photoImageView setImageWithURL:_photo.mediumImageURL];
    self.photoOwnerNameLabel.text = _photo.ownerName;
    [self.photoOwnerImageView setImageWithURL:_photo.ownerThumbnailURL];
    self.photoDateLabel.text = _photo.uploadDateFormattedString;
}

- (void)reloadData
{
    [self reloadOutlets];

    if (_photo.comments.count <= 0) {
        [[MZLibraryAPI sharedLibrary] commentsForPhoto:_photo completionHandler:^(NSArray *comments, NSError *error) {
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

    MZFlickrComment *comment = self.photo.comments[indexPath.row];
    cell.commentLabel.text = comment.content;

    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    return height + 10;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photo.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MZRecentPhotoCommentCell *cell = (MZRecentPhotoCommentCell *)[tableView dequeueReusableCellWithIdentifier:MZRecentPhotoCommentCellIdentifier forIndexPath:indexPath];

    MZFlickrComment *comment = self.photo.comments[indexPath.row];
    [cell setupCellWithFlickerPhotoComment:comment];


    return cell;
}


@end
