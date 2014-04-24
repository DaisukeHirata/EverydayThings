//
//  SettingFormViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/24.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "SettingFormViewController.h"
#import "SettingForm.h"

@interface SettingFormViewController ()

@end

@implementation SettingFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.formController.form = [[SettingForm alloc] init];
    // necessary to show form
    [self.tableView reloadData];
}

@end
