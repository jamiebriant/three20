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

// Style
#import "BFFStyledFrame.h"
#import "BFFStyleDelegate.h"

@class BFFStyledImageNode;

@interface BFFStyledImageFrame : BFFStyledFrame <BFFStyleDelegate> {
  BFFStyledImageNode*  _imageNode;
  BFFStyle*            _style;
}

/**
 * The node represented by the frame.
 */
@property (nonatomic, readonly) BFFStyledImageNode* imageNode;

/**
 * The style used to render the frame;
 */
@property (nonatomic, retain) BFFStyle* style;

- (id)initWithElement:(BFFStyledElement*)element node:(BFFStyledImageNode*)node;

@end
