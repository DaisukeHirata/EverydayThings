//
//  AppDelegate+MOC.h
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface AppDelegate (MOC)

+ (void)saveContext:(NSManagedObjectContext *)managedObjectContext;

// Create managed object context attaches to a calculator database
+ (NSManagedObjectContext *)createMainQueueManagedObjectContext;

@end
