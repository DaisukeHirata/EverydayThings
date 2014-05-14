//
//  CategoryDialogViewController.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 5/13/14.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "QuickDialogController.h"

@class ItemCategory;

@interface CategoryDialogViewController : QuickDialogController

@property (nonatomic, strong) ItemCategory *category;

@end
