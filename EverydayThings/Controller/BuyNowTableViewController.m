//
//  BuyNowTableViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "BuyNowTableViewController.h"
#import "ItemFormViewController.h"
#import "ItemForm.h"
#import "EverydayThingsDatabaseAvailability.h"
#import "AppDelegate.h"
#import "Item+Helper.h"

@interface BuyNowTableViewController ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@end

@implementation BuyNowTableViewController

#pragma mark - View Controller Lifecycle

- (void)awakeFromNib
{
    // tune in a managed object context notification radio station at very first.
    // when database context is ready, then fetch conversion units data from a server,
    // after fetching finished , set property.
    [[NSNotificationCenter defaultCenter]
        addObserverForName:EverydayThingsDatabaseAvailabilityNotification
                    object:nil
                     queue:nil
                usingBlock:^(NSNotification *note) {
                    NSLog(@"Database Ready");
                    self.managedObjectContext = note.userInfo[EverydayThingsDatabaseAvailabilityContext];
                }];
}

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
    static NSString *CellIdentifier = @"Item Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Item *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = item.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ItemFormViewController *controller = [[ItemFormViewController alloc] init];
    controller.formController.form = [[ItemForm alloc] init];
    controller.item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:controller animated:YES];
}

// hide section index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}


- (IBAction)addButtonPressed:(UIBarButtonItem *)sender {
    ItemFormViewController *controller = [[ItemFormViewController alloc] init];
    controller.formController.form = [[ItemForm alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
