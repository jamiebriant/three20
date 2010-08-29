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

#import "BFFViewController.h"

// UI
#import "BFFNavigator.h"
#import "BFFTableViewController.h"
#import "BFFSearchDisplayController.h"

// UINavigator
#import "BFFGlobalNavigatorMetrics.h"
#import "BFFUIViewController+BFFNavigator.h"

// UICommon
#import "BFFGlobalUICommon.h"
#import "BFFUIViewControllerAdditions.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFStyleSheet.h"

// Network
#import "BFFURLRequestQueue.h"

// Core
#import "BFFCorePreprocessorMacros.h"
#import "BFFDebug.h"
#import "BFFDebugFlags.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.navigationBarTintColor = BFFSTYLEVAR(navigationBarTintColor);
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [self initWithNibName:nil bundle:nil]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [[BFFURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  if (nil != self.nibName) {
    [super loadView];

  } else {
    CGRect frame = self.wantsFullScreenLayout ? BFFScreenBounds() : BFFNavigationFrame();
    self.view = [[[UIView alloc] initWithFrame:frame] autorelease];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = BFFSTYLEVAR(backgroundColor);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
  [super viewDidUnload];
  BFF_RELEASE_SAFELY(_searchController);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [BFFURLRequestQueue mainQueue].suspended = YES;

  // Ugly hack to work around UISearchBar's inability to resize its text field
  // to avoid being overlapped by the table section index
//  if (_searchController && !_searchController.active) {
//    [_searchController setActive:YES animated:NO];
//    [_searchController setActive:NO animated:NO];
//  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [BFFURLRequestQueue mainQueue].suspended = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFTableViewController*)searchViewController {
  return _searchController.searchResultsViewController;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSearchViewController:(BFFTableViewController*)searchViewController {
  if (searchViewController) {
    if (nil == _searchController) {
      UISearchBar* searchBar = [[[UISearchBar alloc] init] autorelease];
      [searchBar sizeToFit];

      _searchController = [[BFFSearchDisplayController alloc] initWithSearchBar:searchBar
                                                             contentsController:self];
    }

    searchViewController.superController = self;
    _searchController.searchResultsViewController = searchViewController;

  } else {
    _searchController.searchResultsViewController = nil;
    BFF_RELEASE_SAFELY(_searchController);
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)doGarbageCollection {
  [UIViewController doNavigatorGarbageCollection];
  [UIViewController doCommonGarbageCollection];
}


@end
