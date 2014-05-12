//
//  LocationManager.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 5/8/14.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface LocationManager : NSObject
+ (LocationManager *)sharedLocationManager;
- (BOOL)isLocationManagerAvaiable;
- (void)initializeLocationManager;
- (void)stopMonitoringAllRegions;
- (void)stopMonitoringRegions:(NSArray *)regions;
- (void)initializeRegionMonitoring:(NSArray*)geofences;
- (NSArray *)buildAllGeofenceData;
- (NSArray *)buildGeofenceDataForItem:(Item *)item;
- (BOOL)monitoredRegion:(NSString *)region;
- (BOOL)insideRegion:(NSString *)region;
@end
