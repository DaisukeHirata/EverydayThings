//
//  ItemCategory+Helper.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "ItemCategory.h"

@interface ItemCategory (Helper)

+ (ItemCategory *)itemCategoryWithName:(NSString *)name;
+ (ItemCategory *)itemCategoryWithIndex:(NSUInteger)index;
+ (ItemCategory *)saveItemCategory:(NSDictionary *)values;

+ (NSArray *)categories;
+ (NSDictionary *)colors;
+ (NSDictionary *)icons;

+ (NSDictionary *)colorChoices;
+ (UIImage *)iconWithCategoryName:(NSString *)name;
+ (NSFetchRequest *)fetchAllRequest;
+ (void)insertInitialData;

@end
