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

#import "BFFInsetStyle.h"

// Style
#import "BFFStyleContext.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFInsetStyle

@synthesize inset = _inset;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(BFFStyle*)next {
  if (self = [super initWithNext:next]) {
    _inset = UIEdgeInsetsZero;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFInsetStyle*)styleWithInset:(UIEdgeInsets)inset next:(BFFStyle*)next {
  BFFInsetStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.inset = inset;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(BFFStyleContext*)context {
  CGRect rect = context.frame;
  context.frame = CGRectMake(rect.origin.x+_inset.left, rect.origin.y+_inset.top,
                             rect.size.width - (_inset.left + _inset.right),
                             rect.size.height - (_inset.top + _inset.bottom));
  [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIEdgeInsets)addToInsets:(UIEdgeInsets)insets forSize:(CGSize)size {
  insets.top += _inset.top;
  insets.right += _inset.right;
  insets.bottom += _inset.bottom;
  insets.left += _inset.left;
  if (self.next) {
    return [self.next addToInsets:insets forSize:size];
  } else {
    return insets;
  }
}


@end
