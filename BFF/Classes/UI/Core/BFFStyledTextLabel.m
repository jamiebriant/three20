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

#import "BFFStyledTextLabel.h"

// UI
#import "BFFNavigator.h"
#import "BFFTableView.h"
#import "BFFUIViewAdditions.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFStyledText.h"
#import "BFFStyledNode.h"
#import "BFFStyleSheet.h"
#import "BFFStyledElement.h"
#import "BFFStyledLinkNode.h"
#import "BFFStyledButtonNode.h"
#import "BFFStyledTextNode.h"

// - Styled frames
#import "BFFStyledInlineFrame.h"
#import "BFFStyledTextFrame.h"

// Core
#import "BFFCorePreprocessorMacros.h"
#import "BFFDebug.h"

static const CGFloat kCancelHighlightThreshold = 4;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFStyledTextLabel

@synthesize text                  = _text;
@synthesize textColor             = _textColor;
@synthesize highlightedTextColor  = _highlightedTextColor;
@synthesize font                  = _font;
@synthesize textAlignment         = _textAlignment;
@synthesize contentInset          = _contentInset;
@synthesize highlighted           = _highlighted;
@synthesize highlightedNode       = _highlightedNode;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _textAlignment  = UITextAlignmentLeft;
    _contentInset   = UIEdgeInsetsZero;

    self.font = BFFSTYLEVAR(font);
    self.backgroundColor = BFFSTYLEVAR(backgroundColor);
    self.contentMode = UIViewContentModeRedraw;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  _text.delegate = nil;
  BFF_RELEASE_SAFELY(_text);
  BFF_RELEASE_SAFELY(_font);
  BFF_RELEASE_SAFELY(_textColor);
  BFF_RELEASE_SAFELY(_highlightedTextColor);
  BFF_RELEASE_SAFELY(_highlightedNode);
  BFF_RELEASE_SAFELY(_highlightedFrame);
  BFF_RELEASE_SAFELY(_accessibilityElements);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
// UITableView looks for this function and crashes if it is not found when you select a cell
- (BOOL)isHighlighted {
  return _highlighted;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStyle:(BFFStyle*)style forFrame:(BFFStyledBoxFrame*)frame {
  if ([frame isKindOfClass:[BFFStyledInlineFrame class]]) {
    BFFStyledInlineFrame* inlineFrame = (BFFStyledInlineFrame*)frame;
    while (inlineFrame.inlinePreviousFrame) {
      inlineFrame = inlineFrame.inlinePreviousFrame;
    }
    while (inlineFrame) {
      inlineFrame.style = style;
      inlineFrame = inlineFrame.inlineNextFrame;
    }
  } else {
    frame.style = style;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlightedFrame:(BFFStyledBoxFrame*)frame{
  if (frame != _highlightedFrame) {
    BFFTableView* tableView = (BFFTableView*)[self ancestorOrSelfWithClass:[BFFTableView class]];

    BFFStyledBoxFrame* affectFrame = frame ? frame : _highlightedFrame;
    NSString* className = affectFrame.element.className;
    if (!className && [affectFrame.element isKindOfClass:[BFFStyledLinkNode class]]) {
      className = @"linkText:";
    }

    if (className && [className rangeOfString:@":"].location != NSNotFound) {
      if (frame) {
        BFFStyle* style = [BFFSTYLESHEET styleWithSelector:className
                                       forState:UIControlStateHighlighted];
        [self setStyle:style forFrame:frame];

        [_highlightedFrame release];
        _highlightedFrame = [frame retain];
        [_highlightedNode release];
        _highlightedNode = [frame.element retain];
        tableView.highlightedLabel = self;
      } else {
        BFFStyle* style = [BFFSTYLESHEET styleWithSelector:className forState:UIControlStateNormal];
        [self setStyle:style forFrame:_highlightedFrame];

        BFF_RELEASE_SAFELY(_highlightedFrame);
        BFF_RELEASE_SAFELY(_highlightedNode);
        tableView.highlightedLabel = nil;
      }

      [self setNeedsDisplay];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)combineTextFromFrame:(BFFStyledTextFrame*)fromFrame toFrame:(BFFStyledTextFrame*)toFrame {
  NSMutableArray* strings = [NSMutableArray array];
  for (BFFStyledTextFrame* frame = fromFrame; frame && frame != toFrame;
       frame = (BFFStyledTextFrame*)frame.nextFrame) {
    [strings addObject:frame.text];
  }
  return [strings componentsJoinedByString:@""];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addAccessibilityElementFromFrame:(BFFStyledTextFrame*)fromFrame
        toFrame:(BFFStyledTextFrame*)toFrame withEdges:(UIEdgeInsets)edges {
  CGRect rect = CGRectMake(edges.left, edges.top,
                           edges.right-edges.left, edges.bottom-edges.top);

  UIAccessibilityElement* acc = [[[UIAccessibilityElement alloc]
                                initWithAccessibilityContainer:self] autorelease];
  acc.accessibilityFrame = CGRectOffset(rect, self.screenViewX, self.screenViewY);
  acc.accessibilityTraits = UIAccessibilityTraitStaticText;
  if (fromFrame == toFrame) {
    acc.accessibilityLabel = fromFrame.text;
  } else {
    acc.accessibilityLabel = [self combineTextFromFrame:fromFrame toFrame:toFrame];
  }
  [_accessibilityElements addObject:acc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)edgesForRect:(CGRect)rect {
  return UIEdgeInsetsMake(rect.origin.y, rect.origin.x,
                          rect.origin.y+rect.size.height,
                          rect.origin.x+rect.size.width);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addAccessibilityElementsForNode:(BFFStyledNode*)node {
  if ([node isKindOfClass:[BFFStyledLinkNode class]]) {
    UIAccessibilityElement* acc = [[[UIAccessibilityElement alloc]
                                  initWithAccessibilityContainer:self] autorelease];
    BFFStyledFrame* frame = [_text getFrameForNode:node];
    acc.accessibilityFrame = CGRectOffset(frame.bounds, self.screenViewX, self.screenViewY);
    acc.accessibilityTraits = UIAccessibilityTraitLink;
    acc.accessibilityLabel = [node outerText];
    [_accessibilityElements addObject:acc];
  } else if ([node isKindOfClass:[BFFStyledTextNode class]]) {
    BFFStyledTextFrame* startFrame = (BFFStyledTextFrame*)[_text getFrameForNode:node];
    UIEdgeInsets edges = [self edgesForRect:startFrame.bounds];

    BFFStyledTextFrame* frame = (BFFStyledTextFrame*)startFrame.nextFrame;
    for (; [frame isKindOfClass:[BFFStyledTextFrame class]]; frame = (BFFStyledTextFrame*)frame.nextFrame) {
      if (frame.bounds.origin.x < edges.left) {
        [self addAccessibilityElementFromFrame:startFrame toFrame:frame withEdges:edges];
        edges = [self edgesForRect:frame.bounds];
        startFrame = frame;
      } else {
        if (frame.bounds.origin.x+frame.bounds.size.width > edges.right) {
          edges.right = frame.bounds.origin.x+frame.bounds.size.width;
        }
        if (frame.bounds.origin.y+frame.bounds.size.height > edges.bottom) {
          edges.bottom = frame.bounds.origin.y+frame.bounds.size.height;
        }
      }
    }

    if (frame != startFrame) {
      [self addAccessibilityElementFromFrame:startFrame toFrame:frame withEdges:edges];
    }
  } else if ([node isKindOfClass:[BFFStyledElement class]]) {
    BFFStyledElement* element = (BFFStyledElement*)node;
    for (BFFStyledNode* child = element.firstChild; child; child = child.nextSibling) {
      [self addAccessibilityElementsForNode:child];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)accessibilityElements {
  if (!_accessibilityElements) {
    _accessibilityElements = [[NSMutableArray alloc] init];
    [self addAccessibilityElementsForNode:_text.rootNode];
  }
  return _accessibilityElements;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponder

/*
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBecomeFirstResponder {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)becomeFirstResponder {
  BOOL became = [super becomeFirstResponder];

  UIMenuController* menu = [UIMenuController sharedMenuController];
  [menu setTargetRect:self.frame inView:self.superview];
  [menu setMenuVisible:YES animated:YES];

  self.highlighted = YES;
  return became;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)resignFirstResponder {
  self.highlighted = NO;
  BOOL resigned = [super resignFirstResponder];
  [[UIMenuController sharedMenuController] setMenuVisible:NO];
  return resigned;
}
*/


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  UITouch* touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  point.x -= _contentInset.left;
  point.y -= _contentInset.top;

  BFFStyledBoxFrame* frame = [_text hitTest:point];
  if (frame) {
    [self setHighlightedFrame:frame];
  }

  //[self performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5];

  [super touchesBegan:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesMoved:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
  BFFTableView* tableView = (BFFTableView*)[self ancestorOrSelfWithClass:[BFFTableView class]];
  if (!tableView) {
    if (_highlightedNode) {
      // This is a dirty hack to decouple the UI from Style. BFFOpenURL was originally within
      // the node implementation. One potential fix would be to provide some protocol for these
      // nodes to converse with.
      if ([_highlightedNode isKindOfClass:[BFFStyledLinkNode class]]) {
        BFFOpenURL([(BFFStyledLinkNode*)_highlightedNode URL]);

      } else if ([_highlightedNode isKindOfClass:[BFFStyledButtonNode class]]) {
        BFFOpenURL([(BFFStyledButtonNode*)_highlightedNode URL]);

      } else {
        [_highlightedNode performDefaultAction];
      }
      [self setHighlightedFrame:nil];
    }
  }

  // We definitely don't want to call this if the label is inside a BFFTableView, because
  // it winds up calling touchesEnded on the table twice, triggering the link twice
  [super touchesEnded:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesCancelled:touches withEvent:event];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
  if (_highlighted) {
    [self.highlightedTextColor setFill];
  } else {
    [self.textColor setFill];
  }

  CGPoint origin = CGPointMake(rect.origin.x + _contentInset.left,
                               rect.origin.y + _contentInset.top);
  [_text drawAtPoint:origin highlighted:_highlighted];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
  [super layoutSubviews];
  CGFloat newWidth = self.width - (_contentInset.left + _contentInset.right);
  if (newWidth != _text.width) {
    // Remove the highlighted node+frame when resizing the text
    self.highlightedNode = nil;
  }

  _text.width = newWidth;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)sizeThatFits:(CGSize)size {
  [self layoutIfNeeded];
  return CGSizeMake(_text.width + (_contentInset.left + _contentInset.right),
                    _text.height+ (_contentInset.top + _contentInset.bottom));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAccessibilityContainer


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)accessibilityElementAtIndex:(NSInteger)elementIndex {
  return [[self accessibilityElements] objectAtIndex:elementIndex];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)accessibilityElementCount {
  return [self accessibilityElements].count;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)indexOfAccessibilityElement:(id)element {
  return [[self accessibilityElements] indexOfObject:element];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIResponderStandardEditActions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)copy:(id)sender {
  NSString* text = _text.rootNode.outerText;
  UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
  [pasteboard setValue:text forPasteboardType:@"public.utf8-plain-text"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFStyledTextDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)styledTextNeedsDisplay:(BFFStyledText*)text {
  [self setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setText:(BFFStyledText*)text {
  if (text != _text) {
    _text.delegate = nil;
    [_text release];
    BFF_RELEASE_SAFELY(_accessibilityElements);
    _text = [text retain];
    _text.delegate = self;
    _text.font = _font;
    [self setNeedsLayout];
    [self setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)html {
  return [_text description];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHtml:(NSString*)html {
  self.text = [BFFStyledText textFromXHTML:html];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    _text.font = _font;
    [self setNeedsLayout];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)textColor {
  if (!_textColor) {
    _textColor = [BFFSTYLEVAR(textColor) retain];
  }
  return _textColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTextColor:(UIColor*)textColor {
  if (textColor != _textColor) {
    [_textColor release];
    _textColor = [textColor retain];
    [self setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)highlightedTextColor {
  if (!_highlightedTextColor) {
    _highlightedTextColor = [BFFSTYLEVAR(highlightedTextColor) retain];
  }
  return _highlightedTextColor;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHighlightedNode:(BFFStyledElement*)node {
  if (node != _highlightedNode) {
    if (!node) {
      [self setHighlightedFrame:nil];
    } else {
      [_highlightedNode release];
      _highlightedNode = [node retain];
    }
  }
}


@end
