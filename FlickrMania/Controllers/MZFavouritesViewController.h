//
//  MZFavouritesViewController.h
//  FlickrMania
//
//  Created by Michał Zaborowski on 05.12.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MZFavouritesViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end
