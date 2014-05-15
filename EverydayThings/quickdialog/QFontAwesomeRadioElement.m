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

#import "QBindingEvaluator.h"
#import "QFontAwesomeRadioElement.h"
#import "QuickDialog.h"

@implementation QFontAwesomeRadioElement {
    QSection *_internalRadioItemsSection;
}

- (void)createElements {
    _sections = nil;
    self.presentationMode = QPresentationModeNavigationInPopover;
    _internalRadioItemsSection = [[QSection alloc] init];
    _parentSection = _internalRadioItemsSection;
    
    [self addSection:_parentSection];
    
    for (NSUInteger i=0; i< [_items count]; i++){
        QFontAwesomeRadioItemElement *element = [[QFontAwesomeRadioItemElement alloc] initWithIndex:i RadioElement:self];
        element.imageNamed = [self.itemsImageNames objectAtIndex:i];
        element.title = [self.items objectAtIndex:i];
        [_parentSection addElement:element];
    }
}


@end
