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

#import "BFFTableTextItemCell.h"

// UI
#import "BFFUIViewAdditions.h"
#import "BFFUITableViewAdditions.h"

// - Table items
#import "BFFTableTextItem.h"
#import "BFFTableLongTextItem.h"
#import "BFFTableGrayTextItem.h"
#import "BFFTableButton.h"
#import "BFFTableLink.h"
#import "BFFTableSummaryItem.h"

// Style
#import "BFFDefaultStyleSheet.h"
#import "BFFGlobalStyle.h"

static const CGFloat kMaxLabelHeight = 2000;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFTableTextItemCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    self.textLabel.highlightedTextColor = BFFSTYLEVAR(highlightedTextColor);
    self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.textLabel.numberOfLines = 0;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class private


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIFont*)textFontForItem:(BFFTableTextItem*)item {
  if ([item isKindOfClass:[BFFTableLongTextItem class]]) {
    return BFFSTYLEVAR(font);
  } else if ([item isKindOfClass:[BFFTableGrayTextItem class]]) {
    return BFFSTYLEVAR(font);
  } else {
    return BFFSTYLEVAR(tableFont);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  BFFTableTextItem* item = object;

  CGFloat width = tableView.width - (kTableCellHPadding*2 + [tableView tableCellMargin]*2);
  UIFont* font = [self textFontForItem:item];
  CGSize size = [item.text sizeWithFont:font
                      constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                          lineBreakMode:UILineBreakModeTailTruncation];
  if (size.height > kMaxLabelHeight) {
    size.height = kMaxLabelHeight;
  }

  return size.height + kTableCellVPadding*2;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  self.textLabel.frame = CGRectInset(self.contentView.bounds,
                                     kTableCellHPadding, kTableCellVPadding);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    BFFTableTextItem* item = object;
    self.textLabel.text = item.text;

    if ([object isKindOfClass:[BFFTableButton class]]) {
      self.textLabel.font = BFFSTYLEVAR(tableButtonFont);
      self.textLabel.textColor = BFFSTYLEVAR(linkTextColor);
      self.textLabel.textAlignment = UITextAlignmentCenter;
      self.accessoryType = UITableViewCellAccessoryNone;
      self.selectionStyle = BFFSTYLEVAR(tableSelectionStyle);

    } else if ([object isKindOfClass:[BFFTableLink class]]) {
      self.textLabel.font = BFFSTYLEVAR(tableFont);
      self.textLabel.textColor = BFFSTYLEVAR(linkTextColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;

    } else if ([object isKindOfClass:[BFFTableSummaryItem class]]) {
      self.textLabel.font = BFFSTYLEVAR(tableSummaryFont);
      self.textLabel.textColor = BFFSTYLEVAR(tableSubTextColor);
      self.textLabel.textAlignment = UITextAlignmentCenter;

    } else if ([object isKindOfClass:[BFFTableLongTextItem class]]) {
      self.textLabel.font = BFFSTYLEVAR(font);
      self.textLabel.textColor = BFFSTYLEVAR(textColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;

    } else if ([object isKindOfClass:[BFFTableGrayTextItem class]]) {
      self.textLabel.font = BFFSTYLEVAR(font);
      self.textLabel.textColor = BFFSTYLEVAR(tableSubTextColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;

    } else {
      self.textLabel.font = BFFSTYLEVAR(tableFont);
      self.textLabel.textColor = BFFSTYLEVAR(textColor);
      self.textLabel.textAlignment = UITextAlignmentLeft;
    }
  }
}


@end
