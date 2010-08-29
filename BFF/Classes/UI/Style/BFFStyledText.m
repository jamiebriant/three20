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

#import "BFFStyledText.h"

// Style
#import "BFFStyledTextDelegate.h"
#import "BFFStyledNode.h"
#import "BFFStyledFrame.h"
#import "BFFStyledLayout.h"
#import "BFFStyledTextParser.h"
#import "BFFStyledImageNode.h"
#import "BFFStyledTextNode.h"
#import "BFFStyledBoxFrame.h"
#import "BFFStyledTextFrame.h"
#import "BFFStyledImageFrame.h"

// Network
#import "BFFURLImageResponse.h"
#import "BFFURLCache.h"
#import "BFFURLRequest.h"

// Core
#import "BFFGlobalCore.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface BFFStyledText()

- (void)stopLoadingImages;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFStyledText

@synthesize rootNode      = _rootNode;
@synthesize font          = _font;
@synthesize width         = _width;
@synthesize height        = _height;
@synthesize invalidImages = _invalidImages;
@synthesize delegate      = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNode:(BFFStyledNode*)rootNode {
  if (self = [super init]) {
    _rootNode = [rootNode retain];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [self stopLoadingImages];
  BFF_RELEASE_SAFELY(_rootNode);
  BFF_RELEASE_SAFELY(_rootFrame);
  BFF_RELEASE_SAFELY(_font);
  BFF_RELEASE_SAFELY(_invalidImages);
  BFF_RELEASE_SAFELY(_imageRequests);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)description {
  return [self.rootNode outerText];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFStyledText*)textFromXHTML:(NSString*)source {
  return [self textFromXHTML:source lineBreaks:NO URLs:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFStyledText*)textFromXHTML:(NSString*)source lineBreaks:(BOOL)lineBreaks URLs:(BOOL)URLs {
  BFFStyledTextParser* parser = [[[BFFStyledTextParser alloc] init] autorelease];
  parser.parseLineBreaks = lineBreaks;
  parser.parseURLs = URLs;
  [parser parseXHTML:source];
  if (parser.rootNode) {
    return [[[BFFStyledText alloc] initWithNode:parser.rootNode] autorelease];

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFStyledText*)textWithURLs:(NSString*)source {
  return [self textWithURLs:source lineBreaks:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFStyledText*)textWithURLs:(NSString*)source lineBreaks:(BOOL)lineBreaks {
  BFFStyledTextParser* parser = [[[BFFStyledTextParser alloc] init] autorelease];
  parser.parseLineBreaks = lineBreaks;
  parser.parseURLs = YES;
  [parser parseText:source];
  if (parser.rootNode) {
    return [[[BFFStyledText alloc] initWithNode:parser.rootNode] autorelease];

  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopLoadingImages {
  if (_imageRequests) {
    NSMutableArray* requests = [_imageRequests retain];
    BFF_RELEASE_SAFELY(_imageRequests);

    if (!_invalidImages) {
      _invalidImages = [[NSMutableArray alloc] init];
    }

    for (BFFURLRequest* request in requests) {
      [_invalidImages addObject:request.userInfo];
      [request cancel];
    }
    [requests release];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadImages {
  [self stopLoadingImages];

  if (_delegate && _invalidImages) {
    BOOL loadedSome = NO;
    for (BFFStyledImageNode* imageNode in _invalidImages) {
      if (imageNode.URL) {
        UIImage* image = [[BFFURLCache sharedCache] imageForURL:imageNode.URL];
        if (image) {
          imageNode.image = image;
          loadedSome = YES;

        } else {
          BFFURLRequest* request = [BFFURLRequest requestWithURL:imageNode.URL delegate:self];
          request.userInfo = imageNode;
          request.response = [[[BFFURLImageResponse alloc] init] autorelease];
          [request send];
        }
      }
    }

    BFF_RELEASE_SAFELY(_invalidImages);

    if (loadedSome) {
      [_delegate styledTextNeedsDisplay:self];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledFrame*)getFrameForNode:(BFFStyledNode*)node inFrame:(BFFStyledFrame*)frame {
  while (frame) {
    if ([frame isKindOfClass:[BFFStyledBoxFrame class]]) {
      BFFStyledBoxFrame* boxFrame = (BFFStyledBoxFrame*)frame;
      if (boxFrame.element == node) {
        return boxFrame;
      }

      BFFStyledFrame* found = [self getFrameForNode:node inFrame:boxFrame.firstChildFrame];
      if (found) {
        return found;
      }

    } else if ([frame isKindOfClass:[BFFStyledTextFrame class]]) {
      BFFStyledTextFrame* textFrame = (BFFStyledTextFrame*)frame;
      if (textFrame.node == node) {
        return textFrame;
      }

    } else if ([frame isKindOfClass:[BFFStyledImageFrame class]]) {
      BFFStyledImageFrame* imageFrame = (BFFStyledImageFrame*)frame;
      if (imageFrame.imageNode == node) {
        return imageFrame;
      }
    }

    frame = frame.nextFrame;
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(BFFURLRequest*)request {
  if (!_imageRequests) {
    _imageRequests = [[NSMutableArray alloc] init];
  }
  [_imageRequests addObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(BFFURLRequest*)request {
  BFFURLImageResponse* response = request.response;
  BFFStyledImageNode* imageNode = request.userInfo;
  imageNode.image = response.image;

  [_imageRequests removeObject:request];

  [_delegate styledTextNeedsDisplay:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)request:(BFFURLRequest*)request didFailLoadWithError:(NSError*)error {
  [_imageRequests removeObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidCancelLoad:(BFFURLRequest*)request {
  [_imageRequests removeObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<BFFStyledTextDelegate>)delegate {
  if (_delegate != delegate) {
    _delegate = delegate;
    [self loadImages];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledFrame*)rootFrame {
  [self layoutIfNeeded];
  return _rootFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [self setNeedsLayout];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setWidth:(CGFloat)width {
  if (width != _width) {
    _width = width;
    [self setNeedsLayout];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
  [self layoutIfNeeded];
  return _height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)needsLayout {
  return !_rootFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutFrames {
  BFFStyledLayout* layout = [[BFFStyledLayout alloc] initWithRootNode:_rootNode];
  layout.width = _width;
  layout.font = _font;
  [layout layout:_rootNode];

  [_rootFrame release];
  _rootFrame = [layout.rootFrame retain];
  _height = ceil(layout.height);
  [_invalidImages release];
  _invalidImages = [layout.invalidImages retain];
  [layout release];

  [self loadImages];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutIfNeeded {
  if (!_rootFrame) {
    [self layoutFrames];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setNeedsLayout {
  BFF_RELEASE_SAFELY(_rootFrame);
  _height = 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawAtPoint:(CGPoint)point {
  [self drawAtPoint:point highlighted:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawAtPoint:(CGPoint)point highlighted:(BOOL)highlighted {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  CGContextTranslateCTM(ctx, point.x, point.y);

  BFFStyledFrame* frame = self.rootFrame;
  while (frame) {
    [frame drawInRect:frame.bounds];
    frame = frame.nextFrame;
  }

  CGContextRestoreGState(ctx);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledBoxFrame*)hitTest:(CGPoint)point {
  return [self.rootFrame hitTest:point];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledFrame*)getFrameForNode:(BFFStyledNode*)node {
  return [self getFrameForNode:node inFrame:_rootFrame];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addChild:(BFFStyledNode*)child {
  if (!_rootNode) {
    self.rootNode = child;
  } else {
    BFFStyledNode* previousNode = _rootNode;
    BFFStyledNode* node = _rootNode.nextSibling;
    while (node) {
      previousNode = node;
      node = node.nextSibling;
    }
    previousNode.nextSibling = child;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addText:(NSString*)text {
  [self addChild:[[[BFFStyledTextNode alloc] initWithText:text] autorelease]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)insertChild:(BFFStyledNode*)child atIndex:(NSInteger)insertIndex {
  if (!_rootNode) {
    self.rootNode = child;
  } else if (insertIndex == 0) {
    child.nextSibling = _rootNode;
    self.rootNode = child;
  } else {
    NSInteger i = 0;
    BFFStyledNode* previousNode = _rootNode;
    BFFStyledNode* node = _rootNode.nextSibling;
    while (node && i != insertIndex) {
      ++i;
      previousNode = node;
      node = node.nextSibling;
    }
    child.nextSibling = node;
    previousNode.nextSibling = child;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledNode*)getElementByClassName:(NSString*)className {
  BFFStyledNode* node = _rootNode;
  while (node) {
    if ([node isKindOfClass:[BFFStyledElement class]]) {
      BFFStyledElement* element = (BFFStyledElement*)node;
      if ([element.className isEqualToString:className]) {
        return element;
      }

      BFFStyledNode* found = [element getElementByClassName:className];
      if (found) {
        return found;
      }
    }
    node = node.nextSibling;
  }
  return nil;
}


@end
