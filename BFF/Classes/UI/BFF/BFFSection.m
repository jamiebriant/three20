//
//  BFFSection.m
//  Locurious
//
//  Created by jamie on 8/24/10.
//BEGINLICENSE
//  Copyright 2010 binaryfinery.com. All rights reserved.
//  This source file may be used only with the permission of James Briant.
//  If you do not have a license agreement you may not use this file
//  nor use the information herein to create a derivative work.
//ENDLICENSE
//


#import "BFFSection.h"


@implementation BFFSectionedTableData

- (id) init
{
  self = [super init];
  if (self != nil) {
    _sections = [[NSMutableArray alloc] init];
  }
  return self;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [_sections count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  BFFSection* s = [_sections objectAtIndex:section];
  return s.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  BFFSection* s = [_sections objectAtIndex:section];
  return s.title;
  
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  BFFSection* s = [_sections objectAtIndex:[indexPath section]];
  return [s tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(BFFSection*)addSectionNamed:(NSString*)name {
  BFFSection* newSection = [[BFFSection alloc] initWithTitle:name];
  [_sections addObject:newSection];
  return newSection;
}
-(BFFSection*)addUnnamedSection {
  BFFSection* newSection = [[BFFSection alloc] init];
  [_sections addObject:newSection];
  return newSection;
}
- (BFFSectionRow*)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  BFFSection* s = [_sections objectAtIndex:[indexPath section]];
  return (BFFSectionRow*)[s tableView:tableView objectForRowAtIndexPath:indexPath];
}

-(void)clear {
  [_sections dealloc];
  _sections = [[NSMutableArray alloc] init];
}

- (Class)tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
  BFFSection* s = [_sections objectAtIndex:[indexPath section]];
  return [s tableView:tableView cellClassForRowAtIndexPath:indexPath];
}

@end


@implementation BFFSection



- (id) init
{
  self = [super init];
  if (self != nil) {
    _title = @"";
    _rows = [[NSMutableArray alloc] init];
  }
  return self;
}

- (id) initWithTitle:(NSString*)title
{
  self = [super init];
  if (self != nil) {
    _title = [[title copy] retain];
    _rows = [[NSMutableArray alloc] init];
  }
  return self;
}


-(NSInteger)count {
  return _rows.count;
}

-(NSString*) title {
  return _title;
}

-(id)objectInRow:(NSInteger)rowidx {
  BFFSectionRow* row =  [_rows objectAtIndex:rowidx];
  return row.item;
}

-(BFFSectionRow*)addRow:(id)what {
  BFFSectionRow* row = [[BFFSectionRow alloc] initWithItem:what];
  [_rows addObject:row];
  return row;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  BFFSectionRow* s = [_rows objectAtIndex:[indexPath row]];
  return [s tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  BFFSectionRow* row =  [_rows objectAtIndex:[indexPath row]];
  return row; // [row tableView:tableView objectForRowAtIndexPath:indexPath];
  
}

- (Class)tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
  BFFSectionRow* row =  [_rows objectAtIndex:[indexPath row]];
  return [row tableView:tableView cellClassForRowAtIndexPath:indexPath];
}

@end
   

@implementation BFFSectionRow

@synthesize height = _height;
@synthesize cellClass = _cellClass;

- (id) initWithItem:(id)what
{
  self = [super init];
  if (self != nil) {
    _item = [what retain];
    _height = -42.0f;
    _cellClass = nil;
  }
  return self;
}

-(id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath {
  return _item;
}

- (Class)tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath {
  return _cellClass;
}


- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  return _height;
}

-(float) height {
  return _height;
}

-(id) item {
  return _item;
}

-(Class) cellClass {
  return _cellClass;
}

-(void) setCellClass:(Class) what {
  _cellClass = what;
}
@end


   
   
