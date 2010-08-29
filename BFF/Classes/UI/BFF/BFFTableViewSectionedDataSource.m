//
//  BFFTableViewSectionedDataSource.m
//  Locurious
//
//  Created by jamie on 8/26/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import "BFFTableViewSectionedDataSource.h"
#import "BFFSection.h"
#import <objc/runtime.h>

@implementation BFFTableViewSectionedDataSource

@synthesize data = _data;

- (id) init
{
  self = [super init];
  if (self != nil) {
    _data = [[BFFSectionedTableData alloc] init];
  }
  return self;
}



- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {  
  
  if ([object isKindOfClass:[BFFSectionRow class]]) {
    BFFSectionRow* row = (BFFSectionRow*)object;
    if ( row.cellClass != nil) {
      return row.cellClass;
    }
    else {
      return [super tableView:tableView cellClassForObject:row.item];
    }
  }
  // and if it isn't, why not?
  return [super tableView:tableView cellClassForObject:object];
}
              
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  Class cellClass = [_data tableView:tableView cellClassForRowAtIndexPath:indexPath];
  id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];  
  if ([object isKindOfClass:[BFFSectionRow class]]) {
    BFFSectionRow* row = (BFFSectionRow*)object;
    object = row.item;
    cellClass = row.cellClass;
  }  
  if (cellClass == nil) {
    // skip what we already know
    cellClass = [super tableView:tableView cellClassForObject:object];
  }
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

   
   

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [_data numberOfSectionsInTableView:tableView];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_data tableView:tableView numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [_data tableView:tableView titleForHeaderInSection:section];
}

- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  BFFSectionRow* row  = [_data tableView:tableView objectForRowAtIndexPath:indexPath];
  return row.item;
}

@end
