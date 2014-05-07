//
//  BuyNowTableViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "BuyNowTableViewController.h"
#import "AppDelegate.h"
#import "Item+Helper.h"
#import "ItemCategory+Helper.h"
#import "TDBadgedCell.h"
#import "UpdateApplicationBadgeNumberNotification.h"

@interface BuyNowTableViewController ()
@end

@implementation BuyNowTableViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *request = [Item createRequestForBuyNowItems];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[AppDelegate sharedContext]
                                                                          sectionNameKeyPath:@"whichItemCategory.name"
                                                                                   cacheName:nil];

}




#pragma mark - Table view data source delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Buy Now Cell";
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = item.name;
    cell.imageView.image = [ItemCategory iconWithCategoryName:item.whichItemCategory.name];
    if ([item cycleInDays]) {
        cell.badgeString = [NSString stringWithFormat:@"%ld/%ld",
                            (long)[item elapsedDaysAfterLastPurchaseDate],
                            (long)[item cycleInDays]];
        if ([item.elapsed isEqualToNumber:@1]) {
            // elpased
            cell.badgeColor = [self hexToUIColor:@"dc143c" alpha:1.0];
        } else {
            cell.badgeColor = [UIColor lightGrayColor];
        }
    }
    if ([item.geofence boolValue]) {        
        cell.accessoryView = [self geofenceImageView];
        [cell.accessoryView setFrame:CGRectMake(0, 0, 12, 12)];
    } else {
        cell.accessoryView = nil;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Section name
    NSString *sectionName = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    if ([[ItemCategory colors] objectForKey:sectionName]) {
        // Background color
        view.tintColor = [ItemCategory colors][sectionName];

        // Text Color
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        [header.textLabel setTextColor:[UIColor whiteColor]];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    
    // update application badge
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateApplicationBadgeNumberNotification
                                                        object:self
                                                      userInfo:nil];
}

@end
