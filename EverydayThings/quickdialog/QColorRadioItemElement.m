//                                
// Copyright 2011 ESCOZ Inc  - http://escoz.com
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "QuickDialogTableView.h"
#import "QSection.h"
#import "QRootElement.h"
#import "QColorRadioItemElement.h"
#import "ItemCategory+Helper.h"

@implementation QColorRadioItemElement

- (QColorRadioItemElement *)initWithIndex:(NSUInteger)index RadioElement:(QRadioElement *)radioElement {
    self = [super init];
    _radioElement = radioElement;
    _index = index;
    return self;
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    UITableViewCell *cell = [super getCellForTableView:tableView controller:controller];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    NSInteger selectedIndex = _radioElement==nil? _radioSection.selected : _radioElement.selected;
    cell.accessoryType = selectedIndex == _index ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.textAlignment = NSTextAlignmentLeft; // hardcoded so that appearance doesn't change it
    cell.textLabel.textColor = self.enabled ? self.appearance.valueColorEnabled : self.appearance.valueColorDisabled;
    cell.imageView.image = self.image;
    return cell;
}

- (void)selected:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller indexPath:(NSIndexPath *)indexPath {
    [super selected:tableView controller:controller indexPath:indexPath];
    
    NSInteger selectedIndex = _radioElement==nil? _radioSection.selected : _radioElement.selected;
    
    if (_index != selectedIndex) {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:indexPath.section]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        [oldCell setNeedsDisplay];
        
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (_radioElement!= nil)
    {
        _radioElement.selected = _index;
        [_radioElement fieldDidEndEditing];
        tableView.userInteractionEnabled = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:0.3
                                         target:controller
                                       selector:@selector(popToPreviousRootElement)
                                       userInfo:nil
                                        repeats:NO];
        
    }
    else if (_radioSection!=nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        _radioSection.selected = _index;
        if (_radioSection.onSelected) {
            _radioSection.onSelected();
        }
    }
}

// override
-(void)setImageNamed:(NSString *)name {
    if(name != nil) {
        self.image = [self imageWithColor:[self hexToUIColor:[ItemCategory colorChoices][name] alpha:1.0]];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a
{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
