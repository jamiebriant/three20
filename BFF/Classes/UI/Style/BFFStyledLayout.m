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

#import "BFFStyledLayout.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFStyledFrame.h"
#import "BFFStyleSheet.h"
#import "BFFBoxStyle.h"
#import "BFFTextStyle.h"
#import "BFFStyledElement.h"
#import "BFFStyledInlineFrame.h"
#import "BFFStyledTextFrame.h"
#import "BFFStyledImageFrame.h"
#import "BFFUIFontAdditions.h"

// Styled nodes
#import "BFFStyledImageNode.h"
#import "BFFStyledBoldNode.h"
#import "BFFStyledItalicNode.h"
#import "BFFStyledLinkNode.h"
#import "BFFStyledBlock.h"
#import "BFFStyledLineBreakNode.h"
#import "BFFStyledTextNode.h"

// Core
#import "BFFGlobalCore.h"
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFStyledLayout

@synthesize width         = _width;
@synthesize height        = _height;
@synthesize rootFrame     = _rootFrame;
@synthesize font          = _font;
@synthesize invalidImages = _invalidImages;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithRootNode:(BFFStyledNode*)rootNode {
  if (self = [super init]) {
    _rootNode = rootNode;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithX:(CGFloat)x width:(CGFloat)width height:(CGFloat)height {
  if (self = [super init]) {
    _x = x;
    _minX = x;
    _width = width;
    _height = height;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_rootFrame);
  BFF_RELEASE_SAFELY(_font);
  BFF_RELEASE_SAFELY(_boldFont);
  BFF_RELEASE_SAFELY(_italicFont);
  BFF_RELEASE_SAFELY(_linkStyle);
  BFF_RELEASE_SAFELY(_invalidImages);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)boldVersionOfFont:(UIFont*)font {
  // XXXjoe Clearly this doesn't work if your font is not the system font
  return [UIFont boldSystemFontOfSize:font.pointSize];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)italicVersionOfFont:(UIFont*)font {
  // XXXjoe Clearly this doesn't work if your font is not the system font
  return [UIFont italicSystemFontOfSize:font.pointSize];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledNode*)findLastNode:(BFFStyledNode*)node {
  BFFStyledNode* lastNode = nil;
  while (node) {
    if ([node isKindOfClass:[BFFStyledElement class]]) {
      BFFStyledElement* element = (BFFStyledElement*)node;
      lastNode = [self findLastNode:element.firstChild];
    } else {
      lastNode = node;
    }
    node = node.nextSibling;
  }
  return lastNode;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)boldFont {
  if (!_boldFont) {
    _boldFont = [[self boldVersionOfFont:self.font] retain];
  }
  return _boldFont;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)italicFont {
  if (!_italicFont) {
    _italicFont = [[self italicVersionOfFont:self.font] retain];
  }
  return _italicFont;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)linkStyle {
  if (!_linkStyle) {
    _linkStyle = [BFFSTYLE(linkText:) retain];
  }
  return _linkStyle;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledNode*)lastNode {
  if (!_lastNode) {
    _lastNode = [self findLastNode:_rootNode];
  }
  return _lastNode;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)offsetFrame:(BFFStyledFrame*)frame by:(CGFloat)y {
   frame.y += y;

  if ([frame isKindOfClass:[BFFStyledInlineFrame class]]) {
    BFFStyledInlineFrame* inlineFrame = (BFFStyledInlineFrame*)frame;
    BFFStyledFrame* child = inlineFrame.firstChildFrame;
    while (child) {
      [self offsetFrame:child by:y];
      child = child.nextFrame;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)expandLineWidth:(CGFloat)width {
  _lineWidth += width;
  BFFStyledInlineFrame* inlineFrame = _inlineFrame;
  while (inlineFrame) {
    inlineFrame.width += width;
    inlineFrame = inlineFrame.inlineParentFrame;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)inflateLineHeight:(CGFloat)height {
  if (height > _lineHeight) {
    _lineHeight = height;
  }
  if (_inlineFrame) {
    BFFStyledInlineFrame* inlineFrame = _inlineFrame;
    while (inlineFrame) {
      if (height > inlineFrame.height) {
        inlineFrame.height = height;
      }
      inlineFrame = inlineFrame.inlineParentFrame;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addFrame:(BFFStyledFrame*)frame {
  if (!_rootFrame) {
    _rootFrame = [frame retain];
  } else if (_topFrame) {
    if (!_topFrame.firstChildFrame) {
      _topFrame.firstChildFrame = frame;
    } else {
      _lastFrame.nextFrame = frame;
    }
  } else {
    _lastFrame.nextFrame = frame;
  }
  _lastFrame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pushFrame:(BFFStyledBoxFrame*)frame {
  [self addFrame:frame];
  frame.parentFrame = _topFrame;
  _topFrame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)popFrame {
  _lastFrame = _topFrame;
  _topFrame = _topFrame.parentFrame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledFrame*)addContentFrame:(BFFStyledFrame*)frame width:(CGFloat)width {
  [self addFrame:frame];
  if (!_lineFirstFrame) {
    _lineFirstFrame = frame;
  }
  _x += width;
  return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addContentFrame:(BFFStyledFrame*)frame width:(CGFloat)width height:(CGFloat)height {
  frame.bounds = CGRectMake(_x, _height, width, height);
  [self addContentFrame:frame width:width];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addAbsoluteFrame:(BFFStyledFrame*)frame width:(CGFloat)width height:(CGFloat)height {
  frame.bounds = CGRectMake(_x, _height, width, height);
  [self addFrame:frame];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledInlineFrame*)addInlineFrame:(BFFStyle*)style element:(BFFStyledElement*)element
                        width:(CGFloat)width height:(CGFloat)height {
  BFFStyledInlineFrame* frame = [[[BFFStyledInlineFrame alloc] initWithElement:element] autorelease];
  frame.style = style;
  frame.bounds = CGRectMake(_x, _height, width, height);
  [self pushFrame:frame];
  if (!_lineFirstFrame) {
    _lineFirstFrame = frame;
  }
  return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledInlineFrame*)cloneInlineFrame:(BFFStyledInlineFrame*)frame {
  BFFStyledInlineFrame* parent = frame.inlineParentFrame;
  if (parent) {
    [self cloneInlineFrame:parent];
  }

  BFFStyledInlineFrame* clone = [self addInlineFrame:frame.style element:frame.element
                                     width:0 height:0];
  clone.inlinePreviousFrame = frame;
  frame.inlineNextFrame = clone;
  return clone;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledFrame*)addBlockFrame:(BFFStyle*)style element:(BFFStyledElement*)element
                  width:(CGFloat)width height:(CGFloat)height {
  BFFStyledBoxFrame* frame = [[[BFFStyledBoxFrame alloc] initWithElement:element] autorelease];
  frame.style = style;
  frame.bounds = CGRectMake(_x, _height, width, height);
  [self pushFrame:frame];
  return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)checkFloats {
  if (_floatHeight && _height > _floatHeight) {
    _minX -= _floatLeftWidth;
    _width += _floatLeftWidth+_floatRightWidth;
    _floatRightWidth = 0;
    _floatLeftWidth = 0;
    _floatHeight = 0;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)breakLine {
  if (_inlineFrame) {
    BFFStyledInlineFrame* inlineFrame = _inlineFrame;
    while (inlineFrame) {
      if (inlineFrame.style) {
        BFFBoxStyle* padding = [inlineFrame.style firstStyleOfClass:[BFFBoxStyle class]];
        if (padding) {
          BFFStyledInlineFrame* inlineFrame2 = inlineFrame;
          while (inlineFrame2) {
            inlineFrame2.y -= padding.padding.top;
            inlineFrame2.height += padding.padding.top+padding.padding.bottom;
            inlineFrame2 = inlineFrame2.inlineParentFrame;
          }
        }
      }
      inlineFrame = inlineFrame.inlineParentFrame;
    }
  }

  // Vertically align all frames on the current line
  if (_lineFirstFrame.nextFrame) {
    BFFStyledFrame* frame = _lineFirstFrame;
    while (frame) {
      // Align to the text baseline
      // XXXjoe Support top, bottom, and center alignment also
      if (frame.height < _lineHeight) {
        UIFont* font = frame.font ? frame.font : _font;
        [self offsetFrame:frame by:(_lineHeight - (frame.height - font.descender))];
      }
      frame = frame.nextFrame;
    }
  }

  _height += _lineHeight;
  [self checkFloats];

  _lineWidth = 0;
  _lineHeight = 0;
  _x = _minX;
  _lineFirstFrame = nil;

  if (_inlineFrame) {
    while ([_topFrame isKindOfClass:[BFFStyledInlineFrame class]]) {
      [self popFrame];
    }
    _inlineFrame = [self cloneInlineFrame:_inlineFrame];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyledFrame*)addFrameForText:(NSString*)text element:(BFFStyledElement*)element
                  node:(BFFStyledTextNode*)node width:(CGFloat)width height:(CGFloat)height {
  BFFStyledTextFrame* frame = [[[BFFStyledTextFrame alloc] initWithText:text element:element
                                                         node:node] autorelease];
  frame.font = _font;
  [self addContentFrame:frame width:width height:height];
  return frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutElement:(BFFStyledElement*)elt {
  BFFStyle* style = nil;
  if (elt.className) {
    BFFStyle* eltStyle = [[BFFStyleSheet globalStyleSheet] styleWithSelector:elt.className];
    if (eltStyle) {
      style = eltStyle;
    }
  }
  if (!style && [elt isKindOfClass:[BFFStyledLinkNode class]]) {
    style = self.linkStyle;
  }

  // Figure out which font to use for the node
  UIFont* font = nil;
  BFFTextStyle* textStyle = nil;
  if (style) {
    textStyle = [style firstStyleOfClass:[BFFTextStyle class]];
    if (textStyle) {
      font = textStyle.font;
    }
  }
  if (!font) {
    if ([elt isKindOfClass:[BFFStyledLinkNode class]]
        || [elt isKindOfClass:[BFFStyledBoldNode class]]) {
      font = self.boldFont;
    } else if ([elt isKindOfClass:[BFFStyledItalicNode class]]) {
      font = self.italicFont;
    } else {
      font = self.font;
    }
  }

  UIFont* lastFont = _font;
  self.font = font;

  BFFBoxStyle* padding = style ? [style firstStyleOfClass:[BFFBoxStyle class]] : nil;

  if (padding && padding.position) {
    BFFStyledFrame* blockFrame = [self addBlockFrame:style element:elt width:_width height:_height];

    CGFloat contentWidth = padding.margin.left + padding.margin.right;
    CGFloat contentHeight = padding.margin.top + padding.margin.bottom;

    if (elt.firstChild) {
      BFFStyledNode* child = elt.firstChild;
      BFFStyledLayout* layout = [[[BFFStyledLayout alloc] initWithX:_minX
                                                        width:0 height:_height] autorelease];
      layout.font = _font;
      layout.invalidImages = _invalidImages;
      [layout layout:child];
      if (!_invalidImages && layout.invalidImages) {
        _invalidImages = [layout.invalidImages retain];
      }

      BFFStyledFrame* frame = [self addContentFrame:layout.rootFrame width:layout.width];

      CGFloat frameHeight = layout.height - _height;
      contentWidth += layout.width;
      contentHeight += frameHeight;

      if (padding.position == BFFPositionFloatLeft) {
        frame.x += _floatLeftWidth;
        _floatLeftWidth += contentWidth;
        if (_height+contentHeight > _floatHeight) {
          _floatHeight = contentHeight+_height;
        }
        _minX += contentWidth;
        _width -= contentWidth;
      } else if (padding.position == BFFPositionFloatRight) {
        frame.x += _width - (_floatRightWidth + contentWidth);
        _floatRightWidth += contentWidth;
        if (_height+contentHeight > _floatHeight) {
          _floatHeight = contentHeight+_height;
        }
        _x -= contentWidth;
        _width -= contentWidth;
      }

      blockFrame.width = layout.width + padding.padding.left + padding.padding.right;
      blockFrame.height = frameHeight + padding.padding.top + padding.padding.bottom;
    }
  } else {
    CGFloat minX = _minX, width = _width, floatLeftWidth = _floatLeftWidth,
            floatRightWidth = _floatRightWidth, floatHeight = _floatHeight;
    BOOL isBlock = [elt isKindOfClass:[BFFStyledBlock class]];
    BFFStyledFrame* blockFrame = nil;

    if (isBlock) {
      if (padding) {
        _x += padding.margin.left;
        _minX += padding.margin.left;
        _width -= padding.margin.left + padding.margin.right;
        _height += padding.margin.top;
      }

      if (_lastFrame) {
        if (!_lineHeight && [elt isKindOfClass:[BFFStyledLineBreakNode class]]) {
          _lineHeight = [_font ttLineHeight];
        }
        [self breakLine];
      }
      if (style) {
        blockFrame = [self addBlockFrame:style element:elt width:_width height:_height];
      }
    } else {
      if (padding) {
        _x += padding.margin.left;
        _height += padding.margin.top;
      }
      if (style) {
        _inlineFrame = [self addInlineFrame:style element:elt width:0 height:0];
      }
    }

    if (padding) {
      if (isBlock) {
        _minX += padding.padding.left;
      }
      _width -= padding.padding.left+padding.padding.right;
      _x += padding.padding.left;
      [self expandLineWidth:padding.padding.left];

      if (isBlock) {
        _height += padding.padding.top;
      }
    }

    if (elt.firstChild) {
      [self layout:elt.firstChild container:elt];
    }

    if (isBlock) {
      _minX = minX, _width = width, _floatLeftWidth = floatLeftWidth,
      _floatRightWidth = floatRightWidth, _floatHeight = floatHeight;
      [self breakLine];

      if (padding) {
        _height += padding.padding.bottom;
      }

      blockFrame.height = _height - blockFrame.height;

      if (padding) {
        if (blockFrame.height < padding.minSize.height) {
          _height += padding.minSize.height - blockFrame.height;
          blockFrame.height = padding.minSize.height;
        }

        _height += padding.margin.bottom;
      }
    } else if (!isBlock && style) {
      if (padding) {
        _x += padding.padding.right + padding.margin.right;
        _lineWidth += padding.padding.right + padding.margin.right;

        BFFStyledInlineFrame* inlineFrame = _inlineFrame;
        while (inlineFrame) {
          if (inlineFrame != _inlineFrame) {
            inlineFrame.width += padding.margin.right;
          }
          inlineFrame.width += padding.padding.right;
          inlineFrame.y -= padding.padding.top;
          inlineFrame.height += padding.padding.top+padding.padding.bottom;
          inlineFrame = inlineFrame.inlineParentFrame;
        }
      }
      _inlineFrame = _inlineFrame.inlineParentFrame;
    }
  }

  self.font = lastFont;

  if (style) {
    [self popFrame];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutImage:(BFFStyledImageNode*)imageNode container:(BFFStyledElement*)element {
  UIImage* image = imageNode.image;
  if (!image && imageNode.URL) {
    if (!_invalidImages) {
      _invalidImages = BFFCreateNonRetainingArray();
    }
    [_invalidImages addObject:imageNode];
  }

  BFFStyle* style = imageNode.className
    ? [[BFFStyleSheet globalStyleSheet] styleWithSelector:imageNode.className] : nil;
  BFFBoxStyle* padding = style ? [style firstStyleOfClass:[BFFBoxStyle class]] : nil;

  CGFloat imageWidth = imageNode.width ? imageNode.width : image.size.width;
  CGFloat imageHeight = imageNode.height ? imageNode.height : image.size.height;
  CGFloat contentWidth = imageWidth;
  CGFloat contentHeight = imageHeight;

  if (padding && padding.position != BFFPositionAbsolute) {
    _x += padding.margin.left;
    contentWidth += padding.margin.left + padding.margin.right;
    contentHeight += padding.margin.top + padding.margin.bottom;
  }

  if ((!padding || !padding.position) && (_lineWidth + contentWidth > _width)) {
    if (_lineWidth) {
      // The image will be placed on the next line, so create a new frame for
      // the current line and mark it with a line break
      [self breakLine];
    } else {
      _width = contentWidth;
    }
  }

  BFFStyledImageFrame* frame = [[[BFFStyledImageFrame alloc] initWithElement:element
                                                           node:imageNode] autorelease];
  frame.style = style;

  if (!padding || !padding.position) {
    [self addContentFrame:frame width:imageWidth height:imageHeight];
    [self expandLineWidth:contentWidth];
    [self inflateLineHeight:contentHeight];
  } else if (padding.position == BFFPositionAbsolute) {
    [self addAbsoluteFrame:frame width:imageWidth height:imageHeight];
    frame.x += padding.margin.left;
    frame.y += padding.margin.top;
  } else if (padding.position == BFFPositionFloatLeft) {
    [self addContentFrame:frame width:imageWidth height:imageHeight];

    frame.x += _floatLeftWidth;
    _floatLeftWidth += contentWidth;
    if (_height+contentHeight > _floatHeight) {
      _floatHeight = contentHeight+_height;
    }
    _minX += contentWidth;
    _width -= contentWidth;
  } else if (padding.position == BFFPositionFloatRight) {
    [self addContentFrame:frame width:imageWidth height:imageHeight];

    frame.x += _width - (_floatRightWidth + contentWidth);
    _floatRightWidth += contentWidth;
    if (_height+contentHeight > _floatHeight) {
      _floatHeight = contentHeight+_height;
    }
    _x -= contentWidth;
    _width -= contentWidth;
  }

  if (padding && padding.position != BFFPositionAbsolute) {
    frame.y += padding.margin.top;
    _x += padding.margin.right;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutText:(BFFStyledTextNode*)textNode container:(BFFStyledElement*)element {
  NSString* text = textNode.text;
  NSUInteger length = text.length;

  if (!textNode.nextSibling && textNode == _rootNode) {
    // This is the only node, so measure it all at once and move on
    CGSize textSize = [text sizeWithFont:_font
                            constrainedToSize:CGSizeMake(_width, CGFLOAT_MAX)
                            lineBreakMode:UILineBreakModeWordWrap];
    [self addFrameForText:text element:element node:textNode width:textSize.width
         height:textSize.height];
    _height += textSize.height;
    return;
  }

  NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];

  NSInteger stringIndex = 0;
  NSInteger lineStartIndex = 0;
  CGFloat frameWidth = 0;

  while (stringIndex < length) {
    // Search for the next whitespace character
    NSRange searchRange = NSMakeRange(stringIndex, length - stringIndex);
    NSRange spaceRange = [text rangeOfCharacterFromSet:whitespace options:0 range:searchRange];

    // Get the word prior to the whitespace
    NSRange wordRange = spaceRange.location != NSNotFound
      ? NSMakeRange(searchRange.location, (spaceRange.location+1) - searchRange.location)
      : NSMakeRange(searchRange.location, length - searchRange.location);
    NSString* word = [text substringWithRange:wordRange];

    // If there is no width to constrain to, then just use an infinite width,
    // which will prevent any word wrapping
    CGFloat availWidth = _width ? _width : CGFLOAT_MAX;

    // Measure the word and check to see if it fits on the current line
    CGSize wordSize = [word sizeWithFont:_font];
    if (wordSize.width > _width) {
      for (NSInteger i = 0; i < word.length; ++i) {
        NSString* c = [word substringWithRange:NSMakeRange(i, 1)];
        CGSize letterSize = [c sizeWithFont:_font];

        if (_lineWidth + letterSize.width > _width) {
          NSRange lineRange = NSMakeRange(lineStartIndex, stringIndex - lineStartIndex);
          if (lineRange.length) {
            NSString* line = [text substringWithRange:lineRange];
            [self addFrameForText:line element:element node:textNode width:frameWidth
                  height:_lineHeight ? _lineHeight : [_font ttLineHeight]];
          }

          if (_lineWidth) {
            [self breakLine];
          }

          lineStartIndex = lineRange.location + lineRange.length;
          frameWidth = 0;
        }

        frameWidth += letterSize.width;
        [self expandLineWidth:letterSize.width];
        [self inflateLineHeight:wordSize.height];
        ++stringIndex;
      }

      NSRange lineRange = NSMakeRange(lineStartIndex, stringIndex - lineStartIndex);
      if (lineRange.length) {
        NSString* line = [text substringWithRange:lineRange];
        [self addFrameForText:line element:element node:textNode width:frameWidth
              height:_lineHeight ? _lineHeight : [_font ttLineHeight]];

        lineStartIndex = lineRange.location + lineRange.length;
        frameWidth = 0;
      }
    } else {
      if (_lineWidth + wordSize.width > _width) {
        // The word will be placed on the next line, so create a new frame for
        // the current line and mark it with a line break
        NSRange lineRange = NSMakeRange(lineStartIndex, stringIndex - lineStartIndex);
        if (lineRange.length) {
          NSString* line = [text substringWithRange:lineRange];
          [self addFrameForText:line element:element node:textNode width:frameWidth
                height:_lineHeight ? _lineHeight : [_font ttLineHeight]];
        }

        if (_lineWidth) {
          [self breakLine];
        }
        lineStartIndex = lineRange.location + lineRange.length;
        frameWidth = 0;
      }

      if (!_lineWidth && textNode == _lastNode) {
        // We are at the start of a new line, and this is the last node, so we don't need to
        // keep measuring every word.  We can just measure all remaining text and create a new
        // frame for all of it.
        NSString* lines = [text substringWithRange:searchRange];
        CGSize linesSize = [lines sizeWithFont:_font
                                  constrainedToSize:CGSizeMake(availWidth, CGFLOAT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];

        [self addFrameForText:lines element:element node:textNode width:linesSize.width
             height:linesSize.height];
        _height += linesSize.height;
        break;
      }

      frameWidth += wordSize.width;
      [self expandLineWidth:wordSize.width];
      [self inflateLineHeight:wordSize.height];

      stringIndex = wordRange.location + wordRange.length;
      if (stringIndex >= length) {
        // The current word was at the very end of the string
        NSRange lineRange = NSMakeRange(lineStartIndex, (wordRange.location + wordRange.length)
                                                        - lineStartIndex);
        NSString* line = !_lineWidth ? word : [text substringWithRange:lineRange];
        [self addFrameForText:line element:element node:textNode width:frameWidth
              height:[_font ttLineHeight]];
        frameWidth = 0;
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  if (!_font) {
    self.font = BFFSTYLEVAR(font);
  }
  return _font;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    BFF_RELEASE_SAFELY(_boldFont);
    BFF_RELEASE_SAFELY(_italicFont);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layout:(BFFStyledNode*)node container:(BFFStyledElement*)element {
  while (node) {
    if ([node isKindOfClass:[BFFStyledImageNode class]]) {
      BFFStyledImageNode* imageNode = (BFFStyledImageNode*)node;
      [self layoutImage:imageNode container:element];
    } else if ([node isKindOfClass:[BFFStyledElement class]]) {
      BFFStyledElement* elt = (BFFStyledElement*)node;
      [self layoutElement:elt];
    } else if ([node isKindOfClass:[BFFStyledTextNode class]]) {
      BFFStyledTextNode* textNode = (BFFStyledTextNode*)node;
      [self layoutText:textNode container:element];
    }

    node = node.nextSibling;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layout:(BFFStyledNode*)node {
  [self layout:node container:nil];
  if (_lineWidth) {
    [self breakLine];
  }
}


@end
