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

// Style
#import "BFFStyle.h"
#import "BFFPosition.h"

@interface BFFBoxStyle : BFFStyle {
  UIEdgeInsets  _margin;
  UIEdgeInsets  _padding;
  CGSize        _minSize;
  BFFPosition    _position;
}

@property (nonatomic) UIEdgeInsets  margin;
@property (nonatomic) UIEdgeInsets  padding;
@property (nonatomic) CGSize        minSize;
@property (nonatomic) BFFPosition    position;

+ (BFFBoxStyle*)styleWithMargin:(UIEdgeInsets)margin next:(BFFStyle*)next;
+ (BFFBoxStyle*)styleWithPadding:(UIEdgeInsets)padding next:(BFFStyle*)next;
+ (BFFBoxStyle*)styleWithFloats:(BFFPosition)position next:(BFFStyle*)next;
+ (BFFBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                          next:(BFFStyle*)next;
+ (BFFBoxStyle*)styleWithMargin:(UIEdgeInsets)margin padding:(UIEdgeInsets)padding
                       minSize:(CGSize)minSize position:(BFFPosition)position next:(BFFStyle*)next;

@end
