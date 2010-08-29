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
#import "BFFModelViewController.h"
#import "BFFScrollViewDelegate.h"
#import "BFFScrollViewDataSource.h"
#import "BFFThumbsViewControllerDelegate.h"

@protocol BFFPhotoSource;
@class BFFScrollView;
@class BFFPhotoView;
@class BFFStyle;

@interface BFFPhotoViewController : BFFModelViewController <
  BFFScrollViewDelegate,
  BFFScrollViewDataSource,
  BFFThumbsViewControllerDelegate
> {
  id<BFFPhoto>       _centerPhoto;
  NSInteger         _centerPhotoIndex;

  UIView*           _innerView;
  BFFScrollView*     _scrollView;
  BFFPhotoView*      _photoStatusView;

  UIToolbar*        _toolbar;
  UIBarButtonItem*  _nextButton;
  UIBarButtonItem*  _previousButton;

  BFFStyle*          _captionStyle;

  UIImage*          _defaultImage;

  NSString*         _statusText;

  NSTimer*          _slideshowTimer;
  NSTimer*          _loadTimer;

  BOOL              _delayLoad;

  BFFThumbsViewController* _thumbsController;

  id<BFFPhotoSource> _photoSource;
}

/**
 * The source of a sequential photo collection that will be displayed.
 */
@property (nonatomic, retain) id<BFFPhotoSource> photoSource;

/**
 * The photo that is currently visible and centered.
 *
 * You can assign this directly to change the photoSource to the one that contains the photo.
 */
@property (nonatomic, retain) id<BFFPhoto> centerPhoto;

/**
 * The index of the currently visible photo.
 *
 * Because centerPhoto can be nil while waiting for the source to load the photo, this property
 * must be maintained even though centerPhoto has its own index property.
 */
@property (nonatomic, readonly) NSInteger centerPhotoIndex;

/**
 * The default image to show before a photo has been loaded.
 */
@property (nonatomic, retain) UIImage* defaultImage;

/**
 * The style to use for the caption label.
 */
@property (nonatomic, retain) BFFStyle* captionStyle;

- (id)initWithPhoto:(id<BFFPhoto>)photo;
- (id)initWithPhotoSource:(id<BFFPhotoSource>)photoSource;

/**
 * Creates a photo view for a new page.
 *
 * Do not call this directly. It is meant to be overriden by subclasses.
 */
- (BFFPhotoView*)createPhotoView;

/**
 * Creates the thumbnail controller used by the "See All" button.
 *
 * Do not call this directly. It is meant to be overriden by subclasses.
 */
- (BFFThumbsViewController*)createThumbsViewController;

/**
 * Sent to the controller after it moves from one photo to another.
 */
- (void)didMoveToPhoto:(id<BFFPhoto>)photo fromPhoto:(id<BFFPhoto>)fromPhoto;

/**
 * Shows or hides an activity label on top of the photo.
 */
- (void)showActivity:(NSString*)title;

@end
