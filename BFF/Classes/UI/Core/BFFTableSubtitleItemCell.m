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

#import "BFFTableSubtitleItemCell.h"

// UI
#import "BFFImageView.h"
#import "BFFTableSubtitleItem.h"
#import "BFFUIViewAdditions.h"
#import "BFFUIFontAdditions.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFDefaultStyleSheet.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFTableSubtitleItemCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier]) {
    self.textLabel.font = BFFSTYLEVAR(tableFont);
    self.textLabel.textColor = BFFSTYLEVAR(textColor);
    self.textLabel.highlightedTextColor = BFFSTYLEVAR(highlightedTextColor);
    self.textLabel.textAlignment = UITextAlignmentLeft;
    self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
    self.textLabel.adjustsFontSizeToFitWidth = YES;

    self.detailTextLabel.font = BFFSTYLEVAR(font);
    self.detailTextLabel.textColor = BFFSTYLEVAR(tableSubTextColor);
    self.detailTextLabel.highlightedTextColor = BFFSTYLEVAR(highlightedTextColor);
    self.detailTextLabel.textAlignment = UITextAlignmentLeft;
    self.detailTextLabel.contentMode = UIViewContentModeTop;
    self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    self.detailTextLabel.numberOfLines = kTableMessageTextLineCount;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_imageView2);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTableViewCell class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  BFFTableSubtitleItem* item = object;

  CGFloat height = BFFSTYLEVAR(tableFont).ttLineHeight + kTableCellVPadding*2;
  if (item.subtitle) {
    height += BFFSTYLEVAR(font).ttLineHeight;
  }

  return height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat height = self.contentView.height;
  CGFloat width = self.contentView.width - (height + kTableCellSmallMargin);
  CGFloat left = 0;

  if (_imageView2) {
    _imageView2.frame = CGRectMake(0, 0, height, height);
    left = _imageView2.right + kTableCellSmallMargin;
  } else {
    left = kTableCellHPadding;
  }

  if (self.detailTextLabel.text.length) {
    CGFloat textHeight = self.textLabel.font.ttLineHeight;
    CGFloat subtitleHeight = self.detailTextLabel.font.ttLineHeight;
    CGFloat paddingY = floor((height - (textHeight + subtitleHeight))/2);

    self.textLabel.frame = CGRectMake(left, paddingY, width, textHeight);
    self.detailTextLabel.frame = CGRectMake(left, self.textLabel.bottom, width, subtitleHeight);

  } else {
    self.textLabel.frame = CGRectMake(_imageView2.right + kTableCellSmallMargin, 0, width, height);
    self.detailTextLabel.frame = CGRectZero;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
  if (_item != object) {
    [super setObject:object];

    BFFTableSubtitleItem* item = object;
    if (item.text.length) {
      self.textLabel.text = item.text;
    }
    if (item.subtitle.length) {
      self.detailTextLabel.text = item.subtitle;
    }
    if (item.defaultImage) {
      self.imageView2.defaultImage = item.defaultImage;
    }
    if (item.imageURL) {
      self.imageView2.urlPath = item.imageURL;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UILabel*)subtitleLabel {
  return self.detailTextLabel;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFImageView*)imageView2 {
  if (!_imageView2) {
    _imageView2 = [[BFFImageView alloc] init];
    //    _imageView2.defaultImage = BFFSTYLEVAR(personImageSmall);
    //    _imageView2.style = BFFSTYLE(threadActorIcon);
    [self.contentView addSubview:_imageView2];
  }
  return _imageView2;
}


@end
