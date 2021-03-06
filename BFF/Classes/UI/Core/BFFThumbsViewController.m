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

#import "BFFThumbsViewController.h"

// UI
#import "BFFNavigator.h"
#import "BFFThumbsDataSource.h"
#import "BFFThumbsTableViewCell.h"
#import "BFFPhoto.h"
#import "BFFPhotoSource.h"
#import "BFFPhotoViewController.h"
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
#import "BFFGlobalCoreRects.h"
#import "BFFCorePreprocessorMacros.h"

static CGFloat kThumbnailRowHeight = 79;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFThumbsViewController

@synthesize delegate    = _delegate;
@synthesize photoSource = _photoSource;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    self.statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationBarStyle = UIBarStyleBlackTranslucent;
    self.navigationBarTintColor = nil;
    self.wantsFullScreenLayout = YES;
    self.hidesBottomBarWhenPushed = YES;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithDelegate:(id<BFFThumbsViewControllerDelegate>)delegate {
  if (self = [self initWithNibName:nil bundle:nil]) {
    self.delegate = delegate;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithQuery:(NSDictionary*)query {
  id<BFFThumbsViewControllerDelegate> delegate = [query objectForKey:@"delegate"];
  if (nil != delegate) {
    self = [self initWithDelegate:delegate];

  } else {
    self = [self initWithNibName:nil bundle:nil];
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
  [_photoSource.delegates removeObject:self];
  BFF_RELEASE_SAFELY(_photoSource);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)suspendLoadingThumbnails:(BOOL)suspended {
  if (_photoSource.maxPhotoIndex >= 0) {
    NSArray* cells = _tableView.visibleCells;
    for (int i = 0; i < cells.count; ++i) {
      BFFThumbsTableViewCell* cell = [cells objectAtIndex:i];
      if ([cell isKindOfClass:[BFFThumbsTableViewCell class]]) {
        [cell suspendLoading:suspended];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateTableLayout {
  self.tableView.contentInset = UIEdgeInsetsMake(BFFBarsHeight()+4, 0, 0, 0);
  self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(BFFBarsHeight(), 0, 0, 0);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)URLForPhoto:(id<BFFPhoto>)photo {
  if ([photo respondsToSelector:@selector(URLValueWithName:)]) {
    return [photo URLValueWithName:@"BFFPhotoViewController"];
  } else {
    return nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
  [super loadView];

  self.tableView.rowHeight = kThumbnailRowHeight;
  self.tableView.autoresizingMask =
  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.tableView.backgroundColor = BFFSTYLEVAR(backgroundColor);
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self updateTableLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self suspendLoadingThumbnails:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidDisappear:(BOOL)animated {
  [self suspendLoadingThumbnails:YES];
  [super viewDidDisappear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return BFFIsSupportedOrientation(interfaceOrientation);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
  [self updateTableLayout];
  [self.tableView reloadData];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (BFFCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  NSString* delegate = [[BFFNavigator navigator] pathForObject:_delegate];
  if (delegate) {
    [state setObject:delegate forKey:@"delegate"];
  }
  return [super persistView:state];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreView:(NSDictionary*)state {
  [super restoreView:state];
  NSString* delegate = [state objectForKey:@"delegate"];
  if (delegate) {
    self.delegate = [[BFFNavigator navigator] objectForPath:delegate];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDelegate:(id<BFFThumbsViewControllerDelegate>)delegate {
  _delegate = delegate;

  if (_delegate) {
    self.navigationItem.leftBarButtonItem =
    [[[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] init]
                                                  autorelease]]
     autorelease];
    self.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:BFFLocalizedString(@"Done", @"")
                                      style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(removeFromSupercontroller)] autorelease];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFModelViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRefreshModel {
  [super didRefreshModel];
  self.title = _photoSource.title;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTableViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForOverlayView {
  return BFFRectContract(CGRectOffset([super rectForOverlayView], 0, BFFBarsHeight()-_tableView.top),
                        0, BFFBarsHeight());
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFThumbsTableViewCellDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)thumbsTableViewCell:(BFFThumbsTableViewCell*)cell didSelectPhoto:(id<BFFPhoto>)photo {
  [_delegate thumbsViewController:self didSelectPhoto:photo];

  BOOL shouldNavigate = YES;
  if ([_delegate respondsToSelector:@selector(thumbsViewController:shouldNavigateToPhoto:)]) {
    shouldNavigate = [_delegate thumbsViewController:self shouldNavigateToPhoto:photo];
  }

  if (shouldNavigate) {
    NSString* URL = [self URLForPhoto:photo];
    if (URL) {
      BFFOpenURL(URL);
    } else {
      BFFPhotoViewController* controller = [self createPhotoViewController];
      controller.centerPhoto = photo;
      [self.navigationController pushViewController:controller animated:YES];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhotoSource:(id<BFFPhotoSource>)photoSource {
  if (photoSource != _photoSource) {
    [_photoSource release];
    _photoSource = [photoSource retain];

    self.title = _photoSource.title;
    self.dataSource = [self createDataSource];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFPhotoViewController*)createPhotoViewController {
  return [[[BFFPhotoViewController alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<BFFTableViewDataSource>)createDataSource {
  return [[[BFFThumbsDataSource alloc] initWithPhotoSource:_photoSource delegate:self] autorelease];
}


@end
