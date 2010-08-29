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

// UI
#import "BFFButton.h"

@class BFFLauncherItem;
@class BFFLabel;

@interface BFFLauncherButton : BFFButton {
  BFFLauncherItem* _item;
  BFFLabel*        _badge;
  BFFButton*       _closeButton;

  BOOL _dragging;
  BOOL _editing;
}

@property (nonatomic, readonly) BFFLauncherItem* item;
@property (nonatomic, readonly) BFFButton*       closeButton;
@property (nonatomic)           BOOL            dragging;
@property (nonatomic)           BOOL            editing;

- (id)initWithItem:(BFFLauncherItem*)item;

@end
