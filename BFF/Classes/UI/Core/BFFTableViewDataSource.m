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

#import "BFFTableViewDataSource.h"

// UI
#import "BFFTextEditor.h"

// - Table Items
#import "BFFTableItem.h"
#import "BFFTableMoreButton.h"
#import "BFFTableSubtextItem.h"
#import "BFFTableRightCaptionItem.h"
#import "BFFTableCaptionItem.h"
#import "BFFTableSubtitleItem.h"
#import "BFFTableMessageItem.h"
#import "BFFTableImageItem.h"
#import "BFFTableStyledTextItem.h"
#import "BFFTableTextItem.h"
#import "BFFTableActivityItem.h"
#import "BFFTableControlItem.h"

// - Table Cells
#import "BFFTableMoreButtonCell.h"
#import "BFFTableSubtextItemCell.h"
#import "BFFTableRightCaptionItemCell.h"
#import "BFFTableCaptionItemCell.h"
#import "BFFTableSubtitleItemCell.h"
#import "BFFTableMessageItemCell.h"
#import "BFFTableImageItemCell.h"
#import "BFFStyledTextTableItemCell.h"
#import "BFFTableActivityItemCell.h"
#import "BFFTableControlCell.h"
#import "BFFTableTextItemCell.h"
#import "BFFStyledTextTableCell.h"
#import "BFFTableFlushViewCell.h"

// Style
#import "BFFStyledText.h"

// Core
#import "BFFCorePreprocessorMacros.h"
#import "BFFGlobalCoreLocale.h"

#import <objc/runtime.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFTableViewDataSource

@synthesize model = _model;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_model);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSArray*)lettersForSectionsWithSearch:(BOOL)search summary:(BOOL)summary {
  NSMutableArray* titles = [NSMutableArray array];
  if (search) {
    [titles addObject:UITableViewIndexSearch];
  }

  for (unichar c = 'A'; c <= 'Z'; ++c) {
    NSString* letter = [NSString stringWithFormat:@"%c", c];
    [titles addObject:letter];
  }

  if (summary) {
    [titles addObject:@"#"];
  }

  return titles;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell*)tableView:(UITableView *)tableView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];

  Class cellClass = [self tableView:tableView cellClassForObject:object];
  const char* className = class_getName(cellClass);
  NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                           length:strlen(className)
                                           encoding:NSASCIIStringEncoding freeWhenDone:NO];

  UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault
                               reuseIdentifier:identifier] autorelease];
  }
  [identifier release];

  if ([cell isKindOfClass:[BFFTableViewCell class]]) {
    [(BFFTableViewCell*)cell setObject:object];
  }

  [self tableView:tableView cell:cell willAppearAtIndexPath:indexPath];

  return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)title
            atIndex:(NSInteger)sectionIndex {
  if (tableView.tableHeaderView) {
    if (sectionIndex == 0)  {
      // This is a hack to get the table header to appear when the user touches the
      // first row in the section index.  By default, it shows the first row, which is
      // not usually what you want.
      [tableView scrollRectToVisible:tableView.tableHeaderView.bounds animated:NO];
      return -1;
    }
  }

  NSString* letter = [title substringToIndex:1];
  NSInteger sectionCount = [tableView numberOfSections];
  for (NSInteger i = 0; i < sectionCount; ++i) {
    NSString* section  = [tableView.dataSource tableView:tableView titleForHeaderInSection:i];
    if ([section hasPrefix:letter]) {
      return i;
    }
  }
  if (sectionIndex >= sectionCount) {
    return sectionCount-1;
  } else {
    return sectionIndex;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)delegates {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOutdated {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(BFFURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidate:(BOOL)erase {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<BFFModel>)model {
  return _model ? _model : self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
  if ([object isKindOfClass:[BFFTableItem class]]) {
    if ([object isKindOfClass:[BFFTableMoreButton class]]) {
      return [BFFTableMoreButtonCell class];
    } else if ([object isKindOfClass:[BFFTableSubtextItem class]]) {
      return [BFFTableSubtextItemCell class];
    } else if ([object isKindOfClass:[BFFTableRightCaptionItem class]]) {
      return [BFFTableRightCaptionItemCell class];
    } else if ([object isKindOfClass:[BFFTableCaptionItem class]]) {
      return [BFFTableCaptionItemCell class];
    } else if ([object isKindOfClass:[BFFTableSubtitleItem class]]) {
      return [BFFTableSubtitleItemCell class];
    } else if ([object isKindOfClass:[BFFTableMessageItem class]]) {
      return [BFFTableMessageItemCell class];
    } else if ([object isKindOfClass:[BFFTableImageItem class]]) {
      return [BFFTableImageItemCell class];
    } else if ([object isKindOfClass:[BFFTableStyledTextItem class]]) {
      return [BFFStyledTextTableItemCell class];
    } else if ([object isKindOfClass:[BFFTableActivityItem class]]) {
      return [BFFTableActivityItemCell class];
    } else if ([object isKindOfClass:[BFFTableControlItem class]]) {
      return [BFFTableControlCell class];
    } else {
      return [BFFTableTextItemCell class];
    }
  } else if ([object isKindOfClass:[BFFStyledText class]]) {
    return [BFFStyledTextTableCell class];
  } else if ([object isKindOfClass:[UIControl class]]
             || [object isKindOfClass:[UITextView class]]
             || [object isKindOfClass:[BFFTextEditor class]]) {
    return [BFFTableControlCell class];
  } else if ([object isKindOfClass:[UIView class]]) {
    return [BFFTableFlushViewCell class];
  }

  // This will display an empty white table cell - probably not what you want, but it
  // is better than crashing, which is what happens if you return nil here
  return [BFFTableViewCell class];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)tableView:(UITableView*)tableView labelForObject:(id)object {
  if ([object isKindOfClass:[BFFTableTextItem class]]) {
    BFFTableTextItem* item = object;
    return item.text;
  } else {
    return [NSString stringWithFormat:@"%@", object];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSIndexPath*)tableView:(UITableView*)tableView indexPathForObject:(id)object {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView*)tableView cell:(UITableViewCell*)cell
        willAppearAtIndexPath:(NSIndexPath*)indexPath {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableViewDidLoadModel:(UITableView*)tableView {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)search:(NSString*)text {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForLoading:(BOOL)reloading {
  if (reloading) {
    return BFFLocalizedString(@"Updating...", @"");
  } else {
    return BFFLocalizedString(@"Loading...", @"");
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForEmpty {
  return [self imageForError:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForEmpty {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForEmpty {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForError:(NSError*)error {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)titleForError:(NSError*)error {
  return BFFDescriptionForError(error);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)subtitleForError:(NSError*)error {
  return BFFLocalizedString(@"Sorry, there was an error.", @"");
}


@end


#pragma mark -
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFTableViewInterstitialDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFTableViewDataSource


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<BFFModel>)model {
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSMutableArray*)delegates {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoadingMore {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isOutdated {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(BFFURLRequestCachePolicy)cachePolicy more:(BOOL)more {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)invalidate:(BOOL)erase {
}


@end
