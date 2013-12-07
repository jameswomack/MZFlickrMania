//
//  MZTabBarController.m
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

#import "MZTabBarController.h"
#import "MZCoreDataFlickrPhoto.h"

@interface MZTabBarController ()

@end

@implementation MZTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUInteger countOfPhotos = [MZCoreDataFlickrPhoto MR_countOfEntities];
    if (countOfPhotos > 0) {
        [self favouritesTabBarItem].badgeValue = [NSString stringWithFormat:@"%d",countOfPhotos];
    }

    __weak MZTabBarController *weakSelf = self;

    [[NSNotificationCenter defaultCenter] addObserverForName:MZAddToFavouritesNotification object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {

                                                      if (![weakSelf favouritesTabBarItem].badgeValue || [[weakSelf favouritesTabBarItem].badgeValue isEqualToString:@""]) {
                                                          [weakSelf favouritesTabBarItem].badgeValue = @"1";
                                                      } else {
                                                          NSInteger badge = [[weakSelf favouritesTabBarItem].badgeValue integerValue];
                                                          badge++;
                                                          [weakSelf favouritesTabBarItem].badgeValue = [NSString stringWithFormat:@"%d",badge];
                                                      }
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:MZRemoveFromFavouritesNotification object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {

                                                      if (![weakSelf favouritesTabBarItem].badgeValue ||
                                                          [[self favouritesTabBarItem].badgeValue isEqualToString:@""] ||
                                                          [note.userInfo[MZRemoveAllFromFavouritesUserInfoKey] boolValue]) {
                                                          
                                                          [weakSelf favouritesTabBarItem].badgeValue = nil;
                                                      } else {
                                                          NSInteger badge = [[self favouritesTabBarItem].badgeValue integerValue];
                                                          badge--;
                                                          if (badge <= 0) {
                                                              [weakSelf favouritesTabBarItem].badgeValue = nil;
                                                          } else {
                                                              [weakSelf favouritesTabBarItem].badgeValue = [NSString stringWithFormat:@"%d",badge];
                                                          }

                                                      }
                                                  }];


}

- (UITabBarItem *)favouritesTabBarItem
{
    for (UIViewController *viewController in self.viewControllers) {
        if (viewController.tabBarItem.tag == MZTabBarControllerTabFavourites) {
            return viewController.tabBarItem;
        }
    }
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MZAddToFavouritesNotification object:nil];
}

@end
