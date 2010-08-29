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

@class BFFShape;
@protocol BFFStyleDelegate;

@interface BFFStyleContext : NSObject {
  CGRect    _frame;
  CGRect    _contentFrame;

  BFFShape*  _shape;

  UIFont*   _font;

  BOOL      _didDrawContent;

  id<BFFStyleDelegate> _delegate;
}

@property (nonatomic)         CGRect    frame;
@property (nonatomic)         CGRect    contentFrame;
@property (nonatomic, retain) BFFShape*  shape;
@property (nonatomic, retain) UIFont*   font;
@property (nonatomic)         BOOL      didDrawContent;

@property (nonatomic, assign) id<BFFStyleDelegate> delegate;

@end
