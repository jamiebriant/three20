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

#import "BFFTabStrip.h"

// UI
#import "BFFTab.h"
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
@implementation BFFTabStrip


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame  {
  if (self = [super initWithFrame:frame]) {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.scrollEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];

    self.style = BFFSTYLE(tabStrip);
    self.tabStyle = @"tabRound:";
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_overflowLeft);
  BFF_RELEASE_SAFELY(_overflowRight);
  BFF_RELEASE_SAFELY(_scrollView);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addTab:(BFFTab*)tab {
  [_scrollView addSubview:tab];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateOverflow {
  if (_scrollView.contentOffset.x < (_scrollView.contentSize.width-self.width)) {
    if (!_overflowRight) {
      _overflowRight = [[BFFView alloc] init];
      _overflowRight.style = BFFSTYLE(tabOverflowRight);
      _overflowRight.userInteractionEnabled = NO;
      _overflowRight.backgroundColor = [UIColor clearColor];
      [_overflowRight sizeToFit];
      [self addSubview:_overflowRight];
    }

    _overflowRight.left = self.width-_overflowRight.width;
    _overflowRight.hidden = NO;
  } else {
    _overflowRight.hidden = YES;
  }
  if (_scrollView.contentOffset.x > 0) {
    if (!_overflowLeft) {
      _overflowLeft = [[BFFView alloc] init];
      _overflowLeft.style = BFFSTYLE(tabOverflowLeft);
      _overflowLeft.userInteractionEnabled = NO;
      _overflowLeft.backgroundColor = [UIColor clearColor];
      [_overflowLeft sizeToFit];
      [self addSubview:_overflowLeft];
    }

    _overflowLeft.hidden = NO;
  } else {
    _overflowLeft.hidden = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)layoutTabs {
  CGSize size = [super layoutTabs];

  CGPoint contentOffset = _scrollView.contentOffset;
  _scrollView.frame = self.bounds;
  _scrollView.contentSize = CGSizeMake(size.width + kTabMargin, self.height);
  _scrollView.contentOffset = contentOffset;

  return size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  [self updateOverflow];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTabBar


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTabItems:(NSArray*)tabItems {
  [super setTabItems:tabItems];
  [self updateOverflow];
}


@end

