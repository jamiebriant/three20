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

#import "BFFTableHeaderDragRefreshView.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFDefaultStyleSheet+DragRefreshHeader.h"

// Network
#import "BFFURLCache.h"

// Core
#import "BFFGlobalCoreLocale.h"
#import "BFFCorePreprocessorMacros.h"

#import <QuartzCore/QuartzCore.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFTableHeaderDragRefreshView

@synthesize isFlipped = _isFlipped;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if(self = [super initWithFrame:frame]) {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    _lastUpdatedLabel = [[UILabel alloc]
                         initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f,
                                                  frame.size.width, 20.0f)];
    _lastUpdatedLabel.autoresizingMask =
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _lastUpdatedLabel.font            = BFFSTYLEVAR(tableRefreshHeaderLastUpdatedFont);
    _lastUpdatedLabel.textColor       = BFFSTYLEVAR(tableRefreshHeaderTextColor);
    _lastUpdatedLabel.shadowColor     = BFFSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _lastUpdatedLabel.shadowOffset    = BFFSTYLEVAR(tableRefreshHeaderTextShadowOffset);
    _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
    _lastUpdatedLabel.textAlignment   = UITextAlignmentCenter;
    [self addSubview:_lastUpdatedLabel];

    _statusLabel = [[UILabel alloc]
                    initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f,
                                             frame.size.width, 20.0f )];
    _statusLabel.autoresizingMask =
      UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _statusLabel.font             = BFFSTYLEVAR(tableRefreshHeaderStatusFont);
    _statusLabel.textColor        = BFFSTYLEVAR(tableRefreshHeaderTextColor);
    _statusLabel.shadowColor      = BFFSTYLEVAR(tableRefreshHeaderTextShadowColor);
    _statusLabel.shadowOffset     = BFFSTYLEVAR(tableRefreshHeaderTextShadowOffset);
    _statusLabel.backgroundColor  = [UIColor clearColor];
    _statusLabel.textAlignment    = UITextAlignmentCenter;
    [self setStatus:BFFTableHeaderDragRefreshPullToReload];
    [self addSubview:_statusLabel];

    _arrowImage = [[UIImageView alloc]
                   initWithFrame:CGRectMake(25.0f, frame.size.height - 65.0f,
                                            30.0f, 55.0f)];
    _arrowImage.contentMode       = UIViewContentModeScaleAspectFit;
    _arrowImage.image             = BFFSTYLEVAR(tableRefreshHeaderArrowImage);
    [_arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
    [self addSubview:_arrowImage];

    _activityView = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake( 25.0f, frame.size.height - 38.0f, 20.0f, 20.0f );
    _activityView.hidesWhenStopped  = YES;
    [self addSubview:_activityView];

    _isFlipped = NO;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_activityView);
  BFF_RELEASE_SAFELY(_statusLabel);
  BFF_RELEASE_SAFELY(_arrowImage);
  BFF_RELEASE_SAFELY(_lastUpdatedLabel);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)flipImageAnimated:(BOOL)animated {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:animated ? .18 : 0.0];
  [_arrowImage layer].transform = _isFlipped ?
    CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) :
    CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
  [UIView commitAnimations];

  _isFlipped = !_isFlipped;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUpdateDate:(NSDate*)newDate {
  if (newDate) {
    if (_lastUpdatedDate != newDate) {
      [_lastUpdatedDate release];
    }

    _lastUpdatedDate = [newDate retain];

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    _lastUpdatedLabel.text = [NSString stringWithFormat:
                              BFFLocalizedString(@"Last updated: %@",
                                                @"The last time the table view was updated."),
                              [formatter stringFromDate:_lastUpdatedDate]];
    [formatter release];

  } else {
    _lastUpdatedDate = nil;
    _lastUpdatedLabel.text = BFFLocalizedString(@"Last updated: never",
                                               @"The table view has never been updated");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentDate {
  [self setUpdateDate:[NSDate date]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStatus:(BFFTableHeaderDragRefreshStatus)status {
  switch (status) {
    case BFFTableHeaderDragRefreshReleaseToReload: {
      _statusLabel.text = BFFLocalizedString(@"Release to update...",
                                            @"Release the table view to update the contents.");
      break;
    }

    case BFFTableHeaderDragRefreshPullToReload: {
      _statusLabel.text = BFFLocalizedString(@"Pull down to update...",
                                            @"Drag the table view down to update the contents.");
      break;
    }

    case BFFTableHeaderDragRefreshLoadingStatus: {
      _statusLabel.text = BFFLocalizedString(@"Updating...",
                                            @"Updating the contents of a table view.");
      break;
    }

    default: {
      break;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(BOOL)shouldShow {
  if (shouldShow) {
    [_activityView startAnimating];
    _arrowImage.hidden = YES;
    [self setStatus:BFFTableHeaderDragRefreshLoadingStatus];

  } else {
    [_activityView stopAnimating];
    _arrowImage.hidden = NO;
  }

}


@end
