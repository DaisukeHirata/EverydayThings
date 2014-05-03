//
//  AmazonSearchResultTableViewController.m
//  AmazonProductAdvertisingAPI
//
//  Created by Daisuke Hirata on 2014/05/01.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "AmazonSearchResultTableViewController.h"
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
    
    [manager GET:[AmazonProductAdvertisingAPI requestURL:self.janCode]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSError *xmlerror = nil;
             NSDictionary *xmlResponse = [XMLReader dictionaryForXMLData:responseObject
                                                                     error:&xmlerror];
             if (!xmlerror) {
                 [AmazonProductAdvertisingAPI logXmlResponse:xmlResponse];
                 self.amazonItems = [AmazonProductAdvertisingAPI loadAmazonItems:xmlResponse];
                 [self.tableView reloadData];
             } else {
                 NSLog(@"XML Error:%@", xmlerror);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
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
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.f];
    cell.textLabel.minimumScaleFactor = 8.f/15.f;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.text = item.title;
    
    cell.detailTextLabel.text = item.price;
    
    // prevend auto scaling. maintain the aspect ratio.
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cell.imageView setImageWithURL:[NSURL URLWithString:item.thumbnailURL]
                   placeholderImage:[UIImage imageNamed:@"placeholder"]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
