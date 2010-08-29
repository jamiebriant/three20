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
#import "BFFStyledNode.h"

@interface BFFStyledElement : BFFStyledNode {
  BFFStyledNode* _firstChild;
  BFFStyledNode* _lastChild;
  NSString*     _className;
}

@property (nonatomic, readonly) BFFStyledNode* firstChild;
@property (nonatomic, readonly) BFFStyledNode* lastChild;
@property (nonatomic, retain)   NSString*     className;

- (id)initWithText:(NSString*)text;

// Designated initializer
- (id)initWithText:(NSString*)text next:(BFFStyledNode*)nextSibling;

- (void)addChild:(BFFStyledNode*)child;
- (void)addText:(NSString*)text;
- (void)replaceChild:(BFFStyledNode*)oldChild withChild:(BFFStyledNode*)newChild;

- (BFFStyledNode*)getElementByClassName:(NSString*)className;

@end
