//
//  AllItemsViewController.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014年 Daisuke Hirata. All rights reserved.
//

#import "AllItemsViewController.h"

@interface AllItemsViewController ()

@end

@implementation AllItemsViewController


#pragma mark - Table view data source delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConversionMeasure Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
    /*
    ConversionMeasure *measure = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = measure.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d units", [measure.units count]];
    cell.imageView.image = [UIImage createPlaceHolderImageWithDiagonalText:measure.name
                                                                    inRect:CGRectMake(0, 0, 60, 60)
                                                                 withColor:[ConversionClass colors][measure.whichClass.name]];
    */
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

// hide section index
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}



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
