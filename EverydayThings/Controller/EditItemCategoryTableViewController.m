//
//  EditItemCategoryTableViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 5/13/14.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "EditItemCategoryTableViewController.h"
#import "CategoryDialogViewController.h"
#import "ItemCategory+helper.h"
#import "AppDelegate.h"
#import "FAKFontAwesome.h"
#import "UpdateCategoryToNoneNotification.h"

@interface EditItemCategoryTableViewController ()

@end

@implementation EditItemCategoryTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *request = [ItemCategory fetchAllRequestExceptNone];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[AppDelegate sharedContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.tabBarController.tabBar.hidden = YES;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath* indexPath = nil;
    indexPath = [self.tableView indexPathForCell:sender];
    
    CategoryDialogViewController *categoryDialogViewController =
                                (CategoryDialogViewController *)segue.destinationViewController;
    
    ItemCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (category) {
        categoryDialogViewController.category = category;
    }
}

#pragma mark - tableview delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Item Category Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ItemCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // adjust font size by text length
    cell.textLabel.minimumScaleFactor = 0.5f;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.imageView.image = [ItemCategory iconWithCategoryName:category.name];
    cell.textLabel.text = category.name;
    cell.textLabel.textColor = [ItemCategory colors][category.name];
    
    return cell;
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

        ItemCategory *category = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSString *categoryName = category.name;

        // update category if this category is used by items.
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateCategoryToNoneNotification
                                                            object:self
                                                          userInfo:@{@"categoryName":categoryName}];

        // delete and save
        [[AppDelegate sharedContext] deleteObject:category];
        [[AppDelegate sharedContext] save:nil];
    }
}


@end
