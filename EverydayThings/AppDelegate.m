//
//  AppDelegate.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+MOC.h"
#import "FontAwesomeKit.h"

@interface AppDelegate()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // set tab icon
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    NSArray *tabItems = tabController.tabBar.items;
    
    CGSize iconImageSize = CGSizeMake(35, 35);
    CGFloat iconSize = 27;
    
    //tab1 buy now
    UITabBarItem *tab1 = [tabItems objectAtIndex:0];
    UIImage *shoppingCart = [UIImage imageWithStackedIcons:@[[FAKFontAwesome shoppingCartIconWithSize:iconSize]]
                                                 imageSize:iconImageSize];
    tab1.image = shoppingCart;

    //tab2 all items
    UITabBarItem *tab2 = [tabItems objectAtIndex:1];
    UIImage *list = [UIImage imageWithStackedIcons:@[[FAKFontAwesome listIconWithSize:iconSize]]
                                         imageSize:iconImageSize];
    tab2.image = list;
    
    //tab3 expired
    UITabBarItem *tab3 = [tabItems objectAtIndex:2];
    UIImage *exclamation = [UIImage imageWithStackedIcons:@[[FAKFontAwesome exclamationCircleIconWithSize:iconSize]]
                                                imageSize:iconImageSize];
    tab3.image = exclamation;

    //tab4 setting
    UITabBarItem *tab4 = [tabItems objectAtIndex:3];
    UIImage *cog = [UIImage imageWithStackedIcons:@[[FAKFontAwesome cogIconWithSize:iconSize]]
                                        imageSize:iconImageSize];
    tab4.image = cog;
    
    return YES;
}

static NSManagedObjectContext *_sharedContext = nil;

+ (NSManagedObjectContext *)sharedContext
{
    if (!_sharedContext) {
        _sharedContext = [AppDelegate createMainQueueManagedObjectContext];
    }
    return _sharedContext;
}

@end
