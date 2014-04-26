//
//  ItemListTableViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "ItemListTableViewController.h"
#import "ItemFormViewController.h"
#import "ItemDialogViewController.h"
#import "ItemForm.h"
#import "AppDelegate.h"

@interface ItemListTableViewController ()

@end

@implementation ItemListTableViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // needs to upload section header color
    [self.tableView reloadData];
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
    /*
    ItemFormViewController *controller = [[ItemFormViewController alloc] init];
    controller.formController.form = [[ItemForm alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    */
    ItemDialogViewController *itemDialogViewController =
    [[self storyboard] instantiateViewControllerWithIdentifier:@"ItemDialogViewController"];
    [self.navigationController pushViewController:itemDialogViewController animated:YES];
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
    }
}

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

@end
