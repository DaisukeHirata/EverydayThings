//
//  ItemForm.m
//  EverydayThings
//
//  Created by Daisuke Hirata on 2014/04/22.
//  Copyright (c) 2014 Daisuke Hirata. All rights reserved.
//

#import "ItemForm.h"
#import "ISO3166CountryValueTransformer.h"
#import "ItemCategory+Helper.h"

@implementation ItemForm

//because we want to rearrange how this form
//is displayed, we've implemented the fields array
//which lets us dictate exactly which fields appear
//and in what order they appear

- (NSArray *)fields
{
    return @[
             
             // we want to add a group header for the field set of fields
             // we do that by adding the header key to the first field in the group
             // , and modify the auto-capitalization
             @{FXFormFieldKey: @"name", FXFormFieldHeader: @"ITEM",
               @"textField.autocapitalizationType": @(UITextAutocapitalizationTypeWords)},

             //this is a multiple choice field, so we'll need to provide some options
             //because this is an enum property, the indexes of the options should match enum values
             @{FXFormFieldKey: @"category",
               FXFormFieldPlaceholder: @"None",
               FXFormFieldOptions: [ItemCategory categories]},

             // switch
             @{FXFormFieldKey: @"buyNow",
               FXFormFieldCell: [FXFormSwitchCell class]},

             // switch
             @{FXFormFieldKey: @"stock",
               FXFormFieldCell: [FXFormSwitchCell class]},

             @"expireDate",
             
             //this field doesn't correspond to any property of the form
             //it's just an action button. the action will be called on first
             //object in the responder chain that implements the submitForm
             //method, which in this case would be the AppDelegate
             @{FXFormFieldTitle: @"Purchased this !!", FXFormFieldHeader: @"Purchase", FXFormFieldAction: @"purchase:"},
             @"lastPurchaseDate",

             
             //
             // Cycle to resupply
             //
             @{FXFormFieldKey: @"cycle",
               FXFormFieldType: FXFormFieldTypeNumber,
               FXFormFieldHeader: @"Cycle to resupply"},
             @{FXFormFieldKey: @"timeSpan",
               FXFormFieldPlaceholder: @"Day",
               FXFormFieldOptions: @[@"Month", @"Year"]},

             
             @{FXFormFieldTitle: @"whereToBuy", FXFormFieldHeader: @"Detail"},
             @"favoriteProductName",
             @"whereToStock",
             
             ];
}


@end
