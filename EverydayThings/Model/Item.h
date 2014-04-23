//
//  Item.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/23.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemCategory;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * cycle;
@property (nonatomic, retain) NSDate * expireDate;
@property (nonatomic, retain) NSString * favoriteProductName;
@property (nonatomic, retain) NSNumber * isBuyNow;
@property (nonatomic, retain) NSNumber * isStock;
@property (nonatomic, retain) NSDate * lastPurchaseDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * timeSpan;
@property (nonatomic, retain) NSString * whereToBuy;
@property (nonatomic, retain) NSString * whereToStock;
@property (nonatomic, retain) NSNumber * elapsed;
@property (nonatomic, retain) ItemCategory *whichItemCategory;

@end
