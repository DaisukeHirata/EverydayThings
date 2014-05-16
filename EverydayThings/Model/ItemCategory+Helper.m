//
//  ItemCategory+Helper.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemCategory+Helper.h"
#import "FAKFontAwesome.h"

@implementation ItemCategory (Helper)

+ (ItemCategory *)saveItemCategory:(NSDictionary *)values
{
    ItemCategory *category = nil;
    NSManagedObjectContext *context = [AppDelegate sharedContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemCategory"];
    request.predicate = [NSPredicate predicateWithFormat:@"categoryId = %@", values[@"categoryId"]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // error
        category = nil; // not necessary. it's for readability
    } else if  ([matches count]) {
        // update
        category = [matches firstObject];
    } else {
        // insert
        category = [NSEntityDescription insertNewObjectForEntityForName:@"ItemCategory"
                                                 inManagedObjectContext:context];
        category.categoryId = [[NSUUID UUID] UUIDString];
    }
    
    if (category) {
        category.name  = values[@"name"];
        category.color = values[@"color"];
        category.icon  = values[@"icon"];
        
        NSError *error = nil;
        [context save:&error];
        if(error) {
            NSLog(@"could not save data : %@", error);
        }
    }
    
    return category;
}

+ (ItemCategory *)itemCategoryWithName:(NSString *)name
{
    ItemCategory *category = nil;
    NSManagedObjectContext *context = [AppDelegate sharedContext];
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemCategory"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            category       = [NSEntityDescription insertNewObjectForEntityForName:@"ItemCategory"
                                                           inManagedObjectContext:context];
            category.categoryId = [[NSUUID UUID] UUIDString];
            category.name       = name;
            category.color      = @"Default";
            category.icon       = @"circleO";
            NSError *error = nil;
            [context save:&error];
            if(error){
                NSLog(@"could not save data : %@", error);
            }
        } else {
            category = [matches lastObject];
        }
    }
    
    return category;
}

+ (ItemCategory *)itemCategoryWithIndex:(NSUInteger)index
{
    NSString *name = [ItemCategory categories][index];
    return [self itemCategoryWithName:name];
}

+ (NSFetchRequest *)fetchAllRequest
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemCategory"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    return request;
}

+ (NSFetchRequest *)fetchAllRequestExceptNone
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItemCategory"];
    request.predicate = [NSPredicate predicateWithFormat:@"name != %@", @"None"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    return request;
}

+ (NSArray *)fetchAll
{
    NSArray *matches = nil;
    
    NSFetchRequest *request = [self fetchAllRequest];
    NSError *error;
    matches = [[AppDelegate sharedContext] executeFetchRequest:request error:&error];
    
    if (error) {
        // error
        NSLog(@"can not read category data.");
    }

    return matches;
}

+ (NSArray *)categories
{
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    
    NSArray *matches = [self fetchAll];
    
    for (ItemCategory *category in matches) {
        [categories addObject:category.name];
    }
    
    return categories;
}

+ (NSDictionary *)colors
{
    NSMutableDictionary *colors = [[NSMutableDictionary alloc] init];
    
    NSArray *matches = [self fetchAll];
    
    for (ItemCategory *category in matches) {
        NSString *colorCode = [self colorChoices][category.color];
        colors[category.name] = [self hexToUIColor:colorCode alpha:1.0];
    }
    
    return colors;
}

+ (NSDictionary *)icons
{
    NSMutableDictionary *icons = [[NSMutableDictionary alloc] init];
        
    NSDictionary *allFonts = [FAKFontAwesome allIconFonts];

    NSArray *matches = [self fetchAll];
    for (ItemCategory *category in matches) {
        NSString *iconName = category.icon;
        icons[category.name] = allFonts[iconName];
    }
    
    return icons;
}

+ (NSDictionary *)colorChoices
{
    return @{@"Red"    : @"DB1100",
             @"Yellow" : @"FFD119",
             @"Blue"   : @"3775CB",
             @"Brown"  : @"987D45",
             @"Green"  : @"45A76F",
             @"Pink"   : @"F50087",
             @"Orange" : @"F56B47",
             @"Purple" : @"49003E",
             @"Gray"   : @"736D66",
             @"Default": @"00008F",
             @"Moss"   : @"4B7401",
             @"None"   : @"F7F7F7"};
}

+ (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a
{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (UIImage *)iconWithCategoryName:(NSString *)name
{
    UIImage *image;
    NSDictionary *icons = [self icons];
    image = [UIImage imageWithStackedIcons:@[icons[name]]
                                 imageSize:CGSizeMake(20, 20)];
    return image;
}

+ (NSArray *)iconNameWithCategoryName:(NSArray *)names
{
    NSMutableArray *iconNames = [[NSMutableArray alloc] init];
    for (NSString *name in names) {
        ItemCategory *category = [self itemCategoryWithName:name];
        [iconNames addObject:category.icon];
    }
    return iconNames;
}

+ (void)insertInitialData
{
    NSLog(@"this is initial insertion.");
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"InitialData" ofType:@"plist"];
    NSArray* initialDataList = [NSArray arrayWithContentsOfFile:path];
    
    if (initialDataList) {
        
        NSManagedObjectContext* context = [AppDelegate sharedContext];
        
        for (NSDictionary *dataDict in initialDataList) {
            // insert category
            ItemCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"ItemCategory"
                                                                   inManagedObjectContext:context];
            category.categoryId = [[NSUUID UUID] UUIDString];
            category.name       = dataDict[@"name"];
            category.color      = dataDict[@"color"];
            category.icon       = dataDict[@"icon"];
            
            NSError *error = nil;
            [context save:&error];
            
            if (error) {
                NSLog(@"Initialize data failed: %@", error);
            }
        }
    } else {
        NSLog(@"Initialize Data file not found");
        abort();
    }
}

@end
