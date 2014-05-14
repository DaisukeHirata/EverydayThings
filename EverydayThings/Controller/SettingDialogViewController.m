//
//  SettingDialogViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/24.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "SettingDialogViewController.h"
#import "SearchAddressViewController.h"
#import "GeoFenceMonitoringLocationReloadNotification.h"
#import "UpdateApplicationBadgeNumberNotification.h"
#import "EditItemCategoryTableViewController.h"

@interface SettingDialogViewController ()

@end

@implementation SettingDialogViewController

#define WeakSelf __weak __typeof__(self)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        QRootElement *_root = [[QRootElement alloc] init];
        _root.grouped = YES;
        _root.title = @"Setting";
        self.root = _root;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    
    //
    // category
    //
    QSection *categorySection = [[QSection alloc] initWithTitle:@"Item Category"];
    QButtonElement *categoryButton = [[QButtonElement alloc] initWithTitle:@"Edit Category"];
    WeakSelf weakSelf = self;
    categoryButton.onSelected = ^{
        EditItemCategoryTableViewController *editItemCategoryTableViewController =
        [[weakSelf storyboard] instantiateViewControllerWithIdentifier:@"EditItemCategoryTableViewController"];
        [weakSelf.navigationController pushViewController:editItemCategoryTableViewController animated:YES];
    };

    categoryButton.key = @"category";

    
    //
    // geofence
    //
    BOOL geofenceValue = [defaults boolForKey:@"geofence"];
    QSection *locationServiceSection = [[QSection alloc] initWithTitle:@"Location Service"];
    QBooleanElement *geofence = [[QBooleanElement alloc] initWithTitle:@"Use GeoFence"
                                                             BoolValue:geofenceValue ? geofenceValue : NO];
    geofence.onSelected = ^{
        QBooleanElement *geofence = (QBooleanElement *)[[self root] elementWithKey:@"geofence"];
        [defaults setBool:geofence.boolValue forKey:@"geofence"];
        [defaults synchronize];
        // geofence region changed.
        [[NSNotificationCenter defaultCenter] postNotificationName:GeofenceMonitoringLocationReloadNotification
                                                            object:self
                                                          userInfo:nil];
    };
    geofence.key = @"geofence";

    
    //
    // badge
    //
    BOOL baddeValue = [defaults boolForKey:@"badge"];
    QSection *homeScreenSection = [[QSection alloc] initWithTitle:@"Home Screen"];
    QBooleanElement *badge = [[QBooleanElement alloc] initWithTitle:@"Show BuyNow Badge"
                                                          BoolValue:baddeValue ? baddeValue : NO];
    badge.onSelected = ^{
        QBooleanElement *badge = (QBooleanElement *)[[self root] elementWithKey:@"badge"];
        [defaults setBool:badge.boolValue forKey:@"badge"];
        [defaults synchronize];
        // update application badge
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateApplicationBadgeNumberNotification
                                                            object:self
                                                          userInfo:nil];
    };
    badge.key = @"badge";

    
    //
    // Feedback
    //
    
    
    [self.root addSection:categorySection];
    [categorySection addElement:categoryButton];
    
    [self.root addSection:locationServiceSection];
    [locationServiceSection addElement:geofence];
    
    [self.root addSection:homeScreenSection];
    [homeScreenSection addElement:badge];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    [super viewWillAppear:animated];
}

@end
