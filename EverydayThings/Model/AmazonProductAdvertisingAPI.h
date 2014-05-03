//
//  AmazonProductAdvertisingAPI.h
//  AmazonProductAdvertisingAPI
//
//  Created by Daisuke Hirata on 2014/05/01.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmazonProductAdvertisingAPI : NSObject

+ (NSString*)requestURL:(NSString*)ItemId;
+ (void)logXmlResponse:(NSDictionary *)xmlResponse;
+ (NSArray *)loadAmazonItems:(NSDictionary *)items;

@end
