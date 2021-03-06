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
#import "BFFView.h"

@protocol BFFTextEditorDelegate;
@class BFFTextView;
@class BFFTextEditorInternal;


@interface BFFTextEditor : BFFView <UITextInputTraits> {
  BFFTextEditorInternal* _internal;
  UITextField*          _textField;
  BFFTextView*           _textView;

  NSInteger _minNumberOfLines;
  NSInteger _maxNumberOfLines;

  BOOL _editing;
  BOOL _overflowed;
  BOOL _autoresizesToText;
  BOOL _showsExtraLine;
  BOOL _forceTextView; // JAB Yes, this is an awful hack.

  id<BFFTextEditorDelegate> _delegate;
}

@property (nonatomic, copy)     NSString* text;
@property (nonatomic, copy)     NSString* placeholder;
@property (nonatomic, retain)   UIFont*   font;
@property (nonatomic, retain)   UIColor*  textColor;

@property (nonatomic)           NSInteger minNumberOfLines;
@property (nonatomic)           NSInteger maxNumberOfLines;

@property (nonatomic, readonly) BOOL editing;
@property (nonatomic)           BOOL autoresizesToText;
@property (nonatomic)           BOOL showsExtraLine;
@property (nonatomic)			BOOL forceTextView; // JAB

@property (nonatomic, assign) id<BFFTextEditorDelegate> delegate;

- (void)scrollContainerToCursor:(UIScrollView*)scrollView;

@end
