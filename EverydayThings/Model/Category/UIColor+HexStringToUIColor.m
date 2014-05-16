//
//  UIColor+HexStringToUIColor.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 5/16/14.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "UIColor+HexStringToUIColor.h"

@implementation UIColor (HexStringToUIColor)

+ (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a
{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
