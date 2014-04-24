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
    request.fetchLimit = 100;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[AppDelegate sharedContext]
                                                                          sectionNameKeyPath:@"whichItemCategory.name"
                                                                                   cacheName:nil];
}

#pragma mark - Table view data source delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"All Items Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = item.name;
    
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
