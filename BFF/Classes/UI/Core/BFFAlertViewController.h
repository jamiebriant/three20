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

// UI
#import "BFFPopupViewController.h"

@protocol BFFAlertViewControllerDelegate;

/**
 * A view controller that displays an alert view.
 *
 * This class exists in order to allow alert views to be displayed by BFFNavigator and gain
 * all the benefits of persistence and URL dispatch.
 */
@interface BFFAlertViewController : BFFPopupViewController <UIAlertViewDelegate> {
@protected
  id              _userInfo;
  NSMutableArray* _URLs;

  id<BFFAlertViewControllerDelegate> _delegate;
}

@property (nonatomic, readonly) UIAlertView*  alertView;
@property (nonatomic, retain)   id            userInfo;

@property (nonatomic, assign)   id<BFFAlertViewControllerDelegate> delegate;


- (id)initWithTitle:(NSString*)title message:(NSString*)message;
- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate;

- (NSInteger)addButtonWithTitle:(NSString*)title URL:(NSString*)URL;
- (NSInteger)addCancelButtonWithTitle:(NSString*)title URL:(NSString*)URL;

- (NSString*)buttonURLAtIndex:(NSInteger)index;

@end
