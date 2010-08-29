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

#import "BFFStyledBoxFrame.h"

// Style
#import "BFFStyleContext.h"
#import "BFFTextStyle.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFStyledBoxFrame

@synthesize parentFrame     = _parentFrame;
@synthesize firstChildFrame = _firstChildFrame;
@synthesize style           = _style;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_firstChildFrame);
  BFF_RELEASE_SAFELY(_style);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawSubframes {
  BFFStyledFrame* frame = _firstChildFrame;
  while (frame) {
    [frame drawInRect:frame.bounds];
    frame = frame.nextFrame;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFStyleDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawLayer:(BFFStyleContext*)context withStyle:(BFFStyle*)style {
  if ([style isKindOfClass:[BFFTextStyle class]]) {
    BFFTextStyle* textStyle = (BFFTextStyle*)style;
    UIFont* font = context.font;
    context.font = textStyle.font;
    if (textStyle.color) {
      CGContextRef ctx = UIGraphicsGetCurrentContext();
      CGContextSaveGState(ctx);
      [textStyle.color setFill];

      [self drawSubframes];

      CGContextRestoreGState(ctx);

    } else {
      [self drawSubframes];
    }

    context.font = font;

  } else {
    [self drawSubframes];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFStyledFrame


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  return _firstChildFrame.font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect {
  if (_style && !CGRectIsEmpty(_bounds)) {
    BFFStyleContext* context = [[[BFFStyleContext alloc] init] autorelease];
    context.delegate = self;
    context.frame = rect;
    context.contentFrame = rect;

    [_style draw:context];
    if (context.didDrawContent) {
      return;
    }
  }

  [self drawSubframes];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledBoxFrame*)hitTest:(CGPoint)point {
  if (CGRectContainsPoint(_bounds, point)) {
    BFFStyledBoxFrame* frame = [_firstChildFrame hitTest:point];
    return frame ? frame : self;

  } else if (_nextFrame) {
    return [_nextFrame hitTest:point];

  } else {
    return nil;
  }
}


@end
