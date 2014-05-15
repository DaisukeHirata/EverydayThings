//
//  AmazonItem.m
//  AmazonProductAdvertisingAPI
//
//  Created by Daisuke Hirata on 2014/05/01.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "AmazonItem.h"

@implementation AmazonItem

- (NSString *)category
{
    if (!_category) {
        _category = [[NSString alloc] init];
    }
    NSString *capitalizedCategory = [_category capitalizedString];
    capitalizedCategory = [capitalizedCategory stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    capitalizedCategory = [capitalizedCategory stringByReplacingOccurrencesOfString:@"Abis " withString:@""];
    return capitalizedCategory;
}

@end
