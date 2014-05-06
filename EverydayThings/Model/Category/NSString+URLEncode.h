#import <Foundation/Foundation.h>

@interface NSString (URLEncode)
    -(NSString *)urlEncode;
    -(NSString *)minimalUrlEncode;
@end