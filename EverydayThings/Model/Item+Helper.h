//
//  Item+Helper.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "Item.h"
#import "ItemForm.h"

@interface Item (Helper)

+ (Item *)saveItem:(ItemForm *)form;

@end
