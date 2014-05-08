//
//  AppDelegate.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+MOC.h"
#import "FontAwesomeKit.h"
#import "LocationManager.h"
#import "Item+helper.h"
#import "GeofenceMonitoringLocationReloadNotification.h"
#import "UpdateApplicationBadgeNumberNotification.h"
#import "UpdateBuyNowTabBadgeNumberNotification.h"

@interface AppDelegate()
@property (nonatomic, strong) LocationManager *locationManager;
@end

@implementation AppDelegate

#pragma mark - Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // setup tabbar
    [self setupTabBar];

    // Location Manager setup
    if ([self.locationManager isLocationManagerAvaiable] && [self useGeofence]) {
        [self.locationManager initializeLocationManager];
        [self.locationManager stopMonitoringAllRegions];
        [self.locationManager initializeRegionMonitoring:[self.locationManager buildGeofenceData]];
    }
    
    // tune in geofence region change notification
    [self tuneInGeofenceMonitoringLocationReloadNotification];
    
    // tune in update appication badge notification
    [self tuneInUpdatingApplicationBadgeNotification];
    
    // tune in updating buy now tab badge number notification
    [self tuneInUpdatingBuyNowBadgeNotification];
    
    // turn on badge update in background
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self updateApplicationBadgeNumber];
    [self updateGeofence];
    // you need to end your performFetchWithCompletionHandler by responding back that you're finished and provide a status
    // iOS expects you to return this promptly, within about 30 seconds, otherwise it will start to penalize your app’s background execution
    // to preserve battery life.
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - Coredata shared managed object context

static NSManagedObjectContext *_sharedContext = nil;

+ (NSManagedObjectContext *)sharedContext
{
    if (!_sharedContext) {
        _sharedContext = [AppDelegate createMainQueueManagedObjectContext];
    }
    return _sharedContext;
}

#pragma mark - Location manager things

- (LocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [LocationManager sharedLocationManager];
    }
    return _locationManager;
}

- (void)updateGeofence
{
    if ([self.locationManager isLocationManagerAvaiable]) {
        [self.locationManager stopMonitoringAllRegions];
        if ([self useGeofence]) {
            [self.locationManager initializeLocationManager];
            [self.locationManager initializeRegionMonitoring:[self.locationManager buildGeofenceData]];
        }
    }
}

#pragma mark - UI

- (void) setupTabBar
{
    // set tab icon
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    NSArray *tabItems = tabController.tabBar.items;
    
    CGSize iconImageSize = CGSizeMake(35, 35);
    CGFloat iconSize = 27;
    
    //tab1 buy now
    UITabBarItem *tab1 = tabItems[0];
    UIImage *shoppingCart = [UIImage imageWithStackedIcons:@[[FAKFontAwesome shoppingCartIconWithSize:iconSize]]
                                                 imageSize:iconImageSize];
    tab1.image = shoppingCart;
    
    //tab2 expired
    UITabBarItem *tab2 = tabItems[1];
    UIImage *exclamation = [UIImage imageWithStackedIcons:@[[FAKFontAwesome calendarIconWithSize:iconSize]]
                                                imageSize:iconImageSize];
    tab2.image = exclamation;

    //tab3 all items
    UITabBarItem *tab3 = tabItems[2];
    UIImage *list = [UIImage imageWithStackedIcons:@[[FAKFontAwesome listIconWithSize:iconSize]]
                                         imageSize:iconImageSize];
    tab3.image = list;
    
    //tab4 setting
    UITabBarItem *tab4 = tabItems[3];
    UIImage *cog = [UIImage imageWithStackedIcons:@[[FAKFontAwesome cogIconWithSize:iconSize]]
                                        imageSize:iconImageSize];
    tab4.image = cog;
}

- (void)setBuyNowTabBadgeNumber
{
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    NSArray *tabItems = tabController.tabBar.items;

    UITabBarItem *tbi = (UITabBarItem*)tabItems[0];
    NSUInteger count = [[Item itemsForBuyNow] count];
    
    if (count != 0) {
        tbi.badgeValue = [NSString stringWithFormat:@"%d", count];
    } else {
        tbi.badgeValue = nil;
    }
}

- (void)updateApplicationBadgeNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:@"badge"]) {
        NSArray *items = [Item itemsForBuyNow];

        if ([items count]) {
            // found
            [UIApplication sharedApplication].applicationIconBadgeNumber = [items count];
        } else {
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
    } else {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)updateBuyNowTabBadgeNumber
{
    [self setBuyNowTabBadgeNumber];
}

#pragma mark - Tuning in notification

- (void) tuneInGeofenceMonitoringLocationReloadNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:GeofenceMonitoringLocationReloadNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateGeofence];
                                                  }];
}

- (void) tuneInUpdatingApplicationBadgeNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UpdateApplicationBadgeNumberNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateApplicationBadgeNumber];
                                                  }];
}

- (void) tuneInUpdatingBuyNowBadgeNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UpdateBuyNowTabBadgeNumberNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateBuyNowTabBadgeNumber];
                                                  }];
}

#pragma mark - global setting

- (BOOL)useGeofence
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"geofence"];
}

@end
