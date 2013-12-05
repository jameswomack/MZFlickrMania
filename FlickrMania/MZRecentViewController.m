//
//  MZViewController.m
//  FlickrMania
//
//  Created by Michał Zaborowski on 07.11.2013.
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

#import "MZRecentViewController.h"
#import "MZRecentDetailsViewController.h"

NSInteger const MZRecentCellWidth = 140;
NSInteger const MZRecentCellLabelHeight = 37;
NSString *const MZRecentCellIdentifier = @"RecentCell";

NSString *const MZPhotoDetailsSegue = @"photoDetails";

@interface MZRecentViewController () <CHTCollectionViewDelegateWaterfallLayout>
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign, getter = isLoadingMoreData) BOOL loadingMoreData;
@end

@implementation MZRecentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _photos = [[NSMutableArray alloc] init];

    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];

    layout.delegate = self;

    self.collectionView.collectionViewLayout = layout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];

    [self updateLayout];

    self.currentPage = 0;

    [self loadMoreDataWithPage:self.currentPage+1];
}

- (void)loadMoreDataWithPage:(NSInteger)page
{
    self.loadingMoreData = YES;

    [[MZLibraryAPI sharedLibrary] recentPhotosOnPage:page completionHandler:^(NSArray *photos, NSError *error) {
        if (!error) {
            [self.photos addObjectsFromArray:photos];
            [self.collectionView reloadData];
            self.currentPage++;

        }
        self.loadingMoreData = NO;
    }];
}

- (void)updateLayout
{
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = self.collectionView.bounds.size.width / MZRecentCellWidth;
    layout.itemWidth = MZRecentCellWidth;

    NSInteger spaces = (NSInteger)(self.view.bounds.size.width / MZRecentCellWidth);
    CGFloat space = self.view.bounds.size.width - (CGFloat)(spaces * MZRecentCellWidth);
    CGFloat insets = space/(CGFloat)(spaces+1);

    layout.sectionInset = UIEdgeInsetsMake(insets, insets, insets, insets);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:MZPhotoDetailsSegue]) {
        UICollectionViewCell *cell = (UICollectionViewCell *)sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        MZFlickrPhoto *photo = self.photos[indexPath.row];

        MZRecentDetailsViewController *destinationViewController = (MZRecentDetailsViewController *)segue.destinationViewController;
        destinationViewController.photo = photo;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZRecentCell *cell = (MZRecentCell *)[collectionView dequeueReusableCellWithReuseIdentifier:MZRecentCellIdentifier forIndexPath:indexPath];

    MZFlickrPhoto *photo = self.photos[indexPath.row];

    [cell setupCellWithFlickerPhoto:photo];

    if (indexPath.row >= self.photos.count*3/4 && !self.isLoadingMoreData) {

        [self loadMoreDataWithPage:self.currentPage+1];
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:MZPhotoDetailsSegue sender:cell];
}


#pragma mark - UICollectionViewWaterfallLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(CHTCollectionViewWaterfallLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZFlickrPhoto *photo = self.photos[indexPath.row];

    return (photo.smallImageDimensions.height/2) + MZRecentCellLabelHeight;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation
                                            duration:duration];
    [self updateLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateLayout];
}


@end
