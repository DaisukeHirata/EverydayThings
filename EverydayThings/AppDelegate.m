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
#import <CoreLocation/CoreLocation.h>
#import "Item.h"
#import "GeoFenceMonitoringLocationChangedNotification.h"

@interface AppDelegate()<CLLocationManagerDelegate>
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
    
    // Location Manager setup
    if ([self isLocationManagerAvaiable]) {
        [self initializeLocationManager];
        [self initializeRegionMonitoring:[self buildGeofenceData]];
        [self initializeLocationUpdates];
    }
    
    // tune in geofence region change notification
    [self updateGeoFenceLocation];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"LocalNotification recieved.");
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
}

- (void) setupTabBar
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

#pragma mark - Geofence monitoring Location changed

- (void) updateGeoFenceLocation
{
    [[NSNotificationCenter defaultCenter] addObserverForName:GeoFenceMonitoringLocationChangedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"location changed");
                                                      // Location Manager setup
                                                      if ([self isLocationManagerAvaiable]) {
                                                          [self stopLocationUpdates];
                                                          [self initializeLocationManager];
                                                          [self initializeRegionMonitoring:[self buildGeofenceData]];
                                                          [self initializeLocationUpdates];
                                                      }
                                                  }];
}

#pragma mark - Location utility

CLLocationManager *_locationManager;
NSArray *_regionArray;

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
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
}


- (void) initializeRegionMonitoring:(NSArray*)geofences
{

    if (_locationManager == nil) {
        [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
    }
    
    for(CLRegion *geofence in geofences) {
        [_locationManager startMonitoringForRegion:geofence];
    }
    
}

- (NSArray *)buildGeofenceData
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"geofence = YES"];
    request.fetchLimit = 30;
    NSError *error;
    NSArray *matches = [[AppDelegate sharedContext] executeFetchRequest:request error:&error];
    NSMutableArray *geofences = [NSMutableArray array];
    
    if (!matches || error) {
        // error
        NSLog(@"can not read geofence location data from item managed object");
    } else if  ([matches count]) {
        // found
        for (Item *item in matches) {
            NSLog(@"%@", item.location);
            CLRegion *region = [self mapItemToRegion:item];
            region.notifyOnEntry = YES;
            region.notifyOnExit = NO;
            [geofences addObject:region];
        }
    }
    
    return geofences;
}

- (CLRegion*)mapItemToRegion:(Item *)item
{
    NSString *title = item.location;
    
    CLLocationDegrees latitude = [item.latitude doubleValue];
    CLLocationDegrees longitude =[item.longitude doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = 500;
    
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

- (void)initializeLocationUpdates
{
    [_locationManager startUpdatingLocation];
}

- (void)stopLocationUpdates
{
    [_locationManager stopUpdatingLocation];
}


#pragma mark - Location Manager - Region Task Methods

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered Region - %@", region.identifier);
    
    // register notification
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = [NSString stringWithFormat:@"Entered Region - %@", region.identifier];
    notification.alertAction = @"Open";
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited Region - %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Started monitoring %@ region %f %f", region.identifier, region.center.latitude, region.center.longitude);
}

#pragma mark - Location Manager - Standard Task Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%@", [NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude, newLocation.coordinate.longitude]);
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
