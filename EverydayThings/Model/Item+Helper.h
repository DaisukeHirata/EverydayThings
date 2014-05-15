//
//  Item+Helper.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "Item.h"

@interface Item (Helper)

+ (Item *)saveItem:(NSDictionary *)values;
- (NSInteger)cycleInDays;
- (NSInteger)elapsedDaysAfterLastPurchaseDate;
+ (NSArray *)timeSpans;
+ (NSFetchRequest *)createRequestForBuyNowItems;
+ (NSFetchRequest *)createRequestForDueDateItems;
+ (NSArray *)itemsForGeofence;
+ (NSArray *)itemsForBuyNow;
+ (NSArray *)itemsForPastDueDate;
+ (void)updateElapsed;
+ (void)updateCategoryToNone:(NSString *)name;

@end
