//
//  PlaceAnnotation
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//
#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, retain) NSURL *url;

@end


