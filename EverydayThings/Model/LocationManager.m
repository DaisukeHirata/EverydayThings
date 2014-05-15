//
//  LocationManager.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 5/8/14.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "LocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "Item+Helper.h"
#import "GeofenceRegionStateChangedNotification.h"

@interface LocationManager() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *regionStates;
@end

@implementation LocationManager

#pragma mark - Location Manager shared instance

static LocationManager *_sharedLocationManager = nil;

+ (LocationManager *)sharedLocationManager
{
    if (!_sharedLocationManager) {
        _sharedLocationManager = [[LocationManager alloc] init];
    }
    return _sharedLocationManager;
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
        if ([self.regionStates objectForKey:region.identifier]) {
            [self.regionStates removeObjectForKey:region.identifier];
        }
    }
}

- (void)stopMonitoringRegions:(NSArray *)regions
{
    for (CLRegion *region in regions) {
        NSLog(@"stop monitoring region %@", region.identifier);
        [self.locationManager stopMonitoringForRegion:region];
        if ([self.regionStates objectForKey:region.identifier]) {
            [self.regionStates removeObjectForKey:region.identifier];
        }
    }
}

- (NSArray *)buildAllGeofenceData
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

- (NSArray *)buildGeofenceDataForItem:(Item *)item;
{
    NSMutableArray *geofences = [NSMutableArray array];
    
    CLRegion *region = [self mapItemToRegion:item];
    [geofences addObject:region];
    
    return geofences;
}

- (void)checkStateForAllMonitoredRegions
{
    NSLog(@"---checkStateForAllMonitoredRegions---");
    self.regionStates = [[NSMutableDictionary alloc] init];
    for (CLRegion *region in [_locationManager monitoredRegions]) {
        [self.locationManager requestStateForRegion:region];
    }
}

- (BOOL)monitoredRegion:(NSString *)region
{
    return [self.regionStates objectForKey:region] != nil ? YES : NO;
}

- (BOOL)insideRegion:(NSString *)region
{
    return [self.regionStates[region] boolValue];
}

/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

- (CLRegion*)mapItemToRegion:(Item *)item
{
    NSString *title = item.location;
    
    CLLocationDegrees latitude = [item.latitude doubleValue];
    CLLocationDegrees longitude =[item.longitude doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = 400.0; // 1 ~ 400 meters work better.
    
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
    [self checkStateForAllMonitoredRegions];
    
    // delete all local notification
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
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
    [self checkStateForAllMonitoredRegions];
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

        // immediate check would fail sometimes. check state after 2 sec. 
        [NSTimer scheduledTimerWithTimeInterval:0.5f
                                         target:self
                                       selector:@selector(requestStateForRegion:)
                                       userInfo:@{@"region":region}
                                        repeats:NO];
        
    }
}

- (void)requestStateForRegion:(NSTimer*)timer{
    [self.locationManager requestStateForRegion:timer.userInfo[@"region"]];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"didDetermineState:%@(%@)", [self regionStateString:state], region.identifier);
    
    if ([region isKindOfClass:[CLCircularRegion class]]) {
        switch (state) {
            case CLRegionStateInside:
                self.regionStates[region.identifier] = [NSNumber numberWithBool:YES];
                break;
            case CLRegionStateOutside:
            case CLRegionStateUnknown:
                self.regionStates[region.identifier] = [NSNumber numberWithBool:NO];
                break;
        }
    }
    
    // notify region state changed
    [[NSNotificationCenter defaultCenter] postNotificationName:GeofenceRegionStateChangedNotification
                                                        object:self
                                                      userInfo:nil];

}

- (NSString *)regionStateString:(CLRegionState)state
{
    switch (state) {
        case CLRegionStateInside:
            return @"inside";
        case CLRegionStateOutside:
            return @"outside";
        case CLRegionStateUnknown:
            return @"unknown";
    }
    return @"";
}

- (NSMutableDictionary *)regionStates
{
    if (!_regionStates) _regionStates = [[NSMutableDictionary alloc] init];
    return _regionStates;
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
