//
//  SettingFormViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/24.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "SettingFormViewController.h"
#import "SettingForm.h"
#import "SearchAddressViewController.h"

@interface SettingFormViewController ()

@end

@implementation SettingFormViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        QRootElement *_root = [[QRootElement alloc] init];
        _root.grouped = YES;
        _root.title = @"Setting";
        self.root = _root;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    QSection *section = [[QSection alloc] initWithTitle:@"Something"];
    QLabelElement *label = [[QLabelElement alloc] initWithTitle:@"Hello" Value:@"world!"];
    QButtonElement *button = [[QButtonElement alloc] initWithTitle:@"Location"];
    button.onSelected =  ^{
        NSLog(@"pushed");
        SearchAddressViewController *searchAddressViewController =
        [[self storyboard] instantiateViewControllerWithIdentifier:@"SearchAddressViewController"];
        [self.navigationController pushViewController:searchAddressViewController animated:YES];
	};

    [self.root addSection:section];
    [section addElement:label];
    [section addElement:button];
}

- (void)searchMap:(UITableViewCell<FXFormFieldCell> *)cell
{
    SearchAddressViewController *searchAddressViewController =
        [[self storyboard] instantiateViewControllerWithIdentifier:@"SearchAddressViewController"];
    [self.navigationController pushViewController:searchAddressViewController animated:YES];
}


@end
