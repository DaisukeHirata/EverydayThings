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
@property (nonatomic, copy)   NSString *categoryId;
@property (nonatomic, copy)   NSString *name;
@end

@implementation CategoryDialogViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        QRootElement *_root = [[QRootElement alloc] init];
        _root.grouped = YES;
        _root.title = @"New Category";
        self.root = _root;
        self.resizeWhenKeyboardPresented =YES;
        UIBarButtonItem* saveItem = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                   target:self
                                                                                   action:@selector(save:)];
        self.navigationItem.leftBarButtonItem = saveItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.category) {
        self.root.title = self.category.name;
        self.categoryId = self.category.categoryId;
    }
    
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

- (void)save:(id)sender
{
    if ([self.name isEqualToString:@"None"]) {
        [self showAlert:@"A name can not be 'None'"];
        return;
    }
    
    if ([self.name length] != 0) {
        [ItemCategory saveItemCategory:self.values];
    }
    // back to previous viewcontroller
    [self.navigationController popViewControllerAnimated:YES];
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

- (QFontAwesomeRadioElement *)createIconRadioElement
{
    QFontAwesomeRadioElement *icon;
    
    NSArray *icons = [self iconsArray];
    icon = [[QFontAwesomeRadioElement alloc] initWithItems:icons
                                                  selected:self.category ? [self iconIndex:self.category.icon] : 0
                                                     title:@"Icon"];
    icon.itemsImageNames = icons;
    icon.key = @"icon";
    return icon;
}

- (QColorRadioElement *)createColorRadioElement
{
    QColorRadioElement *color;
    NSArray *colors = [self colorsArray];
    color = [[QColorRadioElement alloc] initWithItems:colors
                                             selected:self.category ? [self colorIndex:self.category.color] : 0
                                                title:@"Color"];
    color.key = @"color";
    color.itemsImageNames = colors;
    return color;
}

- (NSMutableDictionary *)values
{
    if (self.root) {
        if (!_values) _values = [[NSMutableDictionary alloc] init];
        [self.root fetchValueIntoObject:_values];
        NSUInteger iconIndex = [_values[@"icon"] integerValue];
        NSUInteger colorIndex = [_values[@"color"] integerValue];
        _values[@"categoryId"] = [self.categoryId length] ? self.categoryId : @"NEW_CATEGORY_DUMMY_ID";
        _values[@"icon"]       = [self iconsArray][iconIndex];
        _values[@"color"]      = [self colorsArray][colorIndex];
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
    NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:[colors allKeys]];
    [allKeys removeObject:@"None"];
    NSArray *keys = allKeys;
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

#pragma mark - normal property getter & setter

- (NSString *)categoryId
{
    if (!_categoryId) _categoryId = [[NSString alloc] init];
    return _categoryId;
}

#pragma mark - quick dialog element property getter & setter

- (NSString *)name
{
    QEntryElement *nameElement = (QEntryElement *)[self.root elementWithKey:@"name"];
    return nameElement.textValue;
}

#pragma mark - Alert Methods

- (void) showAlert:(NSString *)alertText
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:alertText
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}


@end
