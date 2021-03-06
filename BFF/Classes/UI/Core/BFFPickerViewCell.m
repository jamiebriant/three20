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

#import "BFFPickerViewCell.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFDefaultStyleSheet.h"

// Core
#import "BFFCorePreprocessorMacros.h"

static const CGFloat kPaddingX = 8;
static const CGFloat kPaddingY = 3;
static const CGFloat kMaxWidth = 250;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFPickerViewCell

@synthesize object    = _object;
@synthesize selected  = _selected;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _labelView = [[UILabel alloc] init];
    _labelView.backgroundColor = [UIColor clearColor];
    _labelView.textColor = BFFSTYLEVAR(textColor);
    _labelView.highlightedTextColor = BFFSTYLEVAR(highlightedTextColor);
    _labelView.lineBreakMode = UILineBreakModeTailTruncation;
    [self addSubview:_labelView];

    self.backgroundColor = [UIColor clearColor];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_object);
  BFF_RELEASE_SAFELY(_labelView);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  _labelView.frame = CGRectMake(kPaddingX, kPaddingY,
    self.frame.size.width-kPaddingX*2, self.frame.size.height-kPaddingY*2);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  CGSize labelSize = [_labelView.text sizeWithFont:_labelView.font];
  CGFloat width = labelSize.width + kPaddingX*2;
  return CGSizeMake(width > kMaxWidth ? kMaxWidth : width, labelSize.height + kPaddingY*2);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)style {
  if (self.selected) {
    return BFFSTYLESTATE(pickerCell:, UIControlStateSelected);
  } else {
    return BFFSTYLESTATE(pickerCell:, UIControlStateNormal);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)label {
  return _labelView.text;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLabel:(NSString*)label {
  _labelView.text = label;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  return _labelView.font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  _labelView.font = font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelected:(BOOL)selected {
  _selected = selected;

  _labelView.highlighted = selected;
  [self setNeedsDisplay];
}


@end
