//
//  ItemListTableViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "ItemListTableViewController.h"
#import "ItemFormViewController.h"
#import "ItemForm.h"
#import "AppDelegate.h"

@interface ItemListTableViewController ()

@end

@implementation ItemListTableViewController

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


// delete row delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[AppDelegate sharedContext] deleteObject:managedObject];
        [[AppDelegate sharedContext] save:nil];
    }
}

@end
