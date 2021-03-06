//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "BFFMessageRecipientField.h"

// UI
#import "BFFPickerTextField.h"
#import "BFFMessageController.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFMessageRecipientField

@synthesize recipients = _recipients;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_recipients);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)description {
  return [NSString stringWithFormat:@"%@ %@", _title, _recipients];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFMessageField


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFPickerTextField*)createViewForController:(BFFMessageController*)controller {
  BFFPickerTextField* textField = [[[BFFPickerTextField alloc] init] autorelease];
  textField.dataSource = controller.dataSource;
  textField.autocorrectionType = UITextAutocorrectionTypeNo;
  textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
  textField.rightViewMode = UITextFieldViewModeAlways;

  if (controller.showsRecipientPicker) {
    UIButton* addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addButton addTarget:controller action:@selector(showRecipientPicker)
        forControlEvents:UIControlEventTouchUpInside];
    textField.rightView = addButton;
  }

  return textField;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)persistField:(UITextField*)textField {
  if ([textField isKindOfClass:[BFFPickerTextField class]]) {
    BFFPickerTextField* picker = (BFFPickerTextField*)textField;
    NSMutableArray* cellsData = [NSMutableArray array];
    for (id cell in picker.cells) {
      if ([cell conformsToProtocol:@protocol(NSCoding)]) {
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:cell];
        [cellsData addObject:data];
      }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:cellsData, @"cells",
            textField.text, @"text", nil];

  } else {
    return [NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"text", nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreField:(UITextField*)textField withData:(id)data {
  NSDictionary* dict = data;

  if ([textField isKindOfClass:[BFFPickerTextField class]]) {
    BFFPickerTextField* picker = (BFFPickerTextField*)textField;
    NSArray* cellsData = [dict objectForKey:@"cells"];
    [picker removeAllCells];
    for (id cellData in cellsData) {
      id cell = [NSKeyedUnarchiver unarchiveObjectWithData:cellData];
      [picker addCellWithObject:cell];
    }
  }

  textField.text = [dict objectForKey:@"text"];
}


@end
