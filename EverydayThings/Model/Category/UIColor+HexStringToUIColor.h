//
//  UIColor+HexStringToUIColor.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 5/16/14.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexStringToUIColor)

+ (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a;

@end
