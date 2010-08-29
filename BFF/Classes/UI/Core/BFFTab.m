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

#import "BFFTab.h"

// UI
#import "BFFTabItem.h"
#import "BFFLabel.h"
#import "BFFUIViewAdditions.h"

// UI (private)
#import "BFFTabBarInternal.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFStyleSheet.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFTab

@synthesize tabItem = _tabItem;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithItem:(BFFTabItem*)tabItem tabBar:(BFFTabBar*)tabBar {
  if (self = [self init]) {
    self.tabItem = tabItem;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_tabItem);
  BFF_RELEASE_SAFELY(_badge);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateBadgeNumber {
  if (_tabItem.badgeNumber) {
    if (!_badge) {
      _badge = [[BFFLabel alloc] init];
      _badge.style = BFFSTYLE(badge);
      _badge.backgroundColor = [UIColor clearColor];
      _badge.userInteractionEnabled = NO;
      [self addSubview:_badge];
    }
    if (_tabItem.badgeNumber <= kMaxBadgeNumber) {
      _badge.text = [NSString stringWithFormat:@"%d", _tabItem.badgeNumber];
    } else {
      _badge.text = [NSString stringWithFormat:@"%d+", kMaxBadgeNumber];
    }
    [_badge sizeToFit];

    _badge.frame = CGRectMake(self.width - _badge.width-1, 1, _badge.width, _badge.height);
    _badge.hidden = NO;
  } else {
    _badge.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTabItemDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tabItem:(BFFTabItem*)item badgeNumberChangedTo:(int)value {
  [self updateBadgeNumber];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTabItem:(BFFTabItem*)tabItem {
  if (tabItem != _tabItem) {
    [_tabItem performSelector:@selector(setTabBar:) withObject:nil];
    [_tabItem release];
    _tabItem = [tabItem retain];
    [_tabItem performSelector:@selector(setTabBar:) withObject:self];

    [self setTitle:_tabItem.title forState:UIControlStateNormal];
    [self setImage:_tabItem.icon forState:UIControlStateNormal];

    if (_tabItem.badgeNumber) {
      [self updateBadgeNumber];
    }
  }
}


@end
