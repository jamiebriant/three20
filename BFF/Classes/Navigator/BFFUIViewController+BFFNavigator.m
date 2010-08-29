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

#import "BFFUIViewController+BFFNavigator.h"

// UINavigator
#import "BFFBaseNavigator.h"
#import "BFFURLMap.h"
#import "BFFNavigatorViewController.h"

// UICommon
#import "BFFUIViewControllerAdditions.h"

// UICommon (private)
#import "BFFUIViewControllerGarbageCollection.h"

// Core
#import "BFFCorePreprocessorMacros.h"
#import "BFFDebug.h"
#import "BFFDebugFlags.h"

static NSMutableDictionary* gNavigatorURLs          = nil;

static NSMutableSet*        gsNavigatorControllers  = nil;
static NSTimer*             gsGarbageCollectorTimer = nil;

static const NSTimeInterval kGarbageCollectionInterval = 20;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewController (BFFNavigator)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [self init]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Garbage Collection


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSMutableSet*)ttNavigatorControllers {
  if (nil == gsNavigatorControllers) {
    gsNavigatorControllers = [[NSMutableSet alloc] init];
  }
  return gsNavigatorControllers;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)doNavigatorGarbageCollection {
  NSMutableSet* controllers = [UIViewController ttNavigatorControllers];

  [self doGarbageCollectionWithSelector: @selector(unsetNavigatorProperties)
                          controllerSet: controllers];

  if ([controllers count] == 0) {
    BFFDCONDITIONLOG(BFFDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Killing the navigator garbage collector.");
    [gsGarbageCollectorTimer invalidate];
    BFF_RELEASE_SAFELY(gsGarbageCollectorTimer);
    BFF_RELEASE_SAFELY(gsNavigatorControllers);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)ttAddNavigatorController:(UIViewController*)controller {

  // BFFNavigatorViewController calls unsetNavigatorProperties in its dealloc.
  // UICommon has its own garbage collector that will unset another set of properties.
  if (![controller isKindOfClass:[BFFNavigatorViewController class]]) {

    BFFDCONDITIONLOG(BFFDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Adding a navigator controller.");

    [[UIViewController ttNavigatorControllers] addObject:controller];

    if (nil == gsGarbageCollectorTimer) {
      gsGarbageCollectorTimer =
        [[NSTimer scheduledTimerWithTimeInterval: kGarbageCollectionInterval
                                          target: [UIViewController class]
                                        selector: @selector(doNavigatorGarbageCollection)
                                        userInfo: nil
                                         repeats: YES] retain];
    }
#if BFFDFLAG_CONTROLLERGARBAGECOLLECTION
  } else {
    BFFDCONDITIONLOG(BFFDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Not adding a navigator controller.");
#endif
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)navigatorURL {
  return self.originalNavigatorURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)originalNavigatorURL {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  return [gNavigatorURLs objectForKey:key];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOriginalNavigatorURL:(NSString*)URL {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (nil != URL) {
    if (nil == gNavigatorURLs) {
      gNavigatorURLs = [[NSMutableDictionary alloc] init];
    }
    [gNavigatorURLs setObject:URL forKey:key];

    [UIViewController ttAddNavigatorController:self];

  } else {
    [gNavigatorURLs removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)frozenState {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrozenState:(NSDictionary*)frozenState {
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewController (BFFNavigatorGarbageCollection)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unsetNavigatorProperties {
  BFFDCONDITIONLOG(BFFDFLAG_CONTROLLERGARBAGECOLLECTION,
                  @"Unsetting this controller's properties: %X", self);

  NSString* urlPath = self.originalNavigatorURL;
  if (nil != urlPath) {
    BFFDCONDITIONLOG(BFFDFLAG_CONTROLLERGARBAGECOLLECTION,
                    @"Removing this URL path: %@", urlPath);

    [[BFFBaseNavigator globalNavigator].URLMap removeObjectForURL:urlPath];
    self.originalNavigatorURL = nil;
  }
}


@end

#import "BFFCategoryFix.h"
FIX_CATEGORY_BUG(UIViewControllerTTNavigator)

