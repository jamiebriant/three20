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

#import "BFFModelViewController.h"

// UI
#import "BFFNavigator.h"

// UICommon
#import "BFFUIViewControllerAdditions.h"

// Network
#import "BFFModel.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFModelViewController

@synthesize model       = _model;
@synthesize modelError  = _modelError;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    _flags.isViewInvalid = YES;
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
  [_model.delegates removeObject:self];
  BFF_RELEASE_SAFELY(_model);
  BFF_RELEASE_SAFELY(_modelError);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetViewStates {
  if (_flags.isShowingLoading) {
    [self showLoading:NO];
    _flags.isShowingLoading = NO;
  }
  if (_flags.isShowingModel) {
    [self showModel:NO];
    _flags.isShowingModel = NO;
  }
  if (_flags.isShowingError) {
    [self showError:NO];
    _flags.isShowingError = NO;
  }
  if (_flags.isShowingEmpty) {
    [self showEmpty:NO];
    _flags.isShowingEmpty = NO;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateViewStates {
  if (_flags.isModelDidRefreshInvalid) {
    [self didRefreshModel];
    _flags.isModelDidRefreshInvalid = NO;
  }
  if (_flags.isModelWillLoadInvalid) {
    [self willLoadModel];
    _flags.isModelWillLoadInvalid = NO;
  }
  if (_flags.isModelDidLoadInvalid) {
    [self didLoadModel:_flags.isModelDidLoadFirstTimeInvalid];
    _flags.isModelDidLoadInvalid = NO;
    _flags.isModelDidLoadFirstTimeInvalid = NO;
    _flags.isShowingModel = NO;
  }

  BOOL showModel = NO, showLoading = NO, showError = NO, showEmpty = NO;

  if (_model.isLoaded || ![self shouldLoad]) {
    if ([self canShowModel]) {
      showModel = !_flags.isShowingModel;
      _flags.isShowingModel = YES;
    } else {
      if (_flags.isShowingModel) {
        [self showModel:NO];
        _flags.isShowingModel = NO;
      }
    }
  } else {
    if (_flags.isShowingModel) {
      [self showModel:NO];
      _flags.isShowingModel = NO;
    }
  }

  if (_model.isLoading) {
    showLoading = !_flags.isShowingLoading;
    _flags.isShowingLoading = YES;
  } else {
    if (_flags.isShowingLoading) {
      [self showLoading:NO];
      _flags.isShowingLoading = NO;
    }
  }

  if (_modelError) {
    showError = !_flags.isShowingError;
    _flags.isShowingError = YES;
  } else {
    if (_flags.isShowingError) {
      [self showError:NO];
      _flags.isShowingError = NO;
    }
  }

  if (!_flags.isShowingLoading && !_flags.isShowingModel && !_flags.isShowingError) {
    showEmpty = !_flags.isShowingEmpty;
    _flags.isShowingEmpty = YES;
  } else {
    if (_flags.isShowingEmpty) {
      [self showEmpty:NO];
      _flags.isShowingEmpty = NO;
    }
  }

  if (showModel) {
    [self showModel:YES];
    [self didShowModel:_flags.isModelDidShowFirstTimeInvalid];
    _flags.isModelDidShowFirstTimeInvalid = NO;
  }
  if (showEmpty) {
    [self showEmpty:YES];
  }
  if (showError) {
    [self showError:YES];
  }
  if (showLoading) {
    [self showLoading:YES];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createInterstitialModel {
  self.model = [[[BFFModel alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
  _isViewAppearing = YES;
  _hasViewAppeared = YES;

  [self updateView];

  [super viewWillAppear:animated];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didReceiveMemoryWarning {
  if (_hasViewAppeared && !_isViewAppearing) {
    [super didReceiveMemoryWarning];
    [self refresh];

  } else {
    [super didReceiveMemoryWarning];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController (BFFCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delayDidEnd {
  [self invalidateModel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidStartLoad:(id<BFFModel>)model {
  if (model == self.model) {
    _flags.isModelWillLoadInvalid = YES;
    _flags.isModelDidLoadFirstTimeInvalid = YES;
    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<BFFModel>)model {
  if (model == _model) {
    BFF_RELEASE_SAFELY(_modelError);
    _flags.isModelDidLoadInvalid = YES;
    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<BFFModel>)model didFailLoadWithError:(NSError*)error {
  if (model == _model) {
    self.modelError = error;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id<BFFModel>)model {
  if (model == _model) {
    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidChange:(id<BFFModel>)model {
  if (model == _model) {
    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<BFFModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<BFFModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<BFFModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidBeginUpdates:(id<BFFModel>)model {
  if (model == _model) {
    [self beginUpdates];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidEndUpdates:(id<BFFModel>)model {
  if (model == _model) {
    [self endUpdates];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<BFFModel>)model {
  if (!_model) {
    if (![BFFNavigator navigator].isDelayed) {
      [self createModel];
    }

    if (!_model) {
      [self createInterstitialModel];
    }
  }
  return _model;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setModel:(id<BFFModel>)model {
  if (_model != model) {
    [_model.delegates removeObject:self];
    [_model release];
    _model = [model retain];
    [_model.delegates addObject:self];
    BFF_RELEASE_SAFELY(_modelError);

    if (_model) {
      _flags.isModelWillLoadInvalid = NO;
      _flags.isModelDidLoadInvalid = NO;
      _flags.isModelDidLoadFirstTimeInvalid = NO;
      _flags.isModelDidShowFirstTimeInvalid = YES;
    }

    [self refresh];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setModelError:(NSError*)error {
  if (error != _modelError) {
    [_modelError release];
    _modelError = [error retain];

    [self invalidateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidateModel {
  BOOL wasModelCreated = self.isModelCreated;
  [self resetViewStates];
  [_model.delegates removeObject:self];
  BFF_RELEASE_SAFELY(_model);
  if (wasModelCreated) {
    self.model;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isModelCreated {
  return !!_model;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoad {
  return !self.model.isLoaded;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldReload {
  return !_modelError && self.model.isOutdated;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldLoadMore {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canShowModel {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  _flags.isViewInvalid = YES;
  [self.model load:BFFURLRequestCachePolicyNetwork more:NO];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadIfNeeded {
  if ([self shouldReload] && !self.model.isLoading) {
    [self reload];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refresh {
  _flags.isViewInvalid = YES;
  _flags.isModelDidRefreshInvalid = YES;

  BOOL loading = self.model.isLoading;
  BOOL loaded = self.model.isLoaded;
  if (!loading && !loaded && [self shouldLoad]) {
    [self.model load:BFFURLRequestCachePolicyDefault more:NO];
  } else if (!loading && loaded && [self shouldReload]) {
    [self.model load:BFFURLRequestCachePolicyNetwork more:NO];
  } else if (!loading && [self shouldLoadMore]) {
    [self.model load:BFFURLRequestCachePolicyDefault more:YES];
  } else {
    _flags.isModelDidLoadInvalid = YES;
    if (_isViewAppearing) {
      [self updateView];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)beginUpdates {
  _flags.isViewSuspended = YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)endUpdates {
  _flags.isViewSuspended = NO;
  [self updateView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidateView {
  _flags.isViewInvalid = YES;
  if (_isViewAppearing) {
    [self updateView];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateView {
  if (_flags.isViewInvalid && !_flags.isViewSuspended && !_flags.isUpdatingView) {
    _flags.isUpdatingView = YES;

    // Ensure the model is created
    self.model;
    // Ensure the view is created
    self.view;

    [self updateViewStates];

    if (_frozenState && _flags.isShowingModel) {
      [self restoreView:_frozenState];
      BFF_RELEASE_SAFELY(_frozenState);
    }

    _flags.isViewInvalid = NO;
    _flags.isUpdatingView = NO;

    [self reloadIfNeeded];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didRefreshModel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willLoadModel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didLoadModel:(BOOL)firstTime {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didShowModel:(BOOL)firstTime {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showModel:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showEmpty:(BOOL)show {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showError:(BOOL)show {
}


@end
