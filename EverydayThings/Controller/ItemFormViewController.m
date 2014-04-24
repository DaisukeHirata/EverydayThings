//
//  ItemFormViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
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
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Save"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(saveItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    if (self.item) {
        ItemForm *form = self.formController.form;
        form.name                = self.item.name;
        form.category            = self.item.whichItemCategory.name;
        form.buyNow              = [self.item.isBuyNow boolValue];
        form.stock               = [self.item.isStock boolValue];
        form.lastPurchaseDate    = self.item.lastPurchaseDate;
        form.expireDate          = self.item.expireDate;
        form.whereToBuy          = self.item.whereToBuy;
        form.favoriteProductName = self.item.favoriteProductName;
        form.whereToStock        = self.item.whereToStock;
        form.cycle               = [self.item.cycle stringValue];
        form.timeSpan            = self.item.timeSpan;
    }
}

- (void)saveItem:(UIBarButtonItem *)sender
{
    // save
    [Item saveItem:self.formController.form];
    
    // return to table view
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)purchase:(UITableViewCell<FXFormFieldCell> *)cell
{
    // lookup the form from the cell
    ItemForm *form = cell.field.form;
    
    NSLog(@"Purchased %@", form.name);
    
    form.lastPurchaseDate = [NSDate date];
    
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
