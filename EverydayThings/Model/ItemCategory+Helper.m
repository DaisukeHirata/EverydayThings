//
//  ItemCategory+Helper.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "AppDelegate.h"
#import "ItemCategory+Helper.h"

@implementation ItemCategory (Helper)

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
            category.name  = name;
            category.color = @"FFD119";
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

+ (NSArray *)categories
{
    return @[@"Grocery", @"Food", @"Emergency Goods", @"Drug"];
}

+ (NSDictionary *)colors
{
    return @{@"Grocery"         : [self hexToUIColor:@"FFD119" alpha:1.0],
             @"Food"            : [self hexToUIColor:@"38AD26" alpha:1.0],
             @"Emergency Goods" : [self hexToUIColor:@"987D45" alpha:1.0],
             @"Drug"            : [self hexToUIColor:@"3775CB" alpha:1.0]};
}

+ (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
