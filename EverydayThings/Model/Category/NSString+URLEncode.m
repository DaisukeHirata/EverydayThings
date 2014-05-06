#import "NSString+URLEncode.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (URLEncode)

-(NSString *)urlEncode {
	return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               kCFStringEncodingUTF8);
}

- (NSString *)minimalUrlEncode {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@",:",
                                                               kCFStringEncodingUTF8);
}

@end