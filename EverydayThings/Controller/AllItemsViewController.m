//
//  AllItemsViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "AllItemsViewController.h"
#import "AppDelegate.h"
#import "Item+Helper.h"
#import "ItemCategory+Helper.h"
#import "TDBadgedCell.h"

@interface AllItemsViewController ()

@end

@implementation AllItemsViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = nil; // all of Item.
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"whichItemCategory.name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[AppDelegate sharedContext]
                                                                          sectionNameKeyPath:@"whichItemCategory.name"
                                                                                   cacheName:nil];
}

#pragma mark - Table view data source delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"All Items Cell";
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // adjust font size by text length
    cell.textLabel.minimumScaleFactor = 0.5f;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = item.name;
    
    cell.detailTextLabel.textColor = [UIColor hexToUIColor:@"FF6100" alpha:1.0];
    cell.detailTextLabel.text      = [item.geofence boolValue] ? item.location : nil;
    
    cell.imageView.image = [ItemCategory iconWithCategoryName:item.whichItemCategory.name];
    if ([item.geofence boolValue]) {
        cell.accessoryView = [self geofenceImageViewMonitored:[self.locationManager monitoredRegion:item.location]
                                                 insideRegion:[self.locationManager insideRegion:item.location]];
    } else {
        cell.accessoryView = nil;
    }
    if ([item.stock boolValue]) {
        cell.badgeString = [NSString stringWithFormat:@"%ld/%ld",
                            (long)[item elapsedDaysAfterLastPurchaseDate],
                            (long)[item cycleInDays]];
        if ([item.elapsed isEqualToNumber:@1]) {
            // elpased
            cell.badgeColor = [UIColor hexToUIColor:@"dc143c" alpha:1.0];
        } else {
            cell.badgeColor = [UIColor lightGrayColor];
        }
    } else {
        cell.badgeString = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Section name
    NSString *sectionName = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    // color
    if ([[ItemCategory colors] objectForKey:sectionName]) {
        
        // Background
        view.tintColor = [ItemCategory colors][sectionName];
        
        // Text
        if (![sectionName isEqualToString:@"None"]) {
            UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
            [header.textLabel setTextColor:[UIColor whiteColor]];
        }
    }
}

@end
