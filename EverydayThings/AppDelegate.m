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
#import "UpdateDueDateTabBadgeNumberNotification.h"
#import "UpdateCategoryToNoneNotification.h"

@interface AppDelegate()
@property (nonatomic, strong) LocationManager *locationManager;
@end

@implementation AppDelegate

#pragma mark - Application Delegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Navigation bar appearance
    [self setupNavigagtionBarAppearance];
    
    // setup tabbar
    [self setupTabBar];

    // Location Manager setup
    if ([self.locationManager isLocationManagerAvaiable] && [self useGeofence]) {
        [self.locationManager initializeLocationManager];
        [self.locationManager stopMonitoringAllRegions];
        [self.locationManager initializeRegionMonitoring:[self.locationManager buildAllGeofenceData]];
    }
    
    // tune in geofence region change notification
    [self tuneInGeofenceMonitoringLocationReloadNotification];
    
    // tune in update appication badge notification
    [self tuneInUpdatingApplicationBadgeNotification];
    
    // tune in updating buy now tab badge number notification
    [self tuneInUpdatingBuyNowBadgeNotification];
    
    // tune in updating due date tab badge number notification
    [self tuneInUpdatingDueDateBadgeNotification];
    
    // tune in updating category of items to none if a category used by those items.
    [self tuneInUpdateCategoryToNoneNotification];
    
    // turn on badge update in background
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}

- (void)setupNavigagtionBarAppearance
{
    UIColor *textColor  = [self hexToUIColor:@"FF6100" alpha:1.0];
    self.window.tintColor = textColor;
}

- (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a
{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self updateApplicationBadgeNumber];
    [self updateAllGeofence];
    [Item updateElapsed];
    // you need to end your performFetchWithCompletionHandler by responding back that you're finished and provide a status
    // iOS expects you to return this promptly, within about 30 seconds, otherwise it will start to penalize your app’s background execution
    // to preserve battery life.
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [Item updateElapsed];
    });
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

- (void)updateAllGeofence
{
    if ([self.locationManager isLocationManagerAvaiable]) {
        [self.locationManager stopMonitoringAllRegions];
        if ([self useGeofence]) {
            [self.locationManager initializeLocationManager];
            [self.locationManager initializeRegionMonitoring:[self.locationManager buildAllGeofenceData]];
        }
    }
}

- (void)updateGeofenceForItem:(Item *)item
{
    if ([self.locationManager isLocationManagerAvaiable]) {
        NSArray *regions = [self.locationManager buildGeofenceDataForItem:item];
        if ([self.locationManager monitoredRegion:item.name]) {
            [self.locationManager stopMonitoringRegions:regions];            
        }
        if ([self useGeofence] &&
            [item.geofence isEqualToNumber:@1] &&
            ([item.buyNow isEqualToNumber:@1] || [item.elapsed isEqualToNumber:@1]) ) {
            [self.locationManager initializeRegionMonitoring:regions];
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
    
    //tab2 due date
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

- (void)updateBuyNowTabBadgeNumber
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

- (void)updateDueDateTabBadgeNumber
{
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    NSArray *tabItems = tabController.tabBar.items;
    
    UITabBarItem *tbi = (UITabBarItem*)tabItems[1];
    NSUInteger count = [[Item itemsForPastDueDate] count];
    
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

#pragma mark - Tuning in notification

- (void) tuneInGeofenceMonitoringLocationReloadNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:GeofenceMonitoringLocationReloadNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      if (note.userInfo[@"item"]) {
                                                          [self updateGeofenceForItem:note.userInfo[@"item"]];
                                                      } else {
                                                          [self updateAllGeofence];
                                                      }
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

- (void) tuneInUpdatingDueDateBadgeNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UpdateDueDateTabBadgeNumberNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self updateDueDateTabBadgeNumber];
                                                  }];
}


- (void) tuneInUpdateCategoryToNoneNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:UpdateCategoryToNoneNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [Item updateCategoryToNone:note.userInfo[@"categoryName"]];
                                                  }];
}

#pragma mark - global setting

- (BOOL)useGeofence
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"geofence"];
}

@end
