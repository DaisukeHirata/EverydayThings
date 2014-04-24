//
//  ItemFormViewController.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "FXForms.h"

@class Item;

@interface ItemFormViewController : FXFormViewController

// in
@property (nonatomic, strong) Item *item;

@end
