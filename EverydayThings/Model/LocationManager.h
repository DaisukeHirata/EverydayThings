//
//  LocationManager.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 5/8/14.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationManager : NSObject
+ (LocationManager *)sharedLocationManager;
- (BOOL)isLocationManagerAvaiable;
- (void)initializeLocationManager;
- (void)stopMonitoringAllRegions;
- (void)initializeRegionMonitoring:(NSArray*)geofences;
- (NSArray *)buildGeofenceData;
- (BOOL)monitoredRegion:(NSString *)region;
- (BOOL)insideRegion:(NSString *)region;
@end
