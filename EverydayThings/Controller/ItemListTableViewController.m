//
//  ItemListTableViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "ItemListTableViewController.h"
#import "ItemDialogViewController.h"
#import "AppDelegate.h"
#import "FAKFontAwesome.h"
#import "GeofenceRegionStateChangedNotification.h"
#import "UpdateApplicationBadgeNumberNotification.h"
#import "UpdateBuyNowTabBadgeNumberNotification.h"
#import "UpdateDueDateTabBadgeNumberNotification.h"

@interface ItemListTableViewController ()

@end

@implementation ItemListTableViewController

#pragma mark - View Controller Lifecycle

/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) //should check version to prevent force closed
    {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 14, 0, 0);;
    }

    // when region changed, then reload data to sync geofence icon color
    [self tuneInGeofenceRegionStateChangedNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateBadgeNumberNotification];
    
    [self.tableView reloadData];
}

#pragma mark - tableview controller delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ItemDialogViewController *itemDialogViewController =
    [[self storyboard] instantiateViewControllerWithIdentifier:@"ItemDialogViewController"];
    itemDialogViewController.item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:itemDialogViewController animated:YES];
}

// hide section index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

// delete row delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[AppDelegate sharedContext] deleteObject:managedObject];
        [[AppDelegate sharedContext] save:nil];
        
        [self updateBadgeNumberNotification];
    }
}

#pragma mark - navigation

- (IBAction)addButtonPressed:(UIBarButtonItem *)sender {
    ItemDialogViewController *itemDialogViewController =
    [[self storyboard] instantiateViewControllerWithIdentifier:@"ItemDialogViewController"];
    [self.navigationController pushViewController:itemDialogViewController animated:YES];
}

#pragma mark - notification

- (void) tuneInGeofenceRegionStateChangedNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:GeofenceRegionStateChangedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self.tableView reloadData];
                                                  }];
}


#pragma mark - util

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

- (UIImageView *)geofenceImageViewMonitored:(BOOL)monitored insideRegion:(BOOL)inside
{
    UIImage *image;

    FAKFontAwesome *arrowIcon = [FAKFontAwesome locationArrowIconWithSize:12];
    [arrowIcon addAttribute:NSForegroundColorAttributeName value:[self hexToUIColor:@"d3d3d3" alpha:0.7]];
    
    if (inside) {
        [arrowIcon addAttribute:NSForegroundColorAttributeName value:[self hexToUIColor:@"0056d9" alpha:1.0]];
        image = [UIImage imageWithStackedIcons:@[arrowIcon] imageSize:CGSizeMake(12, 12)];
    }
    else if (monitored) {
        [arrowIcon addAttribute:NSForegroundColorAttributeName value:[self hexToUIColor:@"d788ff" alpha:0.5]];
        FAKFontAwesome *borderIcon = [FAKFontAwesome locationArrowIconWithSize:4.5];
        [borderIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        image = [UIImage imageWithStackedIcons:@[arrowIcon, borderIcon] imageSize:CGSizeMake(12, 12)];
    }
    else
    {
        image = [UIImage imageWithStackedIcons:@[arrowIcon] imageSize:CGSizeMake(12, 12)];
    }
    
    return [[UIImageView alloc] initWithImage:image];
}

- (void)updateBadgeNumberNotification
{
    // update application badge number.
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateApplicationBadgeNumberNotification
                                                        object:self
                                                      userInfo:nil];
    
    // update buy now tab badge number.
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateBuyNowTabBadgeNumberNotification
                                                        object:self
                                                      userInfo:nil];
    
    // update due date tab badge number.
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateDueDateTabBadgeNumberNotification
                                                        object:self
                                                      userInfo:nil];

}


#pragma mark - Location manager things

- (LocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [LocationManager sharedLocationManager];
    }
    return _locationManager;
}



@end
