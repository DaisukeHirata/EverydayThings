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

- (NSArray*) buildGeofenceData {
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"regions" ofType:@"plist"];
    _regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    NSMutableArray *geofences = [NSMutableArray array];
    for(NSDictionary *regionDict in _regionArray) {
        CLRegion *region = [self mapDictionaryToRegion:regionDict];
        region.notifyOnEntry = YES;
        region.notifyOnExit = NO;
        [geofences addObject:region];
    }
    
    return [NSArray arrayWithArray:geofences];
}

- (CLRegion*)mapDictionaryToRegion:(NSDictionary*)dictionary
{
    NSString *title = [dictionary valueForKey:@"title"];
    
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
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
//    [self showRegionAlert:@"Exiting Region" forRegion:region.identifier];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Started monitoring %@ region", region.identifier);
}

#pragma mark - Location Manager - Standard Task Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//    self.coordinateLabel.text = [NSString stringWithFormat:@"%f,%f",newLocation.coordinate.latitude, newLocation.coordinate.longitude];
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
