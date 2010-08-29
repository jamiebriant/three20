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

#import "BFFTableImageItemCell.h"

// UI
#import "BFFImageView.h"
#import "BFFTableImageItem.h"
#import "BFFTableRightImageItem.h"
#import "BFFUIViewAdditions.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFDefaultStyleSheet.h"
#import "BFFImageStyle.h"

// Network
#import "BFFURLCache.h"

// Core
#import "BFFCorePreprocessorMacros.h"

static const CGFloat kKeySpacing = 12;
static const CGFloat kDefaultImageSize = 50;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFTableImageItemCell

@synthesize imageView2 = _imageView2;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
  if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
    _imageView2 = [[BFFImageView alloc] init];
    [self.contentView addSubview:_imageView2];
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
  BFFTableImageItem* imageItem = object;

  UIImage* image = imageItem.imageURL
  ? [[BFFURLCache sharedCache] imageForURL:imageItem.imageURL] : nil;
  if (!image) {
    image = imageItem.defaultImage;
  }

  CGFloat imageHeight, imageWidth;
  BFFImageStyle* style = [imageItem.imageStyle firstStyleOfClass:[BFFImageStyle class]];
  if (style && !CGSizeEqualToSize(style.size, CGSizeZero)) {
    imageWidth = style.size.width + kKeySpacing;
    imageHeight = style.size.height;
  } else {
    imageWidth = image
    ? image.size.width + kKeySpacing
    : (imageItem.imageURL ? kDefaultImageSize + kKeySpacing : 0);
    imageHeight = image
    ? image.size.height
    : (imageItem.imageURL ? kDefaultImageSize : 0);
  }

  CGFloat maxWidth = tableView.width - (imageWidth + kTableCellHPadding*2 + kTableCellMargin*2);

  CGSize textSize = [imageItem.text sizeWithFont:BFFSTYLEVAR(tableSmallFont)
                               constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                   lineBreakMode:UILineBreakModeTailTruncation];

  CGFloat contentHeight = textSize.height > imageHeight ? textSize.height : imageHeight;
  return contentHeight + kTableCellVPadding*2;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];

  BFFTableImageItem* item = self.object;
  UIImage* image = item.imageURL ? [[BFFURLCache sharedCache] imageForURL:item.imageURL] : nil;
  if (!image) {
    image = item.defaultImage;
  }

  if ([_item isKindOfClass:[BFFTableRightImageItem class]]) {
    CGFloat imageWidth = image
    ? image.size.width
    : (item.imageURL ? kDefaultImageSize : 0);
    CGFloat imageHeight = image
    ? image.size.height
    : (item.imageURL ? kDefaultImageSize : 0);

    if (_imageView2.urlPath) {
      CGFloat innerWidth = self.contentView.width - (kTableCellHPadding*2 + imageWidth + kKeySpacing);
      CGFloat innerHeight = self.contentView.height - kTableCellVPadding*2;
      self.textLabel.frame = CGRectMake(kTableCellHPadding, kTableCellVPadding, innerWidth, innerHeight);

      _imageView2.frame = CGRectMake(self.textLabel.right + kKeySpacing,
                                     floor(self.height/2 - imageHeight/2),
                                     imageWidth, imageHeight);

    } else {
      self.textLabel.frame = CGRectInset(self.contentView.bounds, kTableCellHPadding, kTableCellVPadding);
      _imageView2.frame = CGRectZero;
    }

  } else {
    if (_imageView2.urlPath) {
      CGFloat iconWidth = image
      ? image.size.width
      : (item.imageURL ? kDefaultImageSize : 0);
      CGFloat iconHeight = image
      ? image.size.height
      : (item.imageURL ? kDefaultImageSize : 0);

      BFFImageStyle* style = [item.imageStyle firstStyleOfClass:[BFFImageStyle class]];
      if (style) {
        _imageView2.contentMode = style.contentMode;
        _imageView2.clipsToBounds = YES;
        _imageView2.backgroundColor = [UIColor clearColor];
        if (style.size.width) {
          iconWidth = style.size.width;
        }
        if (style.size.height) {
          iconHeight = style.size.height;
        }
      }

      _imageView2.frame = CGRectMake(kTableCellHPadding, floor(self.height/2 - iconHeight/2),
                                     iconWidth, iconHeight);

      CGFloat innerWidth = self.contentView.width - (kTableCellHPadding*2 + iconWidth + kKeySpacing);
      CGFloat innerHeight = self.contentView.height - kTableCellVPadding*2;
      self.textLabel.frame = CGRectMake(kTableCellHPadding + iconWidth + kKeySpacing, kTableCellVPadding,
                                        innerWidth, innerHeight);
    } else {
      self.textLabel.frame = CGRectInset(self.contentView.bounds, kTableCellHPadding, kTableCellVPadding);
      _imageView2.frame = CGRectZero;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didMoveToSuperview {
  [super didMoveToSuperview];

  if (self.superview) {
    _imageView2.backgroundColor = self.backgroundColor;
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

    BFFTableImageItem* item = object;
    _imageView2.style = item.imageStyle;
    _imageView2.defaultImage = item.defaultImage;
    _imageView2.urlPath = item.imageURL;

    if ([_item isKindOfClass:[BFFTableRightImageItem class]]) {
      self.textLabel.font = BFFSTYLEVAR(tableSmallFont);
      self.textLabel.textAlignment = UITextAlignmentCenter;
      self.accessoryType = UITableViewCellAccessoryNone;
    } else {
      self.textLabel.font = BFFSTYLEVAR(tableFont);
      self.textLabel.textAlignment = UITextAlignmentLeft;
    }
  }
}


@end
