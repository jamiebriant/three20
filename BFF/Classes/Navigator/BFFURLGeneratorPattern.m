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

#import "BFFURLGeneratorPattern.h"

// UI (private)
#import "BFFURLWildcard.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFURLGeneratorPattern

@synthesize targetClass = _targetClass;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTargetClass:(id)targetClass {
  if (self = [super init]) {
    _targetClass = targetClass;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithTargetClass:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFURLPattern


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)classForInvocation {
  return _targetClass;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)compile {
  [self compileURL];

  for (id<BFFURLPatternText> pattern in _path) {
    if ([pattern isKindOfClass:[BFFURLWildcard class]]) {
      BFFURLWildcard* wildcard = (BFFURLWildcard*)pattern;
      [wildcard deduceSelectorForClass:_targetClass];
    }
  }

  for (id<BFFURLPatternText> pattern in [_query objectEnumerator]) {
    if ([pattern isKindOfClass:[BFFURLWildcard class]]) {
      BFFURLWildcard* wildcard = (BFFURLWildcard*)pattern;
      [wildcard deduceSelectorForClass:_targetClass];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)generateURLFromObject:(id)object {
  NSMutableArray* paths = [NSMutableArray array];
  NSMutableArray* queries = nil;
  [paths addObject:[NSString stringWithFormat:@"%@:/", _scheme]];

  for (id<BFFURLPatternText> patternText in _path) {
    NSString* value = [patternText convertPropertyOfObject:object];
    [paths addObject:value];
  }

  for (NSString* name in [_query keyEnumerator]) {
    id<BFFURLPatternText> patternText = [_query objectForKey:name];
    NSString* value = [patternText convertPropertyOfObject:object];
    NSString* pair = [NSString stringWithFormat:@"%@=%@", name, value];
    if (!queries) {
      queries = [NSMutableArray array];
    }
    [queries addObject:pair];
  }

  NSString* path = [paths componentsJoinedByString:@"/"];
  if (queries) {
    NSString* query = [queries componentsJoinedByString:@"&"];
    return [path stringByAppendingFormat:@"?%@", query];
  } else {
    return path;
  }
}


@end
