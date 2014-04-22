//
//  ItemForm.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXForms.h"

typedef NS_OPTIONS(NSInteger, Interests)
{
    InterestComputers = 1 << 0,
    InterestSocializing = 1 << 1,
    InterestSports = 1 << 2
};

@interface ItemForm : NSObject <FXForm>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, assign) BOOL buyNow;
@property (nonatomic, assign) BOOL stock;

@property (nonatomic, copy) NSString *cycle;
@property (nonatomic, copy) NSString *timeSpan;

@property (nonatomic, strong) NSDate *lastPurchaseDate;
@property (nonatomic, strong) NSDate *expireDate;
@property (nonatomic, copy) NSString *whereToBuy;
@property (nonatomic, copy) NSString *favoriteProductName;
@property (nonatomic, copy) NSString *whereToStock;

@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, strong) UIImage *profilePhoto;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSArray *interests;
@property (nonatomic, assign) Interests otherInterests;
@property (nonatomic, copy) NSString *about;

@property (nonatomic, copy) NSString *notifications;

@property (nonatomic, assign) BOOL agreedToTerms;

@end
