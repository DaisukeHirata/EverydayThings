//
//  ItemFormViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ItemFormViewController.h"
#import "ItemForm.h"
#import "Item+Helper.h"
#import "ItemCategory+Helper.h"
#import "AppDelegate.h"

@interface ItemFormViewController ()

@end

@implementation ItemFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.formController.form = [[ItemForm alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)addItem:(UITableViewCell<FXFormFieldCell> *)cell
{
    // lookup the form from the cell
    ItemForm *form = cell.field.form;
    
    // save
    [Item saveItem:form];
    
    // return to table view
    [self.navigationController popViewControllerAnimated:YES];

    
/*
    //we can then perform validation, etc
    if (form.agreedToTerms)
    {
        [[[UIAlertView alloc] initWithTitle:@"Login Form Submitted" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"User Error" message:@"Please agree to the terms and conditions before proceeding" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Yes Sir!", nil] show];
    }
*/
}

@end
