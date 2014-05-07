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
    request.fetchLimit = 300;
    
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
    
    cell.textLabel.text = item.name;
    cell.imageView.image = [ItemCategory iconWithCategoryName:item.whichItemCategory.name];
    if ([item.geofence boolValue]) {
        cell.accessoryView = [self geofenceImageView];
        [cell.accessoryView setFrame:CGRectMake(0, 0, 12, 12)];
    } else {
        cell.accessoryView = nil;
    }
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
    } else {
        cell.badgeString = nil;
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

@end
