//
//  AppDelegate.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+MOC.h"

@interface AppDelegate()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

static NSManagedObjectContext *_sharedContext = nil;

+ (NSManagedObjectContext *)sharedContext
{
    if (!_sharedContext) {
        _sharedContext = [AppDelegate createMainQueueManagedObjectContext];
    }
    return _sharedContext;
}

@end
