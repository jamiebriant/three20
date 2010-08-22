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

#import "Six40/TTStyledTextTableItemCell.h"

// UI
#import "Six40/TTStyledTextLabel.h"
#import "Six40/TTTableStyledTextItem.h"
#import "Six40/UITableViewAdditions.h"
#import "Six40/UIViewAdditions.h"

// Style
#import "Six40/TTGlobalStyle.h"
#import "Six40/TTDefaultStyleSheet.h"
#import "Six40/TTStyledText.h"

// Core
#import "Six40/TTCorePreprocessorMacros.h"

static const CGFloat kDisclosureIndicatorWidth = 23;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTStyledTextTableItemCell

@synthesize label = _label;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _label = [[TTStyledTextLabel alloc] init];
    _label.contentMode = UIViewContentModeLeft;
    [self.contentView addSubview:_label];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  TT_RELEASE_SAFELY(_label);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  TTTableStyledTextItem* item = object;
  if (!item.text.font) {
    item.text.font = TTSTYLEVAR(font);
  }

  CGFloat padding = [tableView tableCellMargin]*2 + item.padding.left + item.padding.right;
  if (item.URL) {
    padding += kDisclosureIndicatorWidth;
  }

  item.text.width = tableView.width - padding;

  return item.text.height + item.padding.top + item.padding.bottom;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  TTTableStyledTextItem* item = self.object;
  _label.frame = CGRectOffset(self.contentView.bounds, item.margin.left, item.margin.top);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
  [super didMoveToSuperview];
  if (self.superview) {
    _label.backgroundColor = self.backgroundColor;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    TTTableStyledTextItem* item = object;
    _label.text = item.text;
    _label.contentInset = item.padding;
    [self setNeedsLayout];
  }
}


@end
