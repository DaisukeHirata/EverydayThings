//
//  ItemDialogViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/25.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "ItemDialogViewController.h"
#import "Item+Helper.h"
#import "ItemCategory+Helper.h"
#import "SearchAddressViewController.h"
#import "JANCodeReaderViewController.h"
#import "GeoFenceLocationSaveNotification.h"
#import "FAKFontAwesome.h"
#import "AmazonItem.h"

@interface ItemDialogViewController ()
@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic, copy)   NSString *itemId;
@property (nonatomic, copy)   NSString *location;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@end

@implementation ItemDialogViewController

#pragma mark - view controller life cycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        QRootElement *_root = [[QRootElement alloc] init];
        _root.grouped = YES;
        _root.title = @"Item";
        self.root = _root;
        self.resizeWhenKeyboardPresented =YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.item) {
        // update item
        self.itemId   = self.item.itemId;
        self.latitude = self.item.latitude;
        self.longitude = self.item.longitude;
        self.location = self.item.location;
    } else {
        // new item
        // add barcode button at left side.
        UIImage *image = [UIImage imageWithStackedIcons:@[[FAKFontAwesome barcodeIconWithSize:20]]
                                              imageSize:CGSizeMake(20, 20)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                                  style:UIBarButtonItemStyleBordered
                                                                                 target:self
                                                                                 action:@selector(barcode)];
    }

    [self createQuickDialogElementsWithItem:self.item];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:GeofenceLocationSaveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSDictionary *info = note.userInfo[GeofenceLocationSaveNotificationItem];
                                                      NSLog(@"location done %@", info[@"location"]);
                                                      self.location  = info[@"location"];
                                                      self.latitude  = info[@"latitude"];
                                                      self.longitude = info[@"longitude"];
                                                  }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    
    if ([self.location length]) {
        QButtonWithLabelElement *location = (QButtonWithLabelElement *)[self.root elementWithKey:@"location"];
        location.value = self.location;
        [self.quickDialogTableView reloadCellForElements:location, nil];
    }
    
    if (self.amazonItem) {
        QEntryElement *name = (QEntryElement *)[self.root elementWithKey:@"name"];
        name.textValue = self.amazonItem.title;
        [self.quickDialogTableView reloadCellForElements:name, nil];
        NSLog(@"amazon category %@", self.amazonItem.category);
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        if ([self.values[@"name"] length]) {
            [Item saveItem:self.values];
        }
    }
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - create dialog elements

- (void)createQuickDialogElementsWithItem:(Item *)item
{
    //
    // General section
    //
    QSection *section = [[QSection alloc] init];
    QEntryElement *name = [[QEntryElement alloc] initWithTitle:@"Name"
                                                         Value:item ? item.name : @""
                                                   Placeholder:@"Enter name"];
    name.appearance.entryAlignment = NSTextAlignmentRight;
    QRadioElement *category = [[QRadioElement alloc] initWithItems:[ItemCategory categories]
                                                          selected:item ? [[ItemCategory categories] indexOfObject:item.whichItemCategory.name] : 0
                                                             title:@"Category"];
    QButtonElement *photo = [[QButtonElement alloc] initWithTitle:@"Photo"];
    photo.image = [UIImage imageWithStackedIcons:@[[FAKFontAwesome barcodeIconWithSize:20]]
                                       imageSize:CGSizeMake(20, 20)];
    photo.onSelected =  ^{
        NSLog(@"pushed");
	};
    QBooleanElement *buyNow = [[QBooleanElement alloc] initWithTitle:@"Buy Now"
                                                           BoolValue:item ? [item.buyNow boolValue] : NO];
    QDateTimeInlineElement *expireDate = [[QDateTimeInlineElement alloc] initWithTitle:@"Expire Date"
                                                                                  date:item ? item.expireDate : nil
                                                                               andMode:UIDatePickerModeDate];
    [self.root addSection:section];
    [section addElement:name];
    [section addElement:category];
//    [section addElement:photo];
    [section addElement:buyNow];
    [section addElement:expireDate];
    name.key = @"name";
    category.key = @"category";
    buyNow.key = @"buyNow";
    expireDate.key = @"expireDate";
    
    
    //
    // Cycle to resupply section
    //
    QBooleanElement *stock = [[QBooleanElement alloc] initWithTitle:@"Stock"
                                                          BoolValue:item ? [item.stock boolValue ] : NO];
    QSection *sectionCycleToResuplly = [[QSection alloc] initWithTitle:@"Cycle to resupply"];
    QEntryElement *cycle = [[QEntryElement alloc] initWithTitle:@"Cycle"
                                                          Value:item ? [item.cycle stringValue]: @""
                                                    Placeholder:@""];
    cycle.appearance.entryAlignment = NSTextAlignmentRight;
    cycle.keyboardType = UIKeyboardTypeNumberPad;
    QRadioElement *timeSpan = [[QRadioElement alloc] initWithItems:[Item timeSpans]
                                                          selected:item ? [[Item timeSpans] indexOfObject:item.timeSpan] : 0
                                                             title:@"Time Span"];
    QDateTimeInlineElement *lastPurchaseDate =
    [[QDateTimeInlineElement alloc] initWithTitle:@"Last Purchase Date"
                                             date:item ? item.lastPurchaseDate : nil
                                          andMode:UIDatePickerModeDate];
    QButtonWithLabelElement *button = [[QButtonWithLabelElement alloc] initWithTitle:@"I bought this."];
    button.onSelected =  ^{
        NSLog(@"pushed");
	};
    [self.root addSection:sectionCycleToResuplly];
    [sectionCycleToResuplly addElement:stock];
    [sectionCycleToResuplly addElement:cycle];
    [sectionCycleToResuplly addElement:timeSpan];
    [sectionCycleToResuplly addElement:lastPurchaseDate];
//    [sectionCycleToResuplly addElement:button];
    stock.key = @"stock";
    cycle.key = @"cycle";
    timeSpan.key = @"timeSpan";
    lastPurchaseDate.key = @"lastPurchaseDate";
    
    
    //
    // Cycle to resupply section
    //
    QSection *sectionDetail = [[QSection alloc] initWithTitle:@"Detail"];
    QEntryElement *whereToBuy = [[QEntryElement alloc] initWithTitle:@"Where to buy"
                                                               Value:@""
                                                         Placeholder:@"Enter"];
    QEntryElement *favoriteProductName = [[QEntryElement alloc] initWithTitle:@"Favorite Product Name"
                                                                        Value:@""
                                                                  Placeholder:@"Enter"];
    QEntryElement *whereToStock = [[QEntryElement alloc] initWithTitle:@"Where to stock"
                                                                 Value:@""
                                                           Placeholder:@"Enter"];
    [self.root addSection:sectionDetail];
    [sectionDetail addElement:whereToBuy];
    [sectionDetail addElement:favoriteProductName];
    [sectionDetail addElement:whereToStock];
    whereToBuy.key = @"whereToBuy";
    favoriteProductName.key = @"favoriteProductName";
    whereToStock.key = @"whereToStock";
    
    
    //
    // Geofence
    //
    QSection *sectionGeofence = [[QSection alloc] initWithTitle:@"Geofence"];
    QBooleanElement *geofence = [[QBooleanElement alloc] initWithTitle:@"enable Geofence for this item?"
                                                             BoolValue:item ? [item.geofence boolValue] : NO];
    geofence.onSelected = ^{
        NSLog(@"selected");
        QBooleanElement *geofence = (QBooleanElement *)[[self root] elementWithKey:@"geofence"];
        QButtonWithLabelElement *location = (QButtonWithLabelElement *)[[self root] elementWithKey:@"location"];
        location.enabled = geofence.boolValue ? YES : NO;
        NSLog(@"%@", geofence.value);
        [self.quickDialogTableView reloadCellForElements:location, nil];
    };
    QButtonWithLabelElement *locationButton = [[QButtonWithLabelElement alloc] initWithTitle:@"Location"];
    locationButton.onSelected =  ^{
        SearchAddressViewController *searchAddressViewController =
        [[self storyboard] instantiateViewControllerWithIdentifier:@"SearchAddressViewController"];
        [self.navigationController pushViewController:searchAddressViewController animated:YES];
	};
    locationButton.enabled = item ? [item.geofence boolValue] ? YES : NO : NO;
    locationButton.value = item ? self.location : @"";
    [self.root addSection:sectionGeofence];
    [sectionGeofence addElement:geofence];
    [sectionGeofence addElement:locationButton];
    geofence.key = @"geofence";
    locationButton.key = @"location";
    
}

- (void)barcode
{
    NSLog(@"barcode pressed");
    JANCodeReaderViewController *janCodeReaderViewController =
    [[self storyboard] instantiateViewControllerWithIdentifier:@"JANCodeReaderViewControllerID"];
    [self.navigationController pushViewController:janCodeReaderViewController animated:YES];
}

#pragma mark - getter

- (NSMutableDictionary *)values
{
    if (self.root) {
        if (!_values) _values = [[NSMutableDictionary alloc] init];
        [self.root fetchValueIntoObject:_values];
        _values[@"itemId"] = [self.itemId length] ? self.itemId : @"NEW_ITEM_DUMMY_ID";
        if (self.location)  _values[@"location"]  = self.location;
        if (self.latitude)  _values[@"latitude"]  = self.latitude;
        if (self.longitude) _values[@"longitude"] = self.longitude;
        return _values;
    } else {
        return nil;
    }
}

- (NSNumber *)latitude
{
    if (!_latitude) _latitude = [[NSNumber alloc] init];
    return _latitude;
}

- (NSNumber *)longitude
{
    if (!_longitude) _longitude = [[NSNumber alloc] init];
    return _longitude;
}

- (NSString *)location
{
    if (!_location) _location = [[NSString alloc] init];
    return _location;
}

- (NSString *)itemId
{
    if (!_itemId) _itemId = [[NSString alloc] init];
    return _itemId;
}


@end
