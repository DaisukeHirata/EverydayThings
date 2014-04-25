//
//  SettingForm.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/24.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "SettingForm.h"

@implementation SettingForm

- (NSArray *)fields
{
    return @[
             
             // switch
             @{FXFormFieldKey: @"useBadge", FXFormFieldCell: [FXFormSwitchCell class]},
             @{FXFormFieldKey: @"useGeoFence", FXFormFieldCell: [FXFormSwitchCell class]},
             
             @{FXFormFieldTitle: @"test map !!", FXFormFieldHeader: @"GeoFence", FXFormFieldAction: @"searchMap:"},
             
             ];
}

@end
