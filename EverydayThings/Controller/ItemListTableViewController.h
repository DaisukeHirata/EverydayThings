//
//  ItemListTableViewController.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface ItemListTableViewController : CoreDataTableViewController

- (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a;

@end
