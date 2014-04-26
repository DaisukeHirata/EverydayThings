//
//  ItemDialogViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/25.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "ItemDialogViewController.h"
#import "ItemCategory+Helper.h"

@interface ItemDialogViewController ()

@end

@implementation ItemDialogViewController

#pragma mark - view controller life cycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        QRootElement *_root = [[QRootElement alloc] init];
        _root.grouped = YES;
        _root.title = @"New Item";
        self.root = _root;
        self.resizeWhenKeyboardPresented =YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createQuickDialogElements];

    if (self.item) {
        NSLog(@"for update");
/*
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
*/
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;

    // very bad practice to fit size
    self.quickDialogTableView.contentInset=UIEdgeInsetsMake(0.0, 0.0, [self getMaxHeight] + 150, 0);
    self.quickDialogTableView.scrollIndicatorInsets = self.quickDialogTableView.contentInset;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        NSLog(@"Save !!");
    }
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - create dialog elements

- (void)createQuickDialogElements
{
    //
    // General section
    //
    QSection *section = [[QSection alloc] init];
    QEntryElement *name = [[QEntryElement alloc] initWithTitle:@"Name" Value:@"" Placeholder:@"Enter name"];
    QRadioElement *category = [[QRadioElement alloc] initWithItems:[ItemCategory categories] selected:0 title:@"Category"];
    QBooleanElement *buyNow = [[QBooleanElement alloc] initWithTitle:@"Buy Now" BoolValue:NO];
    QBooleanElement *stock = [[QBooleanElement alloc] initWithTitle:@"Stock" BoolValue:NO];
    QDateTimeInlineElement *expireDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Expire Date" date:nil andMode:UIDatePickerModeDate];
    [self.root addSection:section];
    [section addElement:name];
    [section addElement:category];
    [section addElement:buyNow];
    [section addElement:stock];
    [section addElement:expireDate];
    
    
    //
    // purchase section
    //
    QSection *sectionPurchase = [[QSection alloc] initWithTitle:@"Purchase"];
    QDateTimeInlineElement *lastPurchaseDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Last Purchase Date" date:nil andMode:UIDatePickerModeDate];
    QButtonWithLabelElement *button = [[QButtonWithLabelElement alloc] initWithTitle:@"I bought this."];
    button.onSelected =  ^{
        NSLog(@"pushed");
	};
    [self.root addSection:sectionPurchase];
    [sectionPurchase addElement:lastPurchaseDate];
    [sectionPurchase addElement:button];
    
    
    //
    // Cycle to resupply section
    //
    QSection *sectionCycleToResuplly = [[QSection alloc] initWithTitle:@"Cycle to resupply"];
    QEntryElement *cycle = [[QEntryElement alloc] initWithTitle:@"Cycle" Value:@"" Placeholder:@""];
    cycle.keyboardType = UIKeyboardTypeNumberPad;
    QRadioElement *timeSpan = [[QRadioElement alloc] initWithItems:@[@"Day", @"Month", @"YEAR"] selected:0 title:@"Time Span"];
    [self.root addSection:sectionCycleToResuplly];
    [sectionCycleToResuplly addElement:cycle];
    [sectionCycleToResuplly addElement:timeSpan];
    
    
    //
    // Cycle to resupply section
    //
    QSection *sectionDetail = [[QSection alloc] initWithTitle:@"Detail"];
    QEntryElement *whereToBuy = [[QEntryElement alloc] initWithTitle:@"Where to buy" Value:@"" Placeholder:@"Enter"];
    QEntryElement *favoriteProductName = [[QEntryElement alloc] initWithTitle:@"Favorite Product Name" Value:@"" Placeholder:@"Enter"];
    QEntryElement *whereToStock = [[QEntryElement alloc] initWithTitle:@"Where to stock" Value:@"" Placeholder:@"Enter"];
    [self.root addSection:sectionDetail];
    [sectionDetail addElement:whereToBuy];
    [sectionDetail addElement:favoriteProductName];
    [sectionDetail addElement:whereToStock];
}

#pragma mark - helper methods

-(float)getMaxHeight
{
    float h = 0;
    
    for (UIView *v in [self.quickDialogTableView subviews]) {
        float fh = v.frame.origin.y + v.frame.size.height;
        h = MAX(fh, h);
    }
    
    return h;
}
@end
