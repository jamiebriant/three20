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

#import "BFFShadowStyle.h"

// Style
#import "BFFStyleContext.h"
#import "BFFShape.h"

// Core
#import "BFFCorePreprocessorMacros.h"
#import "BFFGlobalCoreRects.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFShadowStyle

@synthesize color   = _color;
@synthesize blur    = _blur;
@synthesize offset  = _offset;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(BFFStyle*)next {
  if (self = [super initWithNext:next]) {
    _offset = CGSizeZero;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_color);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFShadowStyle*)styleWithColor:(UIColor*)color blur:(CGFloat)blur offset:(CGSize)offset
                            next:(BFFStyle*)next {
  BFFShadowStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.color = color;
  style.blur = blur;
  style.offset = offset;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(BFFStyleContext*)context {
  CGFloat blurSize = round(_blur / 2);
  UIEdgeInsets inset = UIEdgeInsetsMake(blurSize, blurSize, blurSize, blurSize);
  if (_offset.width < 0) {
    inset.left += fabs(_offset.width) + blurSize*2;
    inset.right -= blurSize;
  } else if (_offset.width > 0) {
    inset.right += fabs(_offset.width) + blurSize*2;
    inset.left -= blurSize;
  }
  if (_offset.height < 0) {
    inset.top += fabs(_offset.height) + blurSize*2;
    inset.bottom -= blurSize;
  } else if (_offset.height > 0) {
    inset.bottom += fabs(_offset.height) + blurSize*2;
    inset.top -= blurSize;
  }

  context.frame = BFFRectInset(context.frame, inset);
  context.contentFrame = BFFRectInset(context.contentFrame, inset);

  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);

  [context.shape addToPath:context.frame];
  CGContextSetShadowWithColor(ctx, CGSizeMake(_offset.width, -_offset.height), _blur,
                              _color.CGColor);
  CGContextBeginTransparencyLayer(ctx, nil);
  [self.next draw:context];
  CGContextEndTransparencyLayer(ctx);

  CGContextRestoreGState(ctx);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(BFFStyleContext*)context {
  CGFloat blurSize = round(_blur / 2);
  size.width += _offset.width + (_offset.width ? blurSize : 0) + blurSize*2;
  size.height += _offset.height + (_offset.height ? blurSize : 0) + blurSize*2;

  if (_next) {
    return [self.next addToSize:size context:context];
  } else {
    return size;
  }
}


@end
