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

#import "BFFTableLinkedItemCell.h"

// UI
#import "BFFNavigator.h"
#import "BFFTableLinkedItem.h"

// UINavigator
#import "BFFURLMap.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFDefaultStyleSheet.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFTableLinkedItemCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_item);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)object {
  return _item;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [_item release];
    _item = [object retain];

    BFFTableLinkedItem* item = object;

    if (item.URL) {
      BFFNavigationMode navigationMode = [[BFFNavigator navigator].URLMap
                                         navigationModeForURL:item.URL];
      if (item.accessoryURL) {
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

      } else if (navigationMode == BFFNavigationModeCreate ||
                 navigationMode == BFFNavigationModeShare) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

      } else {
        self.accessoryType = UITableViewCellAccessoryNone;
      }

      self.selectionStyle = BFFSTYLEVAR(tableSelectionStyle);

    } else {
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
  }
}


@end
