//
//  ExpireListTableViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ExpireListTableViewController.h"
#import "AppDelegate.h"
#import "Item+Helper.h"

@interface ExpireListTableViewController ()

@end

@implementation ExpireListTableViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];

    // 1 week later
    NSDate *today = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setWeek:1];
    NSDate *nearFutureDate = [cal dateByAddingComponents:comps toDate:today options:0];
    request.predicate = [NSPredicate predicateWithFormat:@"expireDate < %@", nearFutureDate];
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
    static NSString *CellIdentifier = @"Expire List Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = item.name;
    
    return cell;
}


@end
