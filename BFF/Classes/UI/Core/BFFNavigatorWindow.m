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

#import "BFFNavigatorWindow.h"

// UI
#import "BFFNavigator.h"

// Core
#import "BFFDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFNavigatorWindow


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if (event.type == UIEventSubtypeMotionShake
      && [BFFNavigator navigator].supportsShakeToReload) {
    // If you're going to use a custom navigator implementation, you need to ensure that you
    // implement the reload method. If you're inheriting from BFFNavigator, then you're fine.
    BFFDASSERT([[BFFNavigator navigator] respondsToSelector:@selector(reload)]);
    [(BFFNavigator*)[BFFNavigator navigator] reload];
  }
}


@end
