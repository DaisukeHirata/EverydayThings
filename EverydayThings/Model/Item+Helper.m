//
//  Item+Helper.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "AppDelegate.h"
#import "Item+Helper.h"
#import "ItemCategory+Helper.h"

@implementation Item (Helper)

+ (Item *)saveItem:(ItemForm *)form
{
    Item *item = nil;
    NSManagedObjectContext *context = [AppDelegate sharedContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", form.name];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // error
        item = nil; // not necessary. it's for readability
    } else if  ([matches count]) {
        // update
        item = [matches firstObject];
    } else {
        // insert
        item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                             inManagedObjectContext:context];
    }
    
    if (item) {
        item.name                   = form.name;
        item.isBuyNow               = [[NSNumber alloc] initWithBool:form.buyNow];
        item.isStock                = [[NSNumber alloc] initWithBool:form.stock];
        item.lastPurchaseDate       = form.lastPurchaseDate;
        item.expireDate             = form.expireDate;
        item.whereToBuy             = form.whereToBuy;
        item.favoriteProductName    = form.favoriteProductName;
        item.whereToStock           = form.whereToStock;
        item.cycle                  = [NSDecimalNumber decimalNumberWithString:form.cycle];
        item.timeSpan               = form.timeSpan;
        item.whichItemCategory      = [ItemCategory itemCategoryWithName:form.category ? form.category : @"None"];
        item.elapsed                = [item elapsedDaysAfterLastPurchaseDate] > [item cycleInDays] ? @1 : @0;
                
        NSError *error = nil;
        [context save:&error];
        if(error) {
            NSLog(@"could not save data : %@", error);
        }
    }
    
    return item;
}

- (NSInteger)expiredWeeks
{
	// now - expire date
	NSTimeInterval since = 0;
    
    if (self.expireDate) {
        since = [[NSDate date] timeIntervalSinceDate:self.expireDate];
    }
    
    // convert second into week
    return (NSInteger)since/(7*24*60*60);
}

- (NSInteger)elapsedDaysAfterLastPurchaseDate
{
	// now - last purchase date
	NSTimeInterval since = 0;
    
    if (self.lastPurchaseDate) {
        since = [[NSDate date] timeIntervalSinceDate:self.lastPurchaseDate];
    }
    
    // convert second into day
    return (NSInteger)since/(24*60*60);
}

- (NSInteger)cycleInDays
{
    NSInteger cycle = 0;
    
    if (![self.cycle isEqualToNumber:[NSDecimalNumber notANumber]]) {
        cycle = [self.cycle longValue];
        if ([self.timeSpan isEqualToString:@"Month"]) {
            cycle = [self.cycle longValue] * 30;
        } else if ([self.timeSpan isEqualToString:@"Year"]) {
            cycle = [self.cycle longValue] * 365;
        }
    }
    
    return cycle;
}

@end
