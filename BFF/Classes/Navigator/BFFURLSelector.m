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

#import "BFFURLSelector.h"

// UINavigator (private)
#import "BFFURLArguments.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFURLSelector

@synthesize name = _name;
@synthesize next = _next;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithName:(NSString*)name {
  if (self = [super init]) {
    _name     = [name copy];
    _selector = NSSelectorFromString(_name);
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_name);
  BFF_RELEASE_SAFELY(_next);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)perform:(id)object returnType:(BFFURLArgumentType)returnType {
  if (_next) {
    id value = [object performSelector:_selector];
    return [_next perform:value returnType:returnType];
  } else {
    NSMethodSignature *sig = [object methodSignatureForSelector:_selector];
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:object];
    [invocation setSelector:_selector];
    [invocation invoke];

    if (!returnType) {
      returnType = BFFURLArgumentTypeForProperty([object class], _name);
    }

    switch (returnType) {
      case BFFURLArgumentTypeNone: {
        return @"";
      }
      case BFFURLArgumentTypeInteger: {
        int val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%d", val];
      }
      case BFFURLArgumentTypeLongLong: {
        long long val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%lld", val];
      }
      case BFFURLArgumentTypeFloat: {
        float val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%f", val];
      }
      case BFFURLArgumentTypeDouble: {
        double val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%f", val];
      }
      case BFFURLArgumentTypeBool: {
        BOOL val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%d", val];
      }
      default: {
        id val;
        [invocation getReturnValue:&val];
        return [NSString stringWithFormat:@"%@", val];
      }
    }
    return @"";
  }
}


@end
