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

#import "BFFThumbsDataSource.h"

// UI
#import "BFFPhotoSource.h"
#import "BFFTableMoreButton.h"
#import "BFFThumbsTableViewCell.h"

// UINavigator
#import "BFFGlobalNavigatorMetrics.h"

// Network
#import "BFFGlobalNetwork.h"
#import "BFFURLCache.h"

// Core
#import "BFFGlobalCoreLocale.h"
#import "BFFCorePreprocessorMacros.h"

static CGFloat kThumbSize = 75;
static CGFloat kThumbSpacing = 4;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFThumbsDataSource

@synthesize photoSource = _photoSource;
@synthesize delegate    = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithPhotoSource:(id<BFFPhotoSource>)photoSource
                 delegate:(id<BFFThumbsTableViewCellDelegate>)delegate {
  if (self = [super init]) {
    _photoSource = [photoSource retain];
    _delegate = delegate;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_photoSource);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasMoreToLoad {
  return _photoSource.maxPhotoIndex+1 < _photoSource.numberOfPhotos;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)columnCount {
  CGFloat width = BFFScreenBounds().size.width;
  return round((width - kThumbSpacing*2) / (kThumbSize+kThumbSpacing));
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger maxIndex = _photoSource.maxPhotoIndex;
  NSInteger columnCount = self.columnCount;
  if (maxIndex >= 0) {
    maxIndex += 1;
    NSInteger count =  ceil((maxIndex / columnCount) + (maxIndex % columnCount ? 1 : 0));
    if (self.hasMoreToLoad) {
      return count + 1;
    } else {
      return count;
    }
  } else {
    return 0;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<BFFModel>)model {
  return _photoSource;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  if (indexPath.row == [tableView numberOfRowsInSection:0]-1 && self.hasMoreToLoad) {
    NSString* text = BFFLocalizedString(@"Load More Photos...", @"");
    NSString* caption = nil;
    if (_photoSource.numberOfPhotos == -1) {
      caption = [NSString stringWithFormat:BFFLocalizedString(@"Showing %@ Photos", @""),
                 BFFFormatInteger(_photoSource.maxPhotoIndex+1)];
    } else {
      caption = [NSString stringWithFormat:BFFLocalizedString(@"Showing %@ of %@ Photos", @""),
                 BFFFormatInteger(_photoSource.maxPhotoIndex+1),
                 BFFFormatInteger(_photoSource.numberOfPhotos)];
    }

    return [BFFTableMoreButton itemWithText:text subtitle:caption];
  } else {
    NSInteger columnCount = self.columnCount;
    return [_photoSource photoAtIndex:indexPath.row * columnCount];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object conformsToProtocol:@protocol(BFFPhoto)]) {
    return [BFFThumbsTableViewCell class];
  } else {
    return [super tableView:tableView cellClassForObject:object];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)        tableView: (UITableView*)tableView
                     cell: (UITableViewCell*)cell
    willAppearAtIndexPath: (NSIndexPath*)indexPath {
  if ([cell isKindOfClass:[BFFThumbsTableViewCell class]]) {
    BFFThumbsTableViewCell* thumbsCell = (BFFThumbsTableViewCell*)cell;
    thumbsCell.delegate = _delegate;
    thumbsCell.columnCount = self.columnCount;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath*)tableView:(UITableView*)tableView willInsertObject:(id)object
              atIndexPath:(NSIndexPath*)indexPath {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath*)tableView:(UITableView*)tableView willRemoveObject:(id)object
              atIndexPath:(NSIndexPath*)indexPath {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
  return BFFLocalizedString(@"No Photos", @"");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForEmpty {
  return BFFLocalizedString(@"This photo set contains no photos.", @"");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForError:(NSError*)error {
  return BFFIMAGE(@"bundle://Three20.bundle/images/photoDefault.png");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return BFFLocalizedString(@"Unable to load this photo set.", @"");
}


@end
