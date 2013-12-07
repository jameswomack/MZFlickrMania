//
//  MZMoreViewController.m
//  FlickrMania
//
//  Created by Michał Zaborowski on 07.12.2013.
//  Copyright (c) 2013 Michał Zaborowski. All rights reserved.
//

#import "MZMoreViewController.h"
#import "MZCoreDataFlickrPhoto.h"
#import <UIImageView+AFNetworking.h>

@interface AFImageCache : NSCache
@end

@interface UIImageView()
+ (AFImageCache *)af_sharedImageCache;
@end

@interface MZMoreViewController ()
@end

@implementation MZMoreViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        cell.accessoryView = activityIndicator;

        if ([MZCoreDataFlickrPhoto MR_truncateAll]) {
            [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:error.localizedDescription
                                               delegate:nil cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:MZRemoveFromFavouritesNotification
                                                                        object:nil
                                                                      userInfo:@{
                                                                                 MZRemoveAllFromFavouritesUserInfoKey : @(YES)
                                                                                 }];
                }
                cell.accessoryView = nil;
            }];
        }

    } else if (indexPath.section == 1) {

        [[UIImageView af_sharedImageCache] removeAllObjects];

    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
