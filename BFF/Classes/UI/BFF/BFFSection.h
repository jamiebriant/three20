//
//  BFFSection.h
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

#import <Foundation/Foundation.h>

@class BFFSection;
@class BFFSectionRow;

// the root of the hierarchy
@interface BFFSectionedTableData : NSObject
{
  NSMutableArray* _sections;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
-(BFFSection*)addSectionNamed:(NSString*)name;
-(BFFSection*)addUnnamedSection;
-(id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)clear;
- (Class)tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
@end


@interface BFFSection : NSObject {
  NSString* _title;
  NSMutableArray* _rows;
}
@property (readonly) NSInteger count;
@property (readonly) NSString* title;


- (id) init;
- (id) initWithTitle:(NSString*)title;
-(id)objectInRow:(NSInteger)row;
-(BFFSectionRow*)addRow:(id)what;
- (Class)tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
-(BFFSectionRow*)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface BFFSectionRow : NSObject {
  id    _item;
  float _height;
  Class _cellClass;
}

- (id) initWithItem:(id)what;

- (Class)tableView:(UITableView *)tableView cellClassForRowAtIndexPath:(NSIndexPath *)indexPath;
-(id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;


@property (readonly, retain) id item;
@property (nonatomic) float height;
@property (retain) Class cellClass;


@end



