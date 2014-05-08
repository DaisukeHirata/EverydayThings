//
//  Item+Helper.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "AppDelegate.h"
#import "Item+Helper.h"
#import "ItemCategory+Helper.h"
#import "GeoFenceMonitoringLocationReloadNotification.h"
#import "UpdateApplicationBadgeNumberNotification.h"
#import "UpdateBuyNowTabBadgeNumberNotification.h"

@implementation Item (Helper)


+ (Item *)saveItem:(NSDictionary *)values
{
    Item *item = nil;
    NSManagedObjectContext *context = [AppDelegate sharedContext];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"itemId = %@", values[@"itemId"]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // error
        item = nil; // not necessary. it's for readability
    } else if  ([matches count]) {
        // update
        item = [matches firstObject];
    } else {
        // insert
        item = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                             inManagedObjectContext:context];
        item.itemId = [[NSUUID UUID] UUIDString];
    }
    
    if (item) {
        item.name                = values[@"name"];
        item.buyNow              = values[@"buyNow"];
        item.stock               = values[@"stock"];
        item.lastPurchaseDate    = values[@"lastPurchaseDate"];
        item.expireDate          = values[@"expireDate"];
        item.whereToBuy          = values[@"whereToBuy"];
        item.favoriteProductName = values[@"favoriteProductName"];
        item.whereToStock        = values[@"whereToStock"];
        item.cycle               = [values[@"cycle"] length] != 0 ?
                                        [NSDecimalNumber decimalNumberWithString:values[@"cycle"]] : nil;
        item.timeSpan            = [Item timeSpans][[values[@"timeSpan"] intValue]];
        item.whichItemCategory   = [ItemCategory itemCategoryWithIndex:[values[@"category"] intValue]];
        item.elapsed             = [item elapsedDaysAfterLastPurchaseDate] > [item cycleInDays] ? @1 : @0;

        item.location            = values[@"location"];
        item.geofence            = values[@"geofence"];
        item.latitude            = values[@"latitude"];
        item.longitude           = values[@"longitude"];
        
        NSError *error = nil;
        [context save:&error];
        if(error) {
            NSLog(@"could not save data : %@", error);
        } else {
            // geofence region changed.
            [[NSNotificationCenter defaultCenter] postNotificationName:GeofenceMonitoringLocationReloadNotification
                                                                object:self
                                                              userInfo:nil];
            
            // update application badge number.
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateApplicationBadgeNumberNotification
                                                                object:self
                                                              userInfo:nil];
            
            // update buy now tab badge number.
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateBuyNowTabBadgeNumberNotification
                                                                object:self
                                                              userInfo:nil];

        }
    }
    
    return item;
}

+ (NSFetchRequest *)createRequestForBuyNowItems
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"buyNow = YES || elapsed = YES"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"whichItemCategory.name"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    return request;
        
}

+ (NSArray *)itemsForBuyNow
{
    NSFetchRequest *request = [self createRequestForBuyNowItems];
    
    NSError *error;
    NSArray *matches = [[AppDelegate sharedContext] executeFetchRequest:request error:&error];
    
    if (error) {
        // error
        NSLog(@"can not read geofence location data from item managed object");
    }
    
    return matches;
}

+ (NSArray *)itemsForGeofence
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"(buyNow = YES || elapsed = YES) && geofence = YES"];
    NSError *error;
    NSArray *matches = [[AppDelegate sharedContext] executeFetchRequest:request error:&error];
    
    if (!matches || error) {
        // error
        NSLog(@"can not read geofence location data from item managed object");
    }
    
    return matches;
}

- (NSInteger)expiredWeeks
{
	// now - expire date
	NSTimeInterval since = 0;
    
    if (self.expireDate) {
        since = [[NSDate date] timeIntervalSinceDate:self.expireDate];
    }
    
    // convert second into week
    return (NSInteger)since/(7*24*60*60);
}

- (NSInteger)elapsedDaysAfterLastPurchaseDate
{
	// now - last purchase date
	NSTimeInterval since = 0;
    
    if (self.lastPurchaseDate) {
        since = [[NSDate date] timeIntervalSinceDate:self.lastPurchaseDate];
    }
    
    // convert second into day
    return (NSInteger)since/(24*60*60);
}

- (NSInteger)cycleInDays
{
    NSInteger cycle = 0;
    
    if (![self.cycle isEqualToNumber:[NSDecimalNumber notANumber]]) {
        cycle = [self.cycle longValue];
        if ([self.timeSpan isEqualToString:@"Month"]) {
            cycle = [self.cycle longValue] * 30;
        } else if ([self.timeSpan isEqualToString:@"Year"]) {
            cycle = [self.cycle longValue] * 365;
        }
    }
    
    return cycle;
}

+ (NSArray *)timeSpans
{
    return @[@"Day", @"Month", @"Year"];
}

@end
