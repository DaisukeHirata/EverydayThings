//
//  AmazonSearchResultTableViewController.m
//  AmazonProductAdvertisingAPI
//
//  Created by Daisuke Hirata on 2014/05/01.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "AmazonSearchResultTableViewController.h"
#import "ItemDialogViewController.h"
#import "XMLReader.h"
#import "AmazonProductAdvertisingAPI.h"
#import "AFHTTPRequestOperationManager.h"
#import "AmazonItem.h"
#import "UIImageView+WebCache.h"

@interface AmazonSearchResultTableViewController ()
@property (nonatomic, strong) NSArray *amazonItems; // array of AmazonItem
@end

@implementation AmazonSearchResultTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"%@", self.janCode);
    
    [self sendRequest];
}

- (void)sendRequest
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    manager.responseSerializer = responseSerializer;

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [manager GET:[AmazonProductAdvertisingAPI requestURL:self.janCode]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             NSError *xmlerror = nil;
             NSDictionary *xmlResponse = [XMLReader dictionaryForXMLData:responseObject
                                                                   error:&xmlerror];
             if (!xmlerror) {
                 [AmazonProductAdvertisingAPI logXmlResponse:xmlResponse];
                 self.amazonItems = [AmazonProductAdvertisingAPI loadAmazonItems:xmlResponse];
                 if ([self.amazonItems count]) {
                     [self.tableView reloadData];
                 } else {
                     [self alert:@"A searched item was not found."];
                 }
             } else {
                 NSLog(@"XML Error:%@", xmlerror);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             NSLog(@"Error: %@", error);
             if (operation.response.statusCode == 503) {
                 [self fatalAlert:@"Sorry, Bar code searching service is busy. Please try it a few seconds later."];
             }
         }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.amazonItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Amazon Item Cell" forIndexPath:indexPath];
 
    AmazonItem *item = [self.amazonItems objectAtIndex:indexPath.row];
    
    // adjust font size by text length
    cell.textLabel.minimumScaleFactor = 0.5f;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.price;
    
    // prevend auto scaling. maintain the aspect ratio.
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.imageView setImageWithURL:[NSURL URLWithString:item.thumbnailURL]
                   placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AmazonItem *item = [self.amazonItems objectAtIndex:indexPath.row];
    UIViewController *rewindController = [self.navigationController.viewControllers objectAtIndex:1];
    if ([rewindController isKindOfClass:[ItemDialogViewController class]]) {
        ItemDialogViewController *itemDialogViewController = (ItemDialogViewController *)rewindController;
        itemDialogViewController.amazonItem = item;
        [self.navigationController popToViewController:itemDialogViewController animated:YES];
    }
}

#pragma mark - Alerts

- (void)alert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Amazon Search"
                                message:message
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)fatalAlert:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Amazon Search"
                                message:message
                               delegate:self    // we're going to cancel when dismissed
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}


@end
