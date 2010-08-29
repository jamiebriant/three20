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

#import "BFFButton.h"

// UI (private)
#import "BFFButtonContent.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFDefaultStyleSheet.h"
#import "BFFStyleContext.h"
#import "BFFTextStyle.h"
#import "BFFPartStyle.h"
#import "BFFBoxStyle.h"
#import "BFFImageStyle.h"
#import "BFFUIImageAdditions.h"

// Core
#import "BFFCorePreprocessorMacros.h"

static const CGFloat kHPadding = 8;
static const CGFloat kVPadding = 7;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFButton

@synthesize font        = _font;
@synthesize isVertical  = _isVertical;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_content);
  BFF_RELEASE_SAFELY(_font);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFButton*)buttonWithStyle:(NSString*)selector {
  BFFButton* button = [[[BFFButton alloc] init] autorelease];
  [button setStylesWithSelector:selector];
  return button;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFButton*)buttonWithStyle:(NSString*)selector title:(NSString*)title {
  BFFButton* button = [[[BFFButton alloc] init] autorelease];
  [button setTitle:title forState:UIControlStateNormal];
  [button setStylesWithSelector:selector];
  return button;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)keyForState:(UIControlState)state {
  static NSString* normalKey = @"normal";
  static NSString* highlighted = @"highlighted";
  static NSString* selected = @"selected";
  static NSString* disabled = @"disabled";
  if (state & UIControlStateHighlighted) {
    return highlighted;
  } else if (state & UIControlStateSelected) {
    return selected;
  } else if (state & UIControlStateDisabled) {
    return disabled;
  } else {
    return normalKey;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFButtonContent*)contentForState:(UIControlState)state {
  if (!_content) {
    _content = [[NSMutableDictionary alloc] init];
  }

  id key = [self keyForState:state];
  BFFButtonContent* content = [_content objectForKey:key];
  if (!content) {
    content = [[[BFFButtonContent alloc] initWithButton:self] autorelease];
    [_content setObject:content forKey:key];
  }

  return content;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFButtonContent*)contentForCurrentState {
  BFFButtonContent* content = nil;
  if (self.selected) {
    content = [self contentForState:UIControlStateSelected];
  } else if (self.highlighted) {
    content = [self contentForState:UIControlStateHighlighted];
  } else if (!self.enabled) {
    content = [self contentForState:UIControlStateDisabled];
  }

  return content ? content : [self contentForState:UIControlStateNormal];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForCurrentState {
  BFFButtonContent* content = [self contentForCurrentState];
  return content.title ? content.title : [self contentForState:UIControlStateNormal].title;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForCurrentState {
  BFFButtonContent* content = [self contentForCurrentState];
  return content.image ? content.image : [self contentForState:UIControlStateNormal].image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)styleForCurrentState {
  BFFButtonContent* content = [self contentForCurrentState];
  return content.style ? content.style : [self contentForState:UIControlStateNormal].style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)fontForCurrentState {
  if (_font) {
    return _font;
  } else {
    BFFStyle* style = [self styleForCurrentState];
    BFFTextStyle* textStyle = (BFFTextStyle*)[style firstStyleOfClass:[BFFTextStyle class]];
    if (textStyle.font) {
      return textStyle.font;
    } else {
      return self.font;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
  BFFStyle* style = [self styleForCurrentState];
  if (style) {
    CGRect textFrame = self.bounds;

    BFFStyleContext* context = [[[BFFStyleContext alloc] init] autorelease];
    context.delegate = self;

    BFFPartStyle* imageStyle = [style styleForPart:@"image"];
    BFFBoxStyle* imageBoxStyle = nil;
    CGSize imageSize = CGSizeZero;
    if (imageStyle) {
      imageBoxStyle = [imageStyle.style firstStyleOfClass:[BFFBoxStyle class]];
      imageSize = [imageStyle.style addToSize:CGSizeZero context:context];
      if (_isVertical) {
        CGFloat height = imageSize.height + imageBoxStyle.margin.top + imageBoxStyle.margin.bottom;
        textFrame.origin.y += height;
        textFrame.size.height -= height;
      } else {
        textFrame.origin.x += imageSize.width + imageBoxStyle.margin.right;
        textFrame.size.width -= imageSize.width + imageBoxStyle.margin.right;
      }
    }

    context.delegate = self;
    context.frame = self.bounds;
    context.contentFrame = textFrame;
    context.font = [self fontForCurrentState];

    [style draw:context];

    if (imageStyle) {
      CGRect frame = context.contentFrame;
      if (_isVertical) {
        frame = self.bounds;
        frame.origin.x += imageBoxStyle.margin.left;
        frame.origin.y += imageBoxStyle.margin.top;
      } else {
        frame.size = imageSize;
        frame.origin.x += imageBoxStyle.margin.left;
        frame.origin.y += imageBoxStyle.margin.top;
      }

      context.frame = frame;
      context.contentFrame = context.frame;
      context.shape = nil;

      [imageStyle drawPart:context];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  BFFStyleContext* context = [[[BFFStyleContext alloc] init] autorelease];
  context.delegate = self;
  context.font = [self fontForCurrentState];

  BFFStyle* style = [self styleForCurrentState];
  if (style) {
    return [style addToSize:CGSizeZero context:context];
  } else {
    return size;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIControl


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAccessibility


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isAccessibilityElement {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)accessibilityLabel {
  return [self titleForCurrentState];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIAccessibilityTraits)accessibilityTraits {
  return [super accessibilityTraits] | UIAccessibilityTraitButton;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFStyleDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)textForLayerWithStyle:(BFFStyle*)style {
  return [self titleForCurrentState];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForLayerWithStyle:(BFFStyle*)style {
  return [self imageForCurrentState];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  if (!_font) {
    _font = [BFFSTYLEVAR(buttonFont) retain];
  }
  return _font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [self setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForState:(UIControlState)state {
  return [self contentForState:state].title;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTitle:(NSString*)title forState:(UIControlState)state {
  BFFButtonContent* content = [self contentForState:state];
  content.title = title;
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)imageForState:(UIControlState)state {
  return [self contentForState:state].imageURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImage:(NSString*)imageURL forState:(UIControlState)state {
  BFFButtonContent* content = [self contentForState:state];
  content.imageURL = imageURL;
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)styleForState:(UIControlState)state {
  return [self contentForState:state].style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStyle:(BFFStyle*)style forState:(UIControlState)state {
  BFFButtonContent* content = [self contentForState:state];
  content.style = style;
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStylesWithSelector:(NSString*)selector {
  BFFStyleSheet* ss = [BFFStyleSheet globalStyleSheet];

  BFFStyle* normalStyle = [ss styleWithSelector:selector forState:UIControlStateNormal];
  [self setStyle:normalStyle forState:UIControlStateNormal];

  BFFStyle* highlightedStyle = [ss styleWithSelector:selector forState:UIControlStateHighlighted];
  [self setStyle:highlightedStyle forState:UIControlStateHighlighted];

  BFFStyle* selectedStyle = [ss styleWithSelector:selector forState:UIControlStateSelected];
  [self setStyle:selectedStyle forState:UIControlStateSelected];

  BFFStyle* disabledStyle = [ss styleWithSelector:selector forState:UIControlStateDisabled];
  [self setStyle:disabledStyle forState:UIControlStateDisabled];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)suspendLoadingImages:(BOOL)suspended {
  BFFButtonContent* content = [self contentForCurrentState];
  if (suspended) {
    [content stopLoading];
  } else if (!content.image) {
    [content reload];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForImage {
  BFFStyle* style = [self styleForCurrentState];
  if (style) {
    BFFStyleContext* context = [[[BFFStyleContext alloc] init] autorelease];
    context.delegate = self;

    BFFPartStyle* imagePartStyle = [style styleForPart:@"image"];
    if (imagePartStyle) {
      BFFImageStyle* imageStyle = [imagePartStyle.style firstStyleOfClass:[BFFImageStyle class]];
      BFFBoxStyle* imageBoxStyle = [imagePartStyle.style firstStyleOfClass:[BFFBoxStyle class]];
      CGSize imageSize = [imagePartStyle.style addToSize:CGSizeZero context:context];

      CGRect frame = context.contentFrame;
      if (_isVertical) {
        frame = self.bounds;
        frame.origin.x += imageBoxStyle.margin.left;
        frame.origin.y += imageBoxStyle.margin.top;
      } else {
        frame.size = imageSize;
        frame.origin.x += imageBoxStyle.margin.left;
        frame.origin.y += imageBoxStyle.margin.top;
      }

      UIImage* image = [self imageForCurrentState];
      return [image convertRect:frame withContentMode:imageStyle.contentMode];
    }
  }

  return CGRectZero;
}


@end
