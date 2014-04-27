//
//  Item.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/27.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemCategory;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * cycle;
@property (nonatomic, retain) NSNumber * elapsed;
@property (nonatomic, retain) NSDate * expireDate;
@property (nonatomic, retain) NSString * favoriteProductName;
@property (nonatomic, retain) NSNumber * buyNow;
@property (nonatomic, retain) NSNumber * stock;
@property (nonatomic, retain) NSDate * lastPurchaseDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * timeSpan;
@property (nonatomic, retain) NSString * whereToBuy;
@property (nonatomic, retain) NSString * whereToStock;
@property (nonatomic, retain) NSNumber * geofence;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) ItemCategory *whichItemCategory;

@end
