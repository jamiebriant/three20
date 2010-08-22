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

#import "Six40/TTTabBar.h"

// UI
#import "Six40/TTTab.h"
#import "Six40/TTTabDelegate.h"

// UI (private)
#import "Six40/TTTabBarInternal.h"

// Style
#import "Six40/TTGlobalStyle.h"
#import "Six40/TTStyleSheet.h"

// Core
#import "Six40/TTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTTabBar

@synthesize tabItems = _tabItems;
@synthesize tabViews = _tabViews;
@synthesize tabStyle = _tabStyle;

@synthesize selectedTabIndex = _selectedTabIndex;

@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame  {
  if (self = [super initWithFrame:frame]) {
    _selectedTabIndex = NSIntegerMax;
    _tabViews = [[NSMutableArray alloc] init];

    self.style = TTSTYLE(tabBar);
    self.tabStyle = @"tab:";
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_tabStyle);
  TT_RELEASE_SAFELY(_tabItems);
  TT_RELEASE_SAFELY(_tabViews);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addTab:(TTTab*)tab {
  [self addSubview:tab];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tabTouchedUp:(TTTab*)tab {
  self.selectedTabView = tab;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  [self layoutTabs];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTTabItem*)selectedTabItem {
  if (_selectedTabIndex != NSIntegerMax) {
    return [_tabItems objectAtIndex:_selectedTabIndex];
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedTabItem:(TTTabItem*)tabItem {
  self.selectedTabIndex = [_tabItems indexOfObject:tabItem];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (TTTab*)selectedTabView {
  if (_selectedTabIndex != NSIntegerMax && _selectedTabIndex < _tabViews.count) {
    return [_tabViews objectAtIndex:_selectedTabIndex];
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedTabView:(TTTab*)tab {
  self.selectedTabIndex = [_tabViews indexOfObject:tab];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelectedTabIndex:(NSInteger)selectedTabIndex {
  if (selectedTabIndex != _selectedTabIndex) {
    if (_selectedTabIndex != NSIntegerMax) {
      self.selectedTabView.selected = NO;
    }

    _selectedTabIndex = selectedTabIndex;

    if (_selectedTabIndex != NSIntegerMax) {
      self.selectedTabView.selected = YES;
    }

    if ([_delegate respondsToSelector:@selector(tabBar:tabSelected:)]) {
      [_delegate tabBar:self tabSelected:_selectedTabIndex];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTabItems:(NSArray*)tabItems {
  [_tabItems release];
  _tabItems =  [tabItems retain];

  for (int i = 0; i < _tabViews.count; ++i) {
    TTTab* tab = [_tabViews objectAtIndex:i];
    [tab removeFromSuperview];
  }

  [_tabViews removeAllObjects];

  if (_selectedTabIndex >= _tabViews.count) {
    _selectedTabIndex = 0;
  }

  for (int i = 0; i < _tabItems.count; ++i) {
    TTTabItem* tabItem = [_tabItems objectAtIndex:i];
    TTTab* tab = [[[TTTab alloc] initWithItem:tabItem tabBar:self] autorelease];
    [tab setStylesWithSelector:self.tabStyle];
    [tab addTarget:self action:@selector(tabTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    [self addTab:tab];
    [_tabViews addObject:tab];
    if (i == _selectedTabIndex) {
      tab.selected = YES;
    }
  }

  [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showTabAtIndex:(NSInteger)tabIndex {
  TTTab* tab = [_tabViews objectAtIndex:tabIndex];
  tab.hidden = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideTabAtIndex:(NSInteger)tabIndex {
  TTTab* tab = [_tabViews objectAtIndex:tabIndex];
  tab.hidden = YES;
}


@end