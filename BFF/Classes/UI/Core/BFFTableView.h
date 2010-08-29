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
#import <QuartzCore/QuartzCore.h>

@class BFFStyledTextLabel;

/**
 * BFFTableView enhances UITableView to provide support for various Three20 services.
 *
 * If you are using BFFStyledTextLabels in your table cells, you need to use BFFTableView if
 * you want links in your labels to be touchable.
 */
@interface BFFTableView : UITableView {
  BFFStyledTextLabel*  _highlightedLabel;
  CGPoint             _highlightStartPoint;
  CGFloat             _contentOrigin;

  BOOL _showShadows;

  CAGradientLayer* _originShadow;
  CAGradientLayer* _topShadow;
  CAGradientLayer* _bottomShadow;
}

@property (nonatomic, retain) BFFStyledTextLabel*  highlightedLabel;
@property (nonatomic)         CGFloat             contentOrigin;
@property (nonatomic)         BOOL                showShadows;

@end

@protocol BFFTableViewDelegate <UITableViewDelegate>

- (void)tableView:(UITableView*)tableView touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)tableView:(UITableView*)tableView touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;

@end
