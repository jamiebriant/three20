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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BFFScrollView;

@protocol BFFScrollViewDelegate <NSObject>

@required

- (void)scrollView:(BFFScrollView*)scrollView didMoveToPageAtIndex:(NSInteger)pageIndex;

@optional

- (void)scrollViewWillRotate: (BFFScrollView*)scrollView
               toOrientation: (UIInterfaceOrientation)orientation;

- (void)scrollViewDidRotate:(BFFScrollView*)scrollView;

- (void)scrollViewWillBeginDragging:(BFFScrollView*)scrollView;

- (void)scrollViewDidEndDragging:(BFFScrollView*)scrollView willDecelerate:(BOOL)willDecelerate;

- (void)scrollViewDidEndDecelerating:(BFFScrollView*)scrollView;

- (BOOL)scrollViewShouldZoom:(BFFScrollView*)scrollView;

- (void)scrollViewDidBeginZooming:(BFFScrollView*)scrollView;

- (void)scrollViewDidEndZooming:(BFFScrollView*)scrollView;

- (void)scrollView:(BFFScrollView*)scrollView touchedDown:(UITouch*)touch;

- (void)scrollView:(BFFScrollView*)scrollView touchedUpInside:(UITouch*)touch;

- (void)scrollView:(BFFScrollView*)scrollView tapped:(UITouch*)touch;

- (void)scrollViewDidBeginHolding:(BFFScrollView*)scrollView;

- (void)scrollViewDidEndHolding:(BFFScrollView*)scrollView;

- (BOOL)scrollView:(BFFScrollView*)scrollView
  shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end
