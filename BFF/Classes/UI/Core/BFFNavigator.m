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

#import "BFFNavigator.h"

// UI
#import "BFFPopupViewController.h"
#import "BFFSearchDisplayController.h"
#import "BFFTableViewController.h"
#import "BFFNavigationController.h"

// UI (private)
#import "BFFNavigatorWindow.h"

// UINavigator
#import "BFFURLMap.h"
#import "BFFURLAction.h"

// UINavigator (private)
#import "BFFBaseNavigatorInternal.h"

// UICommon
#import "BFFUIViewControllerAdditions.h"

// Core
#import "BFFDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
UIViewController* BFFOpenURL(NSString* URL) {
  return [[BFFNavigator navigator] openURLAction:
          [[BFFURLAction actionWithURLPath:URL]
           applyAnimated:YES]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFNavigator


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFNavigator*)navigator {
  BFFBaseNavigator* navigator = [BFFBaseNavigator globalNavigator];
  if (nil == navigator) {
    navigator = [[BFFNavigator alloc] init];
    // setNavigator: retains.
    [super setGlobalNavigator:navigator];
    [navigator release];
  }
  // If this asserts, it's likely that you're attempting to use two different navigator
  // implementations simultaneously. Be consistent!
  BFFDASSERT([navigator isKindOfClass:[BFFNavigator class]]);
  return (BFFNavigator*)navigator;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)windowClass {
  return [BFFNavigatorWindow class];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * A popup controller is a view controller that is presented over another controller, but doesn't
 * necessarily completely hide the original controller (like a modal controller would). A classic
 * example is a status indicator while something is loading.
 *
 * @private
 */
- (void)presentPopupController: (BFFPopupViewController*)controller
              parentController: (UIViewController*)parentController
                      animated: (BOOL)animated {
  parentController.popupViewController = controller;
  controller.superController = parentController;
  [controller showInView: parentController.view
                animated: animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Present a view controller that strictly depends on the existence of the parent controller.
 *
 * @protected
 */
- (void)presentDependantController: (UIViewController*)controller
                  parentController: (UIViewController*)parentController
                              mode: (BFFNavigationMode)mode
                          animated: (BOOL)animated
                        transition: (NSInteger)transition {

  if ([controller isKindOfClass:[BFFPopupViewController class]]) {
    BFFPopupViewController* popupViewController = (BFFPopupViewController*)controller;
    [self presentPopupController: popupViewController
                parentController: parentController
                        animated: animated];

  } else {
    [super presentDependantController: controller
                     parentController: parentController
                                 mode: mode
                             animated: animated
                           transition: transition];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @protected
 */
- (void)didRestoreController:(UIViewController*)controller {
  if ([controller isKindOfClass:[BFFModelViewController class]]) {
    BFFModelViewController* modelViewController = (BFFModelViewController*)controller;
    modelViewController.model;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @protected
 */
- (UIViewController*)getVisibleChildController:(UIViewController*)controller {
  UISearchDisplayController* search = controller.searchDisplayController;
  if (search && search.active && [search isKindOfClass:[BFFSearchDisplayController class]]) {
    BFFSearchDisplayController* ttsearch = (BFFSearchDisplayController*)search;
    return ttsearch.searchResultsViewController;

  } else {
    return [super getVisibleChildController:controller];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  UIViewController* controller = self.visibleViewController;
  if ([controller isKindOfClass:[BFFModelViewController class]]) {
    BFFModelViewController* ttcontroller = (BFFModelViewController*)controller;
    [ttcontroller reload];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)navigationControllerClass {
  return [BFFNavigationController class];
}


@end
