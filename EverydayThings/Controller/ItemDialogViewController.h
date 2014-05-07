//
//  ItemDialogViewController.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/25.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "QuickDialogController.h"

@class Item;
@class AmazonItem;

@interface ItemDialogViewController : QuickDialogController

// in
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) AmazonItem *amazonItem;

@end
