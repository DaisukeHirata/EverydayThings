//
//  AmazonProductAdvertisingAPI.h
//  AmazonProductAdvertisingAPI
//
//  Created by Daisuke Hirata on 2014/05/01.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "AmazonProductAdvertisingAPI.h"
#import "NSString+URLEncode.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonHMAC.h>
#import "AmazonItem.h"
#import "AmazonProductAdvertisingAPIKey.h"

@implementation AmazonProductAdvertisingAPI

+ (NSString*)requestURL:(NSString*)ItemId {
    
    //Get the time stamp to enter into requestURL
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
    
    //Enter the time stamp into the parameters
    //Sort the parameter/value pairs by byte value (not alphabetically, lowercase parameters will be listed after uppercase ones).
    NSString *parameters = [NSString stringWithFormat:@"AWSAccessKeyId=%@&AssociateTag=%@&IdType=EAN&ItemId=%@&Operation=ItemLookup&ResponseGroup=Medium&SearchIndex=All&Service=AWSECommerceService&Timestamp=%@&Version=2011-08-01", ACCESS_KEY_ID, ASSOCIATE_TAG, ItemId, timeStamp];
    
    //URL encode the request's comma (,) and colon (:) characters
    NSString *encodedParameters = [parameters minimalUrlEncode];
    
    //Prepend the following three lines(with line breaks) before the canonical string
    // GET
    // necs.amazonaws.jp
    // xml
    NSString *head = @"GET\necs.amazonaws.jp\n/onca/xml";
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@", head, encodedParameters];
    
    //Calculate an RFC 2104-compliant HMAC with the SHA256 hash algorithm using the string above with Secret Access Key
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    const char *cKey = [SECRET_ACCESS_KEY cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [stringToSign cStringUsingEncoding:NSASCIIStringEncoding];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    //base64URL encode the calculated result above
    NSData *HMAC = [[NSData alloc]initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *base64EncodedString = [HMAC base64EncodedString];
    
    //URL encode the plus (+) and equal (=) characters in the signature
    NSString *hash = [base64EncodedString urlEncode];
    
    //Add the URL encoded signature to your request, and the result is a properly-formatted signed request
    NSString *requestURLString = [NSString stringWithFormat:@"http://ecs.amazonaws.jp/onca/xml?%@&Signature=%@", encodedParameters, hash];
    
    return requestURLString;
}

+ (NSArray *)loadAmazonItems:(NSDictionary *)xmlResponse
{
    NSMutableArray *tmpItems = [[NSMutableArray alloc] init];

    NSDictionary *resItems = xmlResponse[@"ItemLookupResponse"][@"Items"];
    
    NSDictionary *error = resItems[@"Request"][@"Errors"][@"Error"];
    if (!error) {
        NSArray *items;
        NSObject *item = resItems[@"Item"];
        if ([item isKindOfClass:[NSArray class]]) {
            items = (NSArray *)item;
        } else if ([item isKindOfClass:[NSDictionary class]]) {
            items = @[item];
        }
        
        for (NSDictionary *item in items) {
            NSDictionary *itemAttributes = item[@"ItemAttributes"];
            NSDictionary *lowestNewPrice = item[@"OfferSummary"][@"LowestNewPrice"];
            NSDictionary *imageSets      = item[@"ImageSets"];
            NSDictionary *imageSet       = [imageSets[@"ImageSet"] isKindOfClass:[NSArray class]] ? imageSets[@"ImageSet"][0] : imageSets[@"ImageSet"];
            
            AmazonItem *amazonItem  = [[AmazonItem alloc] init];
            amazonItem.title        = itemAttributes[@"Title"][@"text"];
            amazonItem.manufacturer = itemAttributes[@"Manufacturer"][@"text"];
            amazonItem.category     = itemAttributes[@"ProductTypeName"][@"text"];
            amazonItem.price        = lowestNewPrice[@"FormattedPrice"][@"text"];
            amazonItem.thumbnailURL = imageSet[@"ThumbnailImage"][@"URL"][@"text"];
            [tmpItems addObject:amazonItem];
        }
    } else {
        NSLog(@"%@", error[@"Message"][@"text"]);
    }
    
    return tmpItems;
}


+ (void)logXmlResponse:(NSDictionary *)xmlResponse
{
    NSLog(@"%@", xmlResponse);
    
    NSDictionary *resItems = xmlResponse[@"ItemLookupResponse"][@"Items"];
    NSDictionary *error = resItems[@"Request"][@"Errors"][@"Error"];
    if (!error) {
        NSArray *items;
        NSObject *item = resItems[@"Item"];
        if ([item isKindOfClass:[NSArray class]]) {
            items = (NSArray *)item;
        } else if ([item isKindOfClass:[NSDictionary class]]) {
            items = @[item];
        }
        
        for (NSDictionary *item in items) {
            NSDictionary *itemAttributes = item[@"ItemAttributes"];
            NSDictionary *lowestNewPrice = item[@"OfferSummary"][@"LowestNewPrice"];
            NSDictionary *imageSets      = item[@"ImageSets"];
            NSDictionary *imageSet       = [imageSets[@"ImageSet"] isKindOfClass:[NSArray class]] ? imageSets[@"ImageSet"][0] : imageSets[@"ImageSet"];
            
            NSLog(@"----------------------------");
            NSLog(@"Title: %@", itemAttributes[@"Title"][@"text"]);
            NSLog(@"Manufacturer: %@", itemAttributes[@"Manufacturer"][@"text"]);
            NSLog(@"ProductTypeName: %@", itemAttributes[@"ProductTypeName"][@"text"]);
            NSLog(@"Price: %@", lowestNewPrice[@"FormattedPrice"][@"text"]);
            NSLog(@"ThumbnailURL: %@", imageSet[@"ThumbnailImage"][@"URL"][@"text"]);
        }
    }
}
@end
