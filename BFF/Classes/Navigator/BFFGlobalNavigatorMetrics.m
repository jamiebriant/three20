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

#import "BFFGlobalNavigatorMetrics.h"

// UINavigator
#import "BFFBaseNavigator.h"

// UICommon
#import "BFFGlobalUICommon.h"

// Core
#import "BFFGlobalCoreRects.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
UIInterfaceOrientation BFFInterfaceOrientation() {
  UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
  if (UIDeviceOrientationUnknown == orient) {
    return [BFFBaseNavigator globalNavigator].visibleViewController.interfaceOrientation;
  } else {
    return orient;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect BFFScreenBounds() {
  CGRect bounds = [UIScreen mainScreen].bounds;
  if (UIInterfaceOrientationIsLandscape(BFFInterfaceOrientation())) {
    CGFloat width = bounds.size.width;
    bounds.size.width = bounds.size.height;
    bounds.size.height = width;
  }
  return bounds;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect BFFNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - BFFToolbarHeight());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect BFFToolbarNavigationFrame() {
  CGRect frame = [UIScreen mainScreen].applicationFrame;
  return CGRectMake(0, 0, frame.size.width, frame.size.height - BFFToolbarHeight()*2);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGRect BFFKeyboardNavigationFrame() {
  return BFFRectContract(BFFNavigationFrame(), 0, BFFKeyboardHeight());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat BFFStatusHeight() {
  UIInterfaceOrientation orientation = BFFInterfaceOrientation();
  if (orientation == UIInterfaceOrientationLandscapeLeft) {
    return [UIScreen mainScreen].applicationFrame.origin.x;
  } else if (orientation == UIInterfaceOrientationLandscapeRight) {
    return -[UIScreen mainScreen].applicationFrame.origin.x;
  } else {
    return [UIScreen mainScreen].applicationFrame.origin.y;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat BFFBarsHeight() {
  CGRect frame = [UIApplication sharedApplication].statusBarFrame;
  if (UIInterfaceOrientationIsPortrait(BFFInterfaceOrientation())) {
    return frame.size.height + BFF_ROW_HEIGHT;
  } else {
    return frame.size.width + BFF_LANDSCAPE_TOOLBAR_HEIGHT;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat BFFToolbarHeight() {
  return BFFToolbarHeightForOrientation(BFFInterfaceOrientation());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat BFFKeyboardHeight() {
  return BFFKeyboardHeightForOrientation(BFFInterfaceOrientation());
}
