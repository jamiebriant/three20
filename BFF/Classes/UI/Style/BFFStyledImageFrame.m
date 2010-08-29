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

#import "BFFStyledImageFrame.h"

// Style
#import "BFFStyledImageNode.h"
#import "BFFStyleContext.h"
#import "BFFShape.h"
#import "BFFImageStyle.h"
#import "BFFUIImageAdditions.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFStyledImageFrame

@synthesize imageNode = _imageNode;
@synthesize style     = _style;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithElement:(BFFStyledElement*)element node:(BFFStyledImageNode*)node {
  if (self = [super initWithElement:element]) {
    _imageNode = node;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_style);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawImage:(CGRect)rect {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  CGContextAddRect(ctx, rect);
  CGContextClip(ctx);

  UIImage* image = _imageNode.image ? _imageNode.image : _imageNode.defaultImage;
  [image drawInRect:rect contentMode:UIViewContentModeScaleAspectFit];
  CGContextRestoreGState(ctx);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFStyleDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawLayer:(BFFStyleContext*)context withStyle:(BFFStyle*)style {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  [context.shape addToPath:context.frame];
  CGContextClip(ctx);

  UIViewContentMode contentMode = UIViewContentModeScaleAspectFit;
  if ([style isMemberOfClass:[BFFImageStyle class]]) {
    BFFImageStyle* imageStyle = (BFFImageStyle*)style;
    contentMode = imageStyle.contentMode;
  }

  UIImage* image = _imageNode.image ? _imageNode.image : _imageNode.defaultImage;
  [image drawInRect:context.contentFrame contentMode:contentMode];

  CGContextRestoreGState(ctx);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawInRect:(CGRect)rect {
  if (_style) {
    BFFStyleContext* context = [[[BFFStyleContext alloc] init] autorelease];
    context.delegate = self;
    context.frame = rect;
    context.contentFrame = rect;

    [_style draw:context];
    if (!context.didDrawContent) {
      [self drawImage:rect];
    }

  } else {
    [self drawImage:rect];
  }
}


@end
