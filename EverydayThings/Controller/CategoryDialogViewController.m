//
//  CategoryDialogViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 5/13/14.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "CategoryDialogViewController.h"
#import "ItemCategory+Helper.h"
#import "FAKFontAwesome.h"

@interface CategoryDialogViewController ()
@property (nonatomic, strong) NSMutableDictionary *values;
@end

@implementation CategoryDialogViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        QRootElement *_root = [[QRootElement alloc] init];
        _root.grouped = YES;
        _root.title = @"Item";
        self.root = _root;
        self.resizeWhenKeyboardPresented =YES;
        /*
        UIBarButtonItem* saveItem = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                   target:self
                                                                                   action:@selector(save:)];
        self.navigationItem.leftBarButtonItem = saveItem;
         */
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    QSection *section = [[QSection alloc] initWithTitle:@"Category"];
    [section addElement:[self createNameEntryElement]];
    [section addElement:[self createIconRadioElement]];
    [section addElement:[self createColorRadioElement]];
        
    [self.root addSection:section];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSString *name = self.values[@"icon"];
    NSLog(@"%@", name);
    
    [ItemCategory saveItemCategory:self.values];
}

#pragma mark - Create QuickDialog Element

#define WeakSelf __weak __typeof__(self)

- (QEntryElement *)createNameEntryElement
{
    QEntryElement *name;
    name = [[QEntryElement alloc] initWithTitle:@"Name"
                                          Value:self.category ? self.category.name : @""
                                    Placeholder:@"Enter name"];
    name.appearance.entryAlignment = NSTextAlignmentRight;
    name.key = @"name";
    return name;
}

- (QRadioElement *)createIconRadioElement
{
    QRadioElement *icon;
    
    NSArray *icons = [self iconsArray];
    icon = [[QRadioElement alloc] initWithItems:icons
                                       selected:self.category ? [self iconIndex:self.category.icon] : 0
                                          title:@"Icon"];
    icon.itemsImageNames = icons;
    icon.key = @"icon";
    return icon;
}

- (QRadioElement *)createColorRadioElement
{
    QRadioElement *color;
    color = [[QRadioElement alloc] initWithItems:[self colorsArray]
                                        selected:self.category ? [self colorIndex:self.category.color] : 0
                                           title:@"Color"];
    color.key = @"color";
    return color;
}

- (NSMutableDictionary *)values
{
    if (self.root) {
        if (!_values) _values = [[NSMutableDictionary alloc] init];
        [self.root fetchValueIntoObject:_values];
        NSUInteger iconIndex = [_values[@"icon"] integerValue];
        NSUInteger colorIndex = [_values[@"color"] integerValue];
        _values[@"icon"]  = [self iconsArray][iconIndex];
        _values[@"color"] = [self colorsArray][colorIndex];
        return _values;
    } else {
        return nil;
    }
}

- (NSArray *)iconsArray
{
    NSDictionary *icons = [FAKFontAwesome allIcons];
    NSArray* values = [icons allValues];
    // sort
    values = [values sortedArrayUsingComparator:^(id o1, id o2) {
        return [o1 compare:o2];
    }];
    return values;
}

- (NSUInteger)iconIndex:(NSString *)name
{
    NSArray *icons = [self iconsArray];
    return [icons indexOfObject:name];
}

- (NSArray *)colorsArray
{
    NSDictionary *colors = [ItemCategory colorChoices];
    NSArray* keys = [colors allKeys];
    // sort
    keys = [keys sortedArrayUsingComparator:^(id o1, id o2) {
        return [o1 compare:o2];
    }];
    return keys;
}

- (NSUInteger)colorIndex:(NSString *)name
{
    NSArray *colors = [self colorsArray];
    return [colors indexOfObject:name];
}

@end
