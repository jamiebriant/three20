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

#import "BFFPostController.h"

// UI
#import "BFFNavigator.h"
#import "BFFPostControllerDelegate.h"
#import "BFFActivityLabel.h"
#import "BFFView.h"
#import "BFFUIViewAdditions.h"

// UINavigator
#import "BFFGlobalNavigatorMetrics.h"

// UICommon
#import "BFFGlobalUICommon.h"
#import "BFFUIViewControllerAdditions.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFStyleSheet.h"

// Core
#import "BFFGlobalCoreLocale.h"
#import "BFFCorePreprocessorMacros.h"
#import "BFFNSStringAdditions.h"

static const CGFloat kMarginX = 5;
static const CGFloat kMarginY = 6;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFPostController

@synthesize result      = _result;
@synthesize textView    = _textView;
@synthesize originView  = _originView;

@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.navigationItem.leftBarButtonItem =
      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                     target: self
                                                     action: @selector(cancel)] autorelease];
    self.navigationItem.rightBarButtonItem =
      [[[UIBarButtonItem alloc] initWithTitle: BFFLocalizedString(@"Done", @"")
                                        style: UIBarButtonItemStyleDone
                                       target: self
                                       action: @selector(post)] autorelease];
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [self initWithNibName:nil bundle:nil]) {
    if (nil != query) {
      _delegate = [query objectForKey:@"delegate"];
      _defaultText = [[query objectForKey:@"text"] copy];

      self.navigationItem.title = [query objectForKey:@"title"];

      self.originView = [query objectForKey:@"__target__"];
      NSValue* originRect = [query objectForKey:@"originRect"];
      if (nil != originRect) {
        _originRect = [originRect CGRectValue];
      }
    }
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithNavigatorURL:nil query:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_result);
  BFF_RELEASE_SAFELY(_defaultText);
  BFF_RELEASE_SAFELY(_originView);
  BFF_RELEASE_SAFELY(_textView);
  BFF_RELEASE_SAFELY(_navigationBar);
  BFF_RELEASE_SAFELY(_innerView);
  BFF_RELEASE_SAFELY(_activityView);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)stripWhitespace:(NSString*)text {
  if (nil != text) {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
    return [text stringByTrimmingCharactersInSet:whitespace];

  } else {
    return @"";
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showKeyboard {
  UIApplication* app = [UIApplication sharedApplication];
  _originalStatusBarStyle = app.statusBarStyle;
  _originalStatusBarHidden = app.statusBarHidden;
  if (!_originalStatusBarHidden) {
#if __IPHONE_3_2 && __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    if (BFFOSVersion() >= 3.2) {
      [app setStatusBarHidden:NO withAnimation:YES];
    }
    else
#endif
    {
      [app setStatusBarHidden:NO animated:YES];
    }
    [app setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
  }
  [_textView becomeFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideKeyboard {
  UIApplication* app = [UIApplication sharedApplication];
#if __IPHONE_3_2 && __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
  if (BFFOSVersion() >= 3.2) {
    [app setStatusBarHidden:_originalStatusBarHidden withAnimation:YES];
  }
  else
#endif
  {
    [app setStatusBarHidden:_originalStatusBarHidden animated:YES];
  }
  [app setStatusBarStyle:_originalStatusBarStyle animated:NO];
  [_textView resignFirstResponder];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGAffineTransform)transformForOrientation {
  return BFFRotateTransformForOrientation(BFFInterfaceOrientation());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(NSString*)activityText {
  if (nil == _activityView) {
    _activityView = [[BFFActivityLabel alloc] initWithStyle:BFFActivityLabelStyleWhiteBox];
    [self.view addSubview:_activityView];
  }

  if (nil != activityText) {
    _activityView.text = activityText;
    _activityView.frame = CGRectOffset(CGRectInset(_textView.frame, 13, 13), 2, 0);
    _activityView.hidden = NO;
    _textView.hidden = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;

  } else {
    _activityView.hidden = YES;
    _textView.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutTextEditor {
  CGFloat keyboard = BFFKeyboardHeightForOrientation(BFFInterfaceOrientation());
  _screenView.frame = CGRectMake(0, _navigationBar.bottom,
                                 self.view.orientationWidth,
                                 self.view.orientationHeight - (keyboard+_navigationBar.height));

  _textView.frame = CGRectMake(kMarginX, kMarginY+_navigationBar.height,
                                 _screenView.width - kMarginX*2,
                                 _screenView.height - kMarginY*2);
  _textView.hidden = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showAnimationDidStop {
  _textView.hidden = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissAnimationDidStop {
  if ([_delegate respondsToSelector:@selector(postController:didPostText:withResult:)]) {
    [_delegate postController:self didPostText:_textView.text withResult:_result];
  }

  BFF_RELEASE_SAFELY(_originView);
  [self dismissPopupViewControllerAnimated:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fadeOut {
  _originView.hidden = NO;
  BFF_RELEASE_SAFELY(_originView);

  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(fadeAnimationDidStop)];
  [UIView setAnimationDuration:BFF_TRANSITION_DURATION];
  self.view.alpha = 0;
  [UIView commitAnimations];

  [self hideKeyboard];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)fadeAnimationDidStop {
  [self dismissPopupViewControllerAnimated:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissWithCancel {
  if ([_delegate respondsToSelector:@selector(postControllerDidCancel:)]) {
    [_delegate postControllerDidCancel:self];
  }

  [self dismissPopupViewControllerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];
  self.view.frame = [UIScreen mainScreen].applicationFrame;
  self.view.backgroundColor = [UIColor clearColor];
  self.view.autoresizesSubviews = YES;

  _innerView = [[UIView alloc] init];
  _innerView.backgroundColor = [UIColor blackColor];
  _innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  _innerView.autoresizesSubviews = YES;
  [self.view addSubview:_innerView];

  _screenView = [[BFFView alloc] init];
  _screenView.backgroundColor = [UIColor clearColor];
  _screenView.style = BFFSTYLE(postTextEditor);
  _screenView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  _screenView.autoresizesSubviews = YES;
  [self.view addSubview:_screenView];

  _textView = [[UITextView alloc] init];
  _textView.delegate = self;
  _textView.font = BFFSTYLEVAR(font);
  _textView.textColor = [UIColor blackColor];
  _textView.contentInset = UIEdgeInsetsMake(0, 4, 0, 4);
  _textView.keyboardAppearance = UIKeyboardAppearanceAlert;
  _textView.backgroundColor = [UIColor clearColor];
  [self.view addSubview:_textView];

  _navigationBar = [[UINavigationBar alloc] init];
  _navigationBar.barStyle = UIBarStyleBlackOpaque;
  _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [_navigationBar pushNavigationItem:self.navigationItem animated:NO];
  [_innerView addSubview:_navigationBar];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return BFFIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
        duration:(NSTimeInterval)duration {
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:BFF_TRANSITION_DURATION];
  self.view.transform = [self transformForOrientation];
  self.view.frame = [UIScreen mainScreen].applicationFrame;
  _innerView.frame = self.view.bounds;
  [self layoutTextEditor];
  [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)rotatingHeaderView {
  return _navigationBar;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (BFFCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  [state setObject:[NSNumber numberWithBool:YES] forKey:@"__important__"];

  NSString* delegate = [[BFFNavigator navigator] pathForObject:_delegate];
  if (delegate) {
    [state setObject:delegate forKey:@"delegate"];
  }
  [state setObject:self.textView.text forKey:@"text"];

  NSString* title = self.navigationItem.title;

  if (title) {
    [state setObject:title forKey:@"title"];
  }

  return [super persistView:state];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreView:(NSDictionary*)state {
  [super restoreView:state];
  NSString* delegate = [state objectForKey:@"delegate"];
  if (delegate) {
    _delegate = [[BFFNavigator navigator] objectForPath:delegate];
  }
  NSString* title = [state objectForKey:@"title"];
  if (title) {
    self.navigationItem.title = title;
  }
  _defaultText = [[state objectForKey:@"text"] retain];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFPopupViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showInView:(UIView*)view animated:(BOOL)animated {
  [self retain];
  UIWindow* window = view.window ? view.window : [UIApplication sharedApplication].keyWindow;

  self.view.transform = [self transformForOrientation];
  self.view.frame = [UIScreen mainScreen].applicationFrame;
  [window addSubview:self.view];

  if (_defaultText) {
    _textView.text = _defaultText;
    BFF_RELEASE_SAFELY(_defaultText);
  } else {
    _defaultText = [_textView.text retain];
  }

  _innerView.frame = self.view.bounds;
  [_navigationBar sizeToFit];
  _originView.hidden = YES;

  if (animated) {
    _innerView.alpha = 0;
    _navigationBar.alpha = 0;
    _textView.hidden = YES;

    CGRect originRect = _originRect;
    if (CGRectIsEmpty(originRect) && _originView) {
      originRect = _originView.screenFrame;
    }

    if (!CGRectIsEmpty(originRect)) {
      _screenView.frame = CGRectOffset(originRect, 0, -BFFStatusHeight());
    } else {
      [self layoutTextEditor];
      _screenView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:BFF_TRANSITION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showAnimationDidStop)];

    _navigationBar.alpha = 1;
    _innerView.alpha = 1;

    if (originRect.size.width) {
      [self layoutTextEditor];
    } else {
      _screenView.transform = CGAffineTransformIdentity;
    }

    [UIView commitAnimations];

  } else {
    _innerView.alpha = 1;
    _screenView.transform = CGAffineTransformIdentity;
    [self layoutTextEditor];
    [self showAnimationDidStop];
  }

  [self showKeyboard];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissPopupViewControllerAnimated:(BOOL)animated {
  if (animated) {
    [self fadeOut];

  } else {
    UIViewController* superController = self.superController;
    [self.view removeFromSuperview];
    [self release];
    superController.popupViewController = nil;
    [superController viewWillAppear:animated];
    [superController viewDidAppear:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIAlertViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    [self dismissWithCancel];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITextView*)textView {
  self.view;
  return _textView;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UINavigationBar*)navigatorBar {
  if (!_navigationBar) {
    self.view;
  }
  return _navigationBar;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOriginView:(UIView*)view {
  if (view != _originView) {
    [_originView release];
    _originView = [view retain];
    _originRect = CGRectZero;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)post {
  BOOL shouldDismiss = [self willPostText:_textView.text];
  if ([_delegate respondsToSelector:@selector(postController:willPostText:)]) {
    shouldDismiss = [_delegate postController:self willPostText:_textView.text];
  }

  if (shouldDismiss) {
    [self dismissWithResult:nil animated:YES];
  } else {
    [self showActivity:[self titleForActivity]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
  if (!_textView.text.isEmptyOrWhitespace
      && !(_defaultText && [_defaultText isEqualToString:_textView.text])) {
    UIAlertView* cancelAlertView = [[[UIAlertView alloc] initWithTitle:
      BFFLocalizedString(@"Cancel", @"")
      message:BFFLocalizedString(@"Are you sure you want to cancel?", @"")
      delegate:self cancelButtonTitle:BFFLocalizedString(@"Yes", @"")
      otherButtonTitles:BFFLocalizedString(@"No", @""), nil] autorelease];
    [cancelAlertView show];
  } else {
    [self dismissWithCancel];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissWithResult:(id)result animated:(BOOL)animated {
  [_result release];
  _result = [result retain];

  if (animated) {
    if ([_delegate respondsToSelector:@selector(postController:willAnimateTowards:)]) {
      CGRect rect = [_delegate postController:self willAnimateTowards:_originRect];
      if (!CGRectIsEmpty(rect)) {
        _originRect = rect;
      }
    }

    CGRect originRect = _originRect;
    if (CGRectIsEmpty(originRect) && _originView) {
      originRect = _originView.screenFrame;
    }

    _originView.hidden = NO;
    _activityView.hidden = YES;
    _textView.hidden = YES;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:BFF_TRANSITION_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop)];

    if (!CGRectIsEmpty(originRect)) {
      _screenView.frame = CGRectOffset(originRect, 0, -BFFStatusHeight());
    } else {
      _screenView.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
    }

    _innerView.alpha = 0;
    _navigationBar.alpha = 0;

    [UIView commitAnimations];

  } else {
    [self dismissAnimationDidStop];
  }

  [self hideKeyboard];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)failWithError:(NSError*)error {
  [self showActivity:nil];

  NSString* title = [self titleForError:error];
  if (title.length) {
    UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:BFFLocalizedString(@"Error", @"")
      message:title delegate:nil cancelButtonTitle:BFFLocalizedString(@"Ok", @"")
      otherButtonTitles:nil] autorelease];
    [alertView show];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)willPostText:(NSString*)text {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForActivity {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForError:(NSError*)error {
  return nil;
}


@end
