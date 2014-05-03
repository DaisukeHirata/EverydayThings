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

static NSString *accessKeyID = @"AKIAIFXPDKTR5HBTUTXA";
static NSString *associateTag = @"daisukihirata-22";
static NSString *secretAccessKey = @"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";

@implementation AmazonProductAdvertisingAPI

+ (NSString*)requestURL:(NSString*)ItemId {
    
    //Get the time stamp to enter into requestURL
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSString *timeStamp = [formatter stringFromDate:[NSDate date]];
    
    //Enter the time stamp into the parameters
    //Sort the parameter/value pairs by byte value (not alphabetically, lowercase parameters will be listed after uppercase ones).
    NSString *parameters = [NSString stringWithFormat:@"AWSAccessKeyId=%@&AssociateTag=%@&IdType=EAN&ItemId=%@&Operation=ItemLookup&ResponseGroup=Medium&SearchIndex=All&Service=AWSECommerceService&Timestamp=%@&Version=2011-08-01", accessKeyID, associateTag, ItemId, timeStamp];
    
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
    const char *cKey = [secretAccessKey cStringUsingEncoding:NSASCIIStringEncoding];
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

+ (void)logXmlResponse:(NSDictionary *)xmlResponse
{
    NSLog(@"%@", xmlResponse);
    if ([xmlResponse[@"ItemLookupResponse"][@"Items"][@"Item"] isKindOfClass:[NSArray class]]) {
        NSArray *items = xmlResponse[@"ItemLookupResponse"][@"Items"][@"Item"];
        for (NSDictionary *item in items) {
            NSLog(@"%@", item[@"ItemAttributes"][@"Title"][@"text"]);
            if ([item[@"ImageSets"][@"ImageSet"] isKindOfClass:[NSArray class]]) {
                NSArray *imageSetArray = item[@"ImageSets"][@"ImageSet"];
                for (NSDictionary *imageSet in imageSetArray) {
                    NSLog(@"Thumbnail %@", imageSet[@"ThumbnailImage"][@"URL"][@"text"]);
                }
            } else {
                NSLog(@"%@", item[@"ImageSets"][@"ImageSet"][@"ThumbnailImage"][@"URL"][@"text"]);
            }
        }
    } else if ([xmlResponse[@"ItemLookupResponse"][@"Items"][@"Item"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *item = xmlResponse[@"ItemLookupResponse"][@"Items"][@"Item"];
        NSLog(@"%@", item[@"ItemAttributes"][@"Title"][@"text"]);
        if ([item[@"ImageSets"][@"ImageSet"] isKindOfClass:[NSArray class]]) {
            NSArray *imageSetArray = item[@"ImageSets"][@"ImageSet"];
            for (NSDictionary *imageSet in imageSetArray) {
                NSLog(@"Thumbnail %@", imageSet[@"ThumbnailImage"][@"URL"][@"text"]);
            }
        } else {
            NSLog(@"%@", item[@"ImageSets"][@"ImageSet"][@"ThumbnailImage"][@"URL"][@"text"]);
        }
    }
}

+ (NSArray *)loadAmazonItems:(NSDictionary *)xmlResponse
{
    NSMutableArray *tmpItems = [[NSMutableArray alloc] init];
    if ([xmlResponse[@"ItemLookupResponse"][@"Items"][@"Item"] isKindOfClass:[NSArray class]]) {
        NSArray *items = xmlResponse[@"ItemLookupResponse"][@"Items"][@"Item"];
        for (NSDictionary *item in items) {
            AmazonItem *amazonItem = [[AmazonItem alloc] init];
            amazonItem.title = item[@"ItemAttributes"][@"Title"][@"text"];
            amazonItem.manufacturer = item[@"ItemAttributes"][@"Manufacturer"][@"text"];
            amazonItem.price = item[@"OfferSummary"][@"LowestNewPrice"][@"FormattedPrice"][@"text"];
            if ([item[@"ImageSets"][@"ImageSet"] isKindOfClass:[NSArray class]]) {
                amazonItem.thumbnailURL = item[@"ImageSets"][@"ImageSet"][0][@"ThumbnailImage"][@"URL"][@"text"];
            } else {
                amazonItem.thumbnailURL = item[@"ImageSets"][@"ImageSet"][@"ThumbnailImage"][@"URL"][@"text"];
            }
            [tmpItems addObject:amazonItem];
        }
    } else if ([xmlResponse[@"ItemLookupResponse"][@"Items"][@"Item"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *item = xmlResponse[@"ItemLookupResponse"][@"Items"][@"Item"];
        AmazonItem *amazonItem = [[AmazonItem alloc] init];
        amazonItem.title = item[@"ItemAttributes"][@"Title"][@"text"];
        amazonItem.manufacturer = item[@"ItemAttributes"][@"Manufacturer"][@"text"];
        amazonItem.price = item[@"OfferSummary"][@"LowestNewPrice"][@"FormattedPrice"][@"text"];
        if ([item[@"ImageSets"][@"ImageSet"] isKindOfClass:[NSArray class]]) {
            amazonItem.thumbnailURL = item[@"ImageSets"][@"ImageSet"][0][@"ThumbnailImage"][@"URL"][@"text"];
        } else {
            amazonItem.thumbnailURL = item[@"ImageSets"][@"ImageSet"][@"ThumbnailImage"][@"URL"][@"text"];
        }
        [tmpItems addObject:amazonItem];
    }
    return tmpItems;
}
@end
