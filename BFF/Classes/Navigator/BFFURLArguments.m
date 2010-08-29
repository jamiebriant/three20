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

#import "BFFURLArguments.h"

#import <objc/runtime.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
BFFURLArgumentType BFFConvertArgumentType(char argType) {
  if (argType == 'c'
      || argType == 'i'
      || argType == 's'
      || argType == 'l'
      || argType == 'C'
      || argType == 'I'
      || argType == 'S'
      || argType == 'L') {
    return BFFURLArgumentTypeInteger;
  } else if (argType == 'q' || argType == 'Q') {
    return BFFURLArgumentTypeLongLong;
  } else if (argType == 'f') {
    return BFFURLArgumentTypeFloat;
  } else if (argType == 'd') {
    return BFFURLArgumentTypeDouble;
  } else if (argType == 'B') {
    return BFFURLArgumentTypeBool;
  } else {
    return BFFURLArgumentTypePointer;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BFFURLArgumentType BFFURLArgumentTypeForProperty(Class cls, NSString* propertyName) {
  objc_property_t prop = class_getProperty(cls, propertyName.UTF8String);
  if (prop) {
    const char* type = property_getAttributes(prop);
    return BFFConvertArgumentType(type[1]);
  } else {
    return BFFURLArgumentTypeNone;
  }
}
