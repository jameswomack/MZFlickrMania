//
//  MZFavouritesViewController.m
//  FlickrMania
//
//  Created by Michał Zaborowski on 05.12.2013.
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

#import "MZFavouritesViewController.h"
#import "MZCoreDataFlickrPhoto+Additional.h"
#import "MZRecentCell.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "MZCoreDataFlickrPhotoDimension+Additional.h"
#import "MZRecentDetailsViewController.h"

NSInteger const MZFavouritesCellWidth = 140;
NSInteger const MZFavouritesHeight = 37;
NSString *const MZFavouritesIdentifier = @"FavouritesCell";

NSString *const MZFavouritesPhotoDetailsSegue = @"photoDetails";

@interface MZFavouritesViewController () <CHTCollectionViewDelegateWaterfallLayout, MZRecentCellDelegate>
@property (nonatomic, strong) NSMutableArray *objectChanges;
@property (nonatomic, strong) NSMutableArray *sectionChanges;
@end

@implementation MZFavouritesViewController

// because the app delegate now loads the NSPersistentStore into the NSPersistentStoreCoordinator asynchronously
// we will see the NSManagedObjectContext set up before any persistent stores are registered
// we will need to fetch again after the persistent store is loaded
- (void)reloadFetchedResults:(NSNotification*)note {

    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.

		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}

    if (note) {
        [self.collectionView reloadData];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];

    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];

    layout.delegate = self;

    self.collectionView.collectionViewLayout = layout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];

    [self updateLayout];

    // observe the app delegate telling us when it's finished asynchronously setting up the persistent store
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:@"RefetchAllDatabaseData" object:[[UIApplication sharedApplication] delegate]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:MZAddToFavouritesNotification object:nil];

    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Delete"
                                                      action:@selector(deleteAction:)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObject:menuItem]];
}

- (void)updateLayout
{
    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = self.collectionView.bounds.size.width / MZFavouritesCellWidth;
    layout.itemWidth = MZFavouritesCellWidth;

    NSInteger spaces = (NSInteger)(self.view.bounds.size.width / MZFavouritesCellWidth);
    CGFloat space = self.view.bounds.size.width - (CGFloat)(spaces * MZFavouritesCellWidth);
    CGFloat insets = space/(CGFloat)(spaces+1);

    layout.sectionInset = UIEdgeInsetsMake(insets, insets, insets, insets);
}



#pragma mark - UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    return YES;  // YES for the Cut, copy, paste actions
}

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
         performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender
{
    NSLog(@"performAction");
}

- (void)recentCellDidPerformDeleteAction:(MZRecentCell *)recentCell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:recentCell];
    MZCoreDataFlickrPhoto *photo = (MZCoreDataFlickrPhoto *)[self.fetchedResultsController objectAtIndexPath:indexPath];

    [photo MR_deleteEntity];

    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    [context MR_saveOnlySelfAndWait];

    [[NSNotificationCenter defaultCenter] postNotificationName:MZRemoveFromFavouritesNotification
                                                        object:nil
                                                      userInfo:@{
                                                                 MZRemoveAllFromFavouritesUserInfoKey : @(NO)
                                                                 }];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZRecentCell *cell = (MZRecentCell *)[collectionView dequeueReusableCellWithReuseIdentifier:MZFavouritesIdentifier forIndexPath:indexPath];
    cell.delegate = self;

    MZCoreDataFlickrPhoto *photo = (MZCoreDataFlickrPhoto *)[self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell setupCellWithCoreDataFlickerPhoto:photo];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:MZFavouritesPhotoDetailsSegue]) {
        UICollectionViewCell *cell = (UICollectionViewCell *)sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        MZCoreDataFlickrPhoto *photo = (MZCoreDataFlickrPhoto *)[self.fetchedResultsController objectAtIndexPath:indexPath];

        MZRecentDetailsViewController *destinationViewController = (MZRecentDetailsViewController *)segue.destinationViewController;
        destinationViewController.photoFromDatabase = photo;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self performSegueWithIdentifier:MZFavouritesPhotoDetailsSegue sender:cell];
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        self.fetchedResultsController = [MZCoreDataFlickrPhoto MR_fetchAllSortedBy:@"uploadDate" ascending:YES withPredicate:nil groupBy:nil delegate:self];
    }

	return _fetchedResultsController;
}


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{

    NSMutableDictionary *change = [NSMutableDictionary new];

    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }

    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{

    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{

            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }

    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {

        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];

        } else {

            [self.collectionView performBatchUpdates:^{

                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }

    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }

    return shouldReload;
}

#pragma mark - UICollectionViewWaterfallLayoutDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(CHTCollectionViewWaterfallLayout *)collectionViewLayout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MZCoreDataFlickrPhoto *photo = (MZCoreDataFlickrPhoto *)[self.fetchedResultsController objectAtIndexPath:indexPath];

    return ([photo.smallestDimension.height integerValue]/2) + MZFavouritesHeight;
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
