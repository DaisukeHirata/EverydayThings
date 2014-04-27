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

#import "QButtonWithLabelElement.h"

@implementation QButtonWithLabelElement

- (QButtonWithLabelElement *)init {
    self = [super init];
    if (self) {
        self.enabled = YES;
    }
    return self;
}

- (QButtonWithLabelElement *)initWithTitle:(NSString *)title {
    self = [super initWithTitle:title Value:nil];
    if (self) {
        self.enabled = YES;
    }
    return self;
}

- (QButtonWithLabelElement *)initWithTitle:(NSString *)title withValue:(NSString *)value
{
    self = [super initWithTitle:title Value:nil];
    if (self) {
        self.enabled = YES;
        self.value = value;
    }
    return self;
}

- (void)fetchValueIntoObject:(id)obj {
	if (_key==nil)
		return;
	
	[obj setValue:_value forKey:_key];
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuickformButtonWithLabelElement"];
    if (cell == nil){
        cell= [[QTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"QuickformButtonWithLabelElement"];
    }
    [cell applyAppearanceForElement:self];
    cell.textLabel.text = _title;
    cell.textLabel.textAlignment = self.appearance.buttonAlignment;
    cell.textLabel.font = self.appearance.labelFont;
    cell.textLabel.textColor = self.enabled ? self.appearance.actionColorEnabled : self.appearance.actionColorDisabled;
    cell.detailTextLabel.text = self.value;
    return cell;
}

- (void)selected:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller indexPath:(NSIndexPath *)indexPath {
    if (self.enabled) {
        [super selected:tableView controller:controller indexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
