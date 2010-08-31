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

// UINavigator (private)
#import "BFFURLPatternText.h"
#import "BFFURLArgumentType.h"

@class BFFURLSelector;

@interface BFFURLWildcard : NSObject <BFFURLPatternText> {
  NSString*         _name;
  NSInteger         _argIndex;
  BFFURLArgumentType _argType;
  BFFURLSelector*    _selector;
}

@property (nonatomic, copy)   NSString*         name;
@property (nonatomic)         NSInteger         argIndex;
@property (nonatomic)         BFFURLArgumentType argType;
@property (nonatomic, retain) BFFURLSelector*    selector;

- (void)deduceSelectorForClass:(Class)cls;

@end