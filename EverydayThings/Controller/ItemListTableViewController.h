//
//  ItemListTableViewController.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "LocationManager.h"

@interface ItemListTableViewController : CoreDataTableViewController
@property (nonatomic, strong) LocationManager *locationManager;

- (UIImageView *)geofenceImageViewMonitored:(BOOL)monitored insideRegion:(BOOL)inside;

@end
