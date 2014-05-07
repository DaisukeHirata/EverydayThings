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
#import <CoreLocation/CoreLocation.h>
#import "Item+helper.h"
#import "GeoFenceMonitoringLocationReloadNotification.h"
#import "UpdateApplicationBadgeNumberNotification.h"

@interface AppDelegate()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation AppDelegate
/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // setup tabbar
    [self setupTabBar];
    [self setTabBarBadgeNumber];
    
    // Location Manager setup
    if ([self isLocationManagerAvaiable] && [self useGeofence]) {
        [self initializeLocationManager];
        [self stopMonitoringAllRegions];
        [self initializeRegionMonitoring:[self buildGeofenceData]];
    }
    
    // tune in geofence region change notification
    [self tuneInGeoFenceMonitoringLocationReloadNotification];
    
    // tune in update appication badge notification
    [self tuneInUpdatingApplicationBadgeNotification];
    
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
    
    //tab2 all items
    UITabBarItem *tab2 = tabItems[1];
    UIImage *list = [UIImage imageWithStackedIcons:@[[FAKFontAwesome listIconWithSize:iconSize]]
                                         imageSize:iconImageSize];
    tab2.image = list;
    
    //tab3 expired
    UITabBarItem *tab3 = tabItems[2];
    UIImage *exclamation = [UIImage imageWithStackedIcons:@[[FAKFontAwesome exclamationCircleIconWithSize:iconSize]]
                                                imageSize:iconImageSize];
    tab3.image = exclamation;
    
    //tab4 setting
    UITabBarItem *tab4 = tabItems[3];
    UIImage *cog = [UIImage imageWithStackedIcons:@[[FAKFontAwesome cogIconWithSize:iconSize]]
                                        imageSize:iconImageSize];
    tab4.image = cog;
}

- (void)setTabBarBadgeNumber
{
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    NSArray *tabItems = tabController.tabBar.items;

    UITabBarItem *tbi = (UITabBarItem*)tabItems[0];
    
    NSString *badgeNumber = [NSString stringWithFormat:@"%d", [[Item itemsForBuyNow] count]];
    [tbi setBadgeValue:badgeNumber];
}

- (BOOL)useGeofence
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"geofence"];
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

- (void)updateGeofence
{
    if ([self isLocationManagerAvaiable]) {
        [self stopMonitoringAllRegions];
        if ([self useGeofence]) {
            [self initializeLocationManager];
            [self initializeRegionMonitoring:[self buildGeofenceData]];
        }
    }
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

#pragma mark - Tuning in notification

- (void) tuneInGeoFenceMonitoringLocationReloadNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:GeoFenceMonitoringLocationReloadNotification
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

#pragma mark - Location utility

- (BOOL)isLocationManagerAvaiable
{
    
    if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]]) {
        // Region monitoring is not available for this Class;
        [self showAlertWithMessage:@"This app requires region monitoring features which are unavailable on this device."];
        return NO;
    }
    
    if(![CLLocationManager locationServicesEnabled]) {
        // You need to enable Location Services
        [self showAlertWithMessage:@"This app requires region monitoring features. First you need to enable Location Services."];
        return NO;
    }
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted  ) {
        // You need to authorize Location Services for the APP
        [self showAlertWithMessage:@"You need to authorize Location Services for the app"];
        return NO;
    }
    
    return YES;
}

- (void)initializeLocationManager
{
    // Check to ensure location services are enabled
    if(![CLLocationManager locationServicesEnabled]) {
        [self showAlertWithMessage:@"You need to enable location services to use this app."];
        return;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}


- (void)initializeRegionMonitoring:(NSArray*)geofences
{

    if (self.locationManager == nil) {
        [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
    }
    
    for(CLRegion *geofence in geofences) {
        [self.locationManager startMonitoringForRegion:geofence];
    }
    
}

- (void)stopMonitoringAllRegions
{
    for (CLRegion *region in [_locationManager monitoredRegions]) {
        NSLog(@"stop monitoring region %@", region.identifier);
        [self.locationManager stopMonitoringForRegion:region];
    }
}

- (NSArray *)buildGeofenceData
{
    NSMutableArray *geofences = [NSMutableArray array];

    NSArray *items = [Item itemsForGeofence];
    
    for (Item *item in items) {
        CLRegion *region = [self mapItemToRegion:item];
//        region.notifyOnEntry = NO;
//        region.notifyOnExit = NO;
        [geofences addObject:region];
    }
    
    return geofences;
}

- (CLRegion*)mapItemToRegion:(Item *)item
{
    NSString *title = item.location;
    
    CLLocationDegrees latitude = [item.latitude doubleValue];
    CLLocationDegrees longitude =[item.longitude doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = 200.0; // 1 ~ 400 meters work better.
    
    CLRegion * region =nil;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                    radius:regionRadius
                                                identifier:title];
    } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        // iOS 7 below
        region = [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                         radius:regionRadius
                                                     identifier:title];
#pragma GCC diagnostic pop
    }
    
    return region;
}

#pragma mark - Location Manager - Region Task Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered Region -> %@", region.identifier);
    
    // register notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [NSString stringWithFormat:@"Entered Region - %@", region.identifier];
    notification.alertAction = @"Open";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited Region <- %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Error Monitoring Region %@ %@", region.identifier, error);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        CLCircularRegion *circularRegion = (CLCircularRegion *)region;
        NSLog(@"Started monitoring %@ region %f %f", circularRegion.identifier, circularRegion.center.latitude, circularRegion.center.longitude);
    }
}

#pragma mark - Location Manager - Standard Task Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@", [NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude, newLocation.coordinate.longitude]);
}

// for more accurate location. However, which can result in higher power usage.
- (void)initializeLocationUpdates
{
    [_locationManager startUpdatingLocation];
}

- (void)stopLocationUpdates
{
    [_locationManager stopUpdatingLocation];
}

#pragma mark - Alert Methods

- (void) showRegionAlert:(NSString *)alertText forRegion:(NSString *)regionIdentifier
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:alertText
                                                      message:regionIdentifier
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

- (void)showAlertWithMessage:(NSString*)alertText
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Error"
                                                        message:alertText
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
